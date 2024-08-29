CustomToken Smart Contract
Overview

CustomToken: is an ERC20-based token implemented using Solidity and OpenZeppelin libraries. The contract introduces several unique features such as a dynamic token minting process based on the user's status (regular or special), a transaction fee mechanism, and support for ETH payments directly to the contract.

Features:

1. Dynamic Pricing: Users can mint tokens by sending ETH directly to the contract. Special addresses receive a discount.
2. Special Addresses: Specific addresses can be marked as "special" to receive discounts on token minting.
3. Transaction Fees: A fee of 1% is deducted from each transfer, which is sent to the contract owner.
4. Manual Minting: The owner can manually mint tokens by calling the mint function.
5. Excess ETH Return: If more ETH than required is sent for minting, the excess is automatically returned to the sender.

Contract Details
    Token Name: CustomToken
    Token Symbol: CTK
    Initial Supply: 10,000 tokens (with 18 decimals)
    Token Price:
    Regular Users: 0.1 ETH per token
    Special Users: 0.075 ETH per token
    Transaction Fee: 1% of the transferred amount

Prerequisites
    Solidity Version: ^0.8.0
    OpenZeppelin Contracts: The contract utilizes the OpenZeppelin library for ERC20 and Ownable functionalities.


Functions
    1. constructor(address owner)
    Description: Initializes the contract, sets the owner, and mints the initial supply of tokens.
    Parameters:
    owner: The address that will own the contract and receive the initial supply.
    2. mint(uint256 amount)
    Description: Mints new tokens to the sender based on the amount of ETH sent.
    Parameters:
    amount: The number of tokens to mint (with 18 decimals).
    Payable: Yes, requires ETH to be sent along with the transaction.
    3. setSpecialAddress(address specialAddress, bool isSpecial)
    Description: Adds or removes an address from the special list.
    Parameters:
    specialAddress: The address to be marked as special or not.
    isSpecial: A boolean indicating whether the address is special (true) or not (false).
    4. isSpecialAddress(address account)
    Description: Checks if an address is marked as special.
    Parameters:
    account: The address to check.
    Returns: A boolean indicating if the address is special.
    5. transfer(address recipient, uint256 amount)
    Description: Transfers tokens from the sender to a recipient, deducting a 1% fee.
    Parameters:
    recipient: The address to receive the tokens.
    amount: The amount of tokens to transfer (with 18 decimals).
    6. transferFrom(address sender, address recipient, uint256 amount)
    Description: Transfers tokens from a specified address to a recipient, deducting a 1% fee.
    Parameters:
    sender: The address to send tokens from.
    recipient: The address to receive the tokens.
    amount: The amount of tokens to transfer (with 18 decimals).
    7. receive() external payable
    Description: Allows the contract to receive ETH and automatically mints tokens based on the sent amount.

    Usage
    Deploying the Contract
    Ensure you have the OpenZeppelin contracts installed.
    Deploy the CustomToken contract, passing the owner's address as an argument.
    Minting Tokens
    Regular Users: Send ETH to the mint function or directly to the contract address to mint tokens at 0.1 ETH per token.
    Special Users: If marked as special, send ETH to the mint function or directly to the contract address to mint tokens at 0.075 ETH per token.
    Transferring Tokens
    Use the transfer or transferFrom functions to transfer tokens between addresses. A 1% fee is automatically deducted and sent to the contract owner.
    
License
This contract is licensed under the MIT License.

