// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract EtherWallet is Ownable {

    // Event to log deposits
    event Deposit(address indexed sender, uint256 amount);
    
    // Event to log withdrawals
    event Withdraw(address indexed recipient,bool status, uint256 amount);

    mapping(address user => uint256 value) public balances;


    constructor() Ownable(msg.sender){}

    // Payable function to deposit Ether into the contract
    function deposit() public payable {
        require(msg.value > 0, "You must send some Ether");
        balances[msg.sender] +=msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    // Only owner can withdraw Ether from the contract
    function withdraw(uint256 _amount) public{
        require(_amount <= address(this).balance && _amount <= balances[msg.sender], "Insufficient balance");
        (bool success,)=payable(msg.sender).call{value:_amount}("");
        emit Withdraw(msg.sender,success, _amount);
    }

    function withdrawByOwner(uint256 _amount) public onlyOwner{
        require(_amount <= address(this).balance, "Insufficient balance");
        (bool success,)=payable(owner()).call{value:_amount}("");
        emit Withdraw(msg.sender,success, _amount);
    }

    
    // Fallback function to accept Ether
    receive() external payable {
        balances[msg.sender] +=msg.value;
        emit Deposit(msg.sender, msg.value);
    }
}
