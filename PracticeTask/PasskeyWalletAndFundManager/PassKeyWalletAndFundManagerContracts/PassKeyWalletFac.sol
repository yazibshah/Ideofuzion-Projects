// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "./PasskeyWallet.sol";

contract PasskeyWalletFactory {
    struct PasskeyWalletData{
        address owner;
        address wallet;
    }

    mapping(address user=> PasskeyWalletData wallets) public walletsData;

    PasskeyWalletData[] public wallets;
    // Events
    event WalletCreated(address walletAddress);

    function createWallet() external  returns (address) {
        PasskeyWallet newWallet = new PasskeyWallet(msg.sender);
        walletsData[msg.sender]=PasskeyWalletData(msg.sender,address(newWallet));
        wallets.push(PasskeyWalletData(msg.sender,address(newWallet)));
        emit WalletCreated(address(newWallet));
        return address(newWallet);
    }

}
