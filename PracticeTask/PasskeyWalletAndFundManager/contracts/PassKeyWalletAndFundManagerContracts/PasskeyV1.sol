// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;


import {PasskeyWallet} from "./Passkey.sol";
import "hardhat/console.sol";

contract PasskeyWalletV1 is PasskeyWallet{

    function mul() public pure returns(uint256) {
        return 50;
    }
}