    // SPDX-License-Identifier: MIT
    pragma solidity 0.8.24;

    contract Upgrade{

        uint256 public num;

        function add(uint256 a, uint256 b) public returns(uint256){
            num=a+b;
            return num;
        }
    }