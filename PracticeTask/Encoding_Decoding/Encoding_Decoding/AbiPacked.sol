// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;


contract ABIPACKED{
    function packed() public pure returns(bytes memory){
        uint256 age=16;
        bytes memory pac=abi.encodePacked(age,"Hello");
        return pac;
    }

    /* unction decodePacked(bytes memory packedData) public pure returns(uint256 age,string memory str){
        age=uint256(bytes32(packedData[:32]));
    } */

}