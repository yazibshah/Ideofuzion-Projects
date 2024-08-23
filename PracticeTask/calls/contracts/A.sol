// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "./IA.sol";
contract A is IA{
    uint256 public a;

    function setValue(uint256 _a) external payable {
        a=_a;
    }

}