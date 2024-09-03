// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

contract EncodeDecode{
    function encode(uint256 age, string memory name) public pure returns(bytes memory) {
        bytes memory ABI=abi.encode(age,name);
        return ABI;

    }

    function decode(bytes memory abiEnocde )
     public  pure returns (uint256 , string memory){
        return abi.decode(abiEnocde,(uint256,string));

    }
}
