// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";

contract TimelockWallet is Ownable {
    // Struct to store each user's deposit details
    struct Deposit {
        uint256 amount;
        uint256 Time;
    }


    uint256 private setLockedTime;
    // Mapping to store each user's deposits
    mapping(address => Deposit) public deposits;

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
    function withdraw(uint256 _amount) public {
        if(msg.sender != owner()){
        require( _amount <= deposits[msg.sender].amount, "No funds to withdraw");
        require(block.timestamp >= deposits[msg.sender].Time + setLockedTime, "Funds are still locked");
        deposits[msg.sender].amount -= _amount;
        }
        else {
        if(_amount > deposits[msg.sender].amount){
            deposits[msg.sender].amount = 0;
        }  
        else{
            deposits[msg.sender].amount -=_amount;
        }
    }

        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "Transfer failed");

        emit WithdrawalMade(msg.sender, _amount);
    }

    function setLockedTimeValue(uint256 _setTime) external onlyOwner{
        setLockedTime=_setTime;
    }

    // Fallback function to accept Ether
    receive() external payable {
        revert("Use the deposit function to send Ether");
    }

    
}
