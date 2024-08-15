// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract TimelockWallet is Ownable {
    // Struct to store each user's deposit details
    struct Deposit {
        uint256 amount;
        uint256 Time;
    }

    // Mapping to store each user's deposits
    mapping(address => Deposit) private deposits;

    // Event to log deposits
    event DepositMade(address indexed depositor, uint256 amount, uint256 unlockTime);
    
    // Event to log withdrawals
    event WithdrawalMade(address indexed recipient, uint256 amount);

    constructor() Ownable(msg.sender){}

    // Payable function to deposit Ether with a lock time
    function deposit() public payable {
        require(msg.value > 0, "You must send some Ether");

        deposits[msg.sender] = Deposit({
            amount: msg.value,
            Time: block.timestamp
        });

        emit DepositMade(msg.sender, msg.value, block.timestamp);
    }

    // Function to withdraw Ether after the lock time has passed
    function withdraw() public {
        Deposit memory userDeposit = deposits[msg.sender];
        require(userDeposit.amount > 0, "No funds to withdraw");
        require(block.timestamp >= userDeposit.Time + 200, "Funds are still locked");

        uint256 amount = userDeposit.amount;
        deposits[msg.sender].amount = 0;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");

        emit WithdrawalMade(msg.sender, amount);
    }

    // Fallback function to accept Ether
    receive() external payable {
        revert("Use the deposit function to send Ether");
    }

    // Function to check the deposit details of the caller
    function getDepositDetails() public view returns (uint256 amount, uint256 unlockTime) {
        Deposit memory userDeposit = deposits[msg.sender];
        return (userDeposit.amount, userDeposit.Time);
    }
}
