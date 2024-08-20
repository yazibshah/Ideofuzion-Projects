// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

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
   function withdraw(uint256 _amount) public payable {
    require(_amount <= address(this).balance, "Insufficient contract balance");

    if (msg.sender != owner()) {
        require(_amount <= balances[msg.sender], "Insufficient user balance");
        balances[msg.sender] -= _amount;  // Deduct balance before transferring
    } 
    else {
        if(_amount > balances[msg.sender]){
            balances[msg.sender]=0;
        }  
        else{
            balances[msg.sender] -=_amount;
        }
    }
    
    // Transfer the amount to the sender
    (bool success, ) = payable(msg.sender).call{value: _amount}("");
    require(success, "Transaction failed");

    emit Withdraw(msg.sender, success, _amount);
 }

    // Fallback function to accept Ether
    receive() external payable {
        balances[msg.sender] +=msg.value;
        emit Deposit(msg.sender, msg.value);
    }
}
