// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;


contract EncodeWithSelector {
    bytes4 selector = bytes4(keccak256("add(uint256,uint256)"));

    function add(uint256 num1 , uint256 num2 ,address con) public  returns(bool){
        bytes memory calldta=abi.encodeWithSelector(selector, num1, num2);
        (bool success, )=con.call(calldta);
        require(success,"Not call the address");
        return success;
    }
}

contract Add{
    uint256 public result;
    function add(uint256 num1,uint256 num2) public  returns(uint256){
        result=num1 + num2;
        return result;
    }
}