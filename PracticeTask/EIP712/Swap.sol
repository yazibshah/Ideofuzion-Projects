// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "../Interfaces/IPriceProvider.sol";
import "hardhat/console.sol";

error TokenTransferFailed(address token, address from, address to, uint256 amount);
error InvestmentBelowMinimum(uint256 investmentAmount);
error UnknownToken(address token);


contract TokenSwap is Ownable {
    // Token to price feed mapping
    mapping(address => uint256) public priceFeeds;
    mapping(address => uint8) public tokenDecimals;

    // Price provider contract
    IPriceProvider public priceProvider;

    // Minimum investment in USD (scaled to 18 decimals)
    uint256 public constant MIN_INVESTMENT_USD = 2 * (10**18); // $2 scaled to 18 decimals

    constructor(address _priceProvider,address _owner) Ownable(_owner) {
        priceProvider = IPriceProvider(_priceProvider);
    }

    // Add a new token with its price feed and decimal
    function addToken(address token, address priceAddress) external onlyOwner {
        priceFeeds[token] = priceProvider.getLatestPrice(priceAddress);
        tokenDecimals[token] = IERC20Metadata(token).decimals();
    }

    // Function to get the latest price from Chainlink
    function getLatestPrice(address priceAddress) public view returns (uint256) {
        return priceProvider.getLatestPrice(priceAddress);
    }

    // Convert token amount to USD based on price feeds
    function convertToUSD(address token, uint256 amount) public view returns (uint256) {
        uint256 tokenPrice = priceFeeds[token];
        return ((amount/ (10 ** tokenDecimals[token]) * tokenPrice));
    }

    function swap(
        address fromToken,
        address toToken,
        uint256 amount
    ) external {
    require(amount > 0, "Amount must be greater than zero");

    // Step 1: Convert the 'fromToken' amount to its equivalent value in USD
    uint256 investmentInUSD = convertToUSD(fromToken, amount); //busd price 18 decimals
    console.log(investmentInUSD);

    if (investmentInUSD < MIN_INVESTMENT_USD) {
        revert InvestmentBelowMinimum(investmentInUSD);
    }

    // Step 2: Automatically calculate the amount of 'toToken' the user should receive based on the investment in USD
    uint256 calculatedAmountToReceive = (investmentInUSD * (10 ** tokenDecimals[toToken])) / priceFeeds[toToken];
    console.log(investmentInUSD);

    // Step 3: If the user provided an expected amount, ensure the calculated amount matches the expected amount
    // if (expectedAmountToReceive > 0) {
    //     require(calculatedAmountToReceive == expectedAmountToReceive, "Calculated amount does not match expected amount");
    // }

    // Step 4: Transfer the 'fromToken' from the user to the contract
    bool success = IERC20(fromToken).transferFrom(msg.sender, address(this), amount);
    console.log(investmentInUSD);
    if (!success) {
        revert TokenTransferFailed(fromToken, msg.sender, address(this), amount);
    }

    // Step 5: Transfer the 'toToken' from the contract to the user
    success = IERC20(toToken).transfer(msg.sender, calculatedAmountToReceive);
    console.log(investmentInUSD);
    if (!success) {
        revert TokenTransferFailed(toToken, address(this), msg.sender, calculatedAmountToReceive);
    }
    }

    function provideAllownce(address tokenAddress, address to ,uint256 value) external returns(bool){
        bool confirm = IERC20(tokenAddress).approve(to,value); 
        return confirm;
    }

    function provideTokenToContract(address tokenAddress,uint256 value) external returns(bool){
        bool confirm = IERC20(tokenAddress).transfer(address(this),value); 
        return confirm;
        
    }

    function tokenBalance(address tokenAddress) external view returns(uint256){
         uint256 balance = IERC20(tokenAddress).balanceOf(address(this)); 
        return balance;
    }



    // Allow the owner to withdraw tokens from the contract
    function withdrawTokens(address token, uint256 amount, address to) external onlyOwner {
        uint256 contractBalance = IERC20(token).balanceOf(address(this));
        require(contractBalance >= amount, "Insufficient token balance in contract");
        bool success = IERC20(token).transfer(to, amount);
        if (!success) {
            revert TokenTransferFailed(token, address(this), to, amount);
        }
    }

    // Withdraw collected BNB from the contract
    function withdrawBNB(address _address, uint256 _amount) external onlyOwner returns (bool) {
        (bool success, ) = payable(_address).call{value: _amount}("");
        return success;
    }

    receive() external payable { }
}

