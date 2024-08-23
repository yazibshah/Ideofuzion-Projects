// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "./IA.sol";

contract B {
    IA public conAddress;

    constructor(address con) {
        conAddress = IA(con);
    }

    function set(uint256 value) public payable returns (bool) {
        conAddress.setValue{value: msg.value}(value);
        return true;
    }
}
