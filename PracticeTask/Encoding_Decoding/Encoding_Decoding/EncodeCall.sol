// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract EncodeWithSelector {

    Add public addd;

    // Set the Add contract address
    function setAddContract(address con) public {
        addd = Add(con);
    }

    // Encode and call the add function of Add contract
    function callAdd(uint256 num1, uint256 num2) public returns (bool, bytes memory) {
        bytes memory calldta = abi.encodeCall(addd.add, (num1, num2));
        
        // Call the Add contract
        (bool success, bytes memory returnData) = address(addd).call(calldta);
        
        require(success, "Call to Add contract failed");
        return (success, returnData);
    }
}

contract Add {
    uint256 public result;

    function add(uint256 num1, uint256 num2) public returns (uint256) {
        result = num1 + num2;
        return result;
    }
}
