// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "hardhat/console.sol";

contract CustomToken is ERC20, Ownable, Pausable {
    uint256 public constant TOKEN_PRICE = 0.1 ether;
    uint256 public constant DISCOUNT_PRICE = 0.075 ether;
    uint256 public constant FEE_PERCENTAGE = 1;
    uint256 public constant BURN_REFUND_PERCENTAGE = 75;
    uint256 public constant INITIAL_SUPPLY = 10000 * (10 ** 18); // 10,000 tokens with 18 decimals

    mapping(address => bool) private _specialAddresses;

    constructor() Ownable(msg.sender) ERC20("CustomToken", "CTK") {
        _mint(msg.sender, INITIAL_SUPPLY); // Mint initial 10,000 tokens to the owner
    }

    // Function to mint tokens manually
    function mint(uint256 amount) public payable whenNotPaused {
        uint256 price = _specialAddresses[msg.sender] ? DISCOUNT_PRICE : TOKEN_PRICE;
        uint256 totalCost = amount * price;
        require(msg.value >= totalCost, "Insufficient ETH sent for minting");

        if (msg.value > totalCost) {
            uint256 excess = msg.value - totalCost;
            (bool success,)=payable(msg.sender).call{value:excess}(""); // Return excess ETH to the sender
            console.log(success);
        }

        _mint(msg.sender, amount * (10 ** 18)); // Mint tokens with 18 decimals
    }

    // Function to whitelist special addresses
    function setSpecialAddress(address specialAddress, bool isSpecial) public onlyOwner {
        _specialAddresses[specialAddress] = isSpecial;
    }

    // Function to check if an address is special
    function isSpecialAddress(address account) public view returns (bool) {
        return _specialAddresses[account];
    }

    // Override transfer function to include fee deduction
    function transfer(address recipient, uint256 amount) public override whenNotPaused returns (bool) {
        uint256 fee = (amount * FEE_PERCENTAGE) / 100;
        uint256 amountAfterFee = amount - fee;

        // Transfer fee to the owner
        _transfer(_msgSender(), owner(), fee);

        // Transfer remaining tokens to recipient
        _transfer(_msgSender(), recipient, amountAfterFee);

        return true;
    }

    // Override transferFrom function to include fee deduction
    function transferFrom(address sender, address recipient, uint256 amount) public override whenNotPaused returns (bool) {
        uint256 fee = (amount * FEE_PERCENTAGE) / 100;
        uint256 amountAfterFee = amount - fee;

        // Transfer fee to the owner
        _transfer(sender, owner(), fee);

        // Transfer remaining tokens to recipient
        _transfer(sender, recipient, amountAfterFee);

        // Update allowance
        uint256 currentAllowance = allowance(sender, _msgSender());
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    // Function to burn tokens and receive 75% of the token's price in ETH
    function burn(uint256 amount) public whenNotPaused {
        uint256 tokenPrice = _specialAddresses[msg.sender] ? DISCOUNT_PRICE : TOKEN_PRICE;
        uint256 ethRefund = (amount * tokenPrice * BURN_REFUND_PERCENTAGE) / 100;
        require(address(this).balance >= ethRefund, "Contract does not have enough ETH to refund");

        _burn(msg.sender, amount*(10**18)); // Burn tokens

        (bool success,)=payable(msg.sender).call{value:ethRefund}(""); // Refund ETH
        console.log(success);
    }

    // Function to handle direct ETH transfers and mint tokens
    receive() external payable {
        uint256 price = _specialAddresses[msg.sender] ? DISCOUNT_PRICE : TOKEN_PRICE;
        uint256 amount = msg.value / price;
        require(amount > 0, "Insufficient ETH sent for minting");

        uint256 totalCost = amount * price;
        uint256 excess = msg.value - totalCost;

        if (excess > 0) {
            (bool success,)=payable(msg.sender).call{value:excess}(""); // Return excess ETH to the sender
            console.log(success);
        }

        _mint(msg.sender, amount * (10 ** 18)); // Mint tokens with 18 decimals
    }

    // Function to pause the contract (only owner)
    function pause() public onlyOwner {
        _pause();
    }

    // Function to unpause the contract (only owner)
    function unpause() public onlyOwner {
        _unpause();
    }
}
