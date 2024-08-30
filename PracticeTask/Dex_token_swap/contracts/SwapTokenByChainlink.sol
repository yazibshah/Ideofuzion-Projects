// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./TokenA.sol";
import "./TokenB.sol";

error TypeNotMatched();
error TokenTransferFailed(address token, address from, address to, uint256 amount);
error InvestmentBelowMinimum(uint256 investmentAmount);

contract TokenSwap is Ownable {
    IERC20 public tokenA;
    IERC20 public tokenB;
    AggregatorV3Interface public priceFeedA; // Chainlink price feed for Token A (BUSD)
    AggregatorV3Interface public priceFeedB; // Chainlink price feed for Token B (USD)

    // Minimum investment in USD (scaled to 18 decimals)
    uint256 public constant MIN_INVESTMENT_USD = 20 * (10**18); // $20 scaled to 18 decimals

    enum SwapType { AforB, BforA }

    constructor(
        address _tokenA, 
        address _tokenB, 
        address _priceFeedA, // Static address for Chainlink price feed A (BUSD)
        address _priceFeedB  // Static address for Chainlink price feed B (USD)
    ) Ownable(msg.sender) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        priceFeedA = AggregatorV3Interface(_priceFeedA); // Initialize the price feed for Token A (BUSD)
        priceFeedB = AggregatorV3Interface(_priceFeedB); // Initialize the price feed for Token B (USD)
    }

    function getLatestPriceA() public view returns (uint256) {
        (
            , 
            int256 price,
            ,
            ,
        ) = priceFeedA.latestRoundData();
        return uint256(price) * (10**10); // Convert price to 18 decimals
    }

    function getLatestPriceB() public view returns (uint256) {
        (
            , 
            int256 price,
            ,
            ,
        ) = priceFeedB.latestRoundData();
        return uint256(price) * (10**10); // Convert price to 18 decimals
    }

    function swap(uint256 amount, SwapType swapType) external {
        uint256 priceInUSD_A = getLatestPriceA(); // Price of Token A in USD
        uint256 priceInUSD_B = getLatestPriceB(); // Price of Token B in USD

        uint256 investmentInUSD;
        if (swapType == SwapType.AforB) {
            // Calculate how much USD the user is investing
            investmentInUSD = (amount * priceInUSD_A) / (10**18);
            // Enforce minimum investment check
            if (investmentInUSD < MIN_INVESTMENT_USD) {
                revert InvestmentBelowMinimum(investmentInUSD);
            }

            // Convert amount of Token A to equivalent amount of Token B
            uint256 amountB = ((amount * priceInUSD_A) / priceInUSD_B)/(10**10);
            tokenA.transferFrom(msg.sender, address(this), amount);
            tokenB.transfer(msg.sender, amountB);
        } else {
            // Calculate how much USD the user is investing
            investmentInUSD = ((amount * priceInUSD_B) / priceInUSD_A)*(10**10);
            // Enforce minimum investment check
            if (investmentInUSD < MIN_INVESTMENT_USD) {
                revert InvestmentBelowMinimum(investmentInUSD);
            }

            // Convert amount of Token B to equivalent amount of Token A
            uint256 amountA = ((amount * priceInUSD_B) / priceInUSD_A)*(10**10);
            tokenB.transferFrom(msg.sender, address(this), amount);
            tokenA.transfer(msg.sender, amountA);
        }
    }

    function getTokenABalance() external view onlyOwner returns (uint256) {
        return tokenA.balanceOf(address(this));
    }

    function getTokenBBalance() external view onlyOwner returns (uint256) {
        return tokenB.balanceOf(address(this));
    }

    // Withdraw function for Token A
    function withdrawTokenA(uint256 amount, address to) external onlyOwner {
        uint256 contractBalance = tokenA.balanceOf(address(this));
        require(contractBalance >= amount, "Insufficient TokenA balance in contract");
        bool success = tokenA.transfer(to, amount);
        if (!success) {
            revert TokenTransferFailed(address(tokenA), address(this), to, amount);
        }
    }

    // Withdraw function for Token B
    function withdrawTokenB(uint256 amount, address to) external onlyOwner {
        uint256 contractBalance = tokenB.balanceOf(address(this));
        require(contractBalance >= amount, "Insufficient TokenB balance in contract");
        bool success = tokenB.transfer(to, amount);
        if (!success) {
            revert TokenTransferFailed(address(tokenB), address(this), to, amount);
        }
    }
}


// 0x79c92959BcfcF5057BeFF4AE02E70958DcC78743 priceprovider
// 0xa9b84B2E1823Bdcb62a6D58ffc6E6cBb4Acd632e
// 0x34fBDd96d24c937C293615CAD7CF8b7A63ec8DD5
// 0x263Fa487b719252b4A56158f0860b8DA0FBc17a2


// 0xC6F476A161ED874e8c55f2413dB9D751f1F795B9 btc
// 0x7FA4E057131f22971BCc699715834d6FE0c4cea9 ETH
// 0x31eC4d7155A2f12C3ea5eeCdaE31AE1d856eE686 Swap