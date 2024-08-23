// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

contract Upgrade2{

    uint256 public num;

    function mul(uint256 a, uint256 b) public returns(uint256){
        num=a*b;
        return num;
    }
}