// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./Interfaces/IPriceProvider.sol";
import "@openzeppelin/contracts/utils/math/Math.sol"; // Import Math library

contract LiquidityPool is Ownable {
    using Math for uint256; // Use Math library for uint256 operations

    IPriceProvider public priceProvider;

    // Mappings
    mapping(address => mapping(address => uint256)) public priceFeeds;
    mapping(address => uint8) public tokenDecimals;
    mapping(address => mapping(address => uint256)) public userTokenBalance;
    mapping(address => mapping(address => bool)) public allowedTokens; // Track allowed tokens
    mapping(address => bool) public allowToken;
    mapping(address => uint256) public priceFeedsInUsd;

    address[] private tokenAddresses;

    // Custom Errors
    error TokenNotAllowed(address token);
    error TokenTransferFailed(address token, address from, address to, uint256 amount);

    // Events
    event LiquidityAdded(address liquidityProvider, address token, uint256 amount);
    event LiquidityRemoved(address liquidityProvider, address token, uint256 amount);

    constructor(address _priceProvider, address _owner) Ownable(_owner) {
        // Price Provider Contract
        priceProvider = IPriceProvider(_priceProvider);
    }

    function addToken(address fromToken, address toToken, address priceAddress) external onlyOwner {
        tokenAddresses.push(fromToken);
        priceFeeds[fromToken][toToken] = priceProvider.getLatestPrice(priceAddress);
        tokenDecimals[fromToken] = IERC20Metadata(fromToken).decimals();
        tokenDecimals[toToken] = IERC20Metadata(toToken).decimals();
        allowToken[fromToken] = true;
        allowToken[toToken] = true;
    }

    function addLiquidity(address token, uint256 amount) external {
        require(allowToken[token], "Token not allowed"); // Check if the token is allowed

        bool success = IERC20(token).transferFrom(msg.sender, address(this), amount);
        if (!success) {
            revert TokenTransferFailed(token, msg.sender, address(this), amount);
        }

        // SafeMath addition using Math library
        (, uint256 newBalance) = userTokenBalance[msg.sender][token].tryAdd(amount);
        userTokenBalance[msg.sender][token] = newBalance;

        emit LiquidityAdded(msg.sender, token, amount);
    }

    function removeLiquidity(address token, uint256 amount) external {
        require(userTokenBalance[msg.sender][token] >= amount, "Insufficient liquidity");

        // SafeMath subtraction using Math library
        (, uint256 newBalance) = userTokenBalance[msg.sender][token].trySub(amount);
        userTokenBalance[msg.sender][token] = newBalance;

        bool success = IERC20(token).transfer(msg.sender, amount);
        if (!success) {
            revert TokenTransferFailed(token, address(this), msg.sender, amount);
        }

        emit LiquidityRemoved(msg.sender, token, amount);
    }

    // Helper functions for DEX contract to update balances
    function reduceUserTokenBalance(address user, address token, uint256 amount) external onlyOwner {
        require(userTokenBalance[user][token] >= amount, "Insufficient balance");

        // SafeMath subtraction using Math library
        (, uint256 newBalance) = userTokenBalance[user][token].trySub(amount);
        userTokenBalance[user][token] = newBalance;
    }

    function increaseUserTokenBalance(address user, address token, uint256 amount) external onlyOwner {
        // SafeMath addition using Math library
        (, uint256 newBalance) = userTokenBalance[user][token].tryAdd(amount);
        userTokenBalance[user][token] = newBalance;
    }

    function convertValue(address fromToken, address toToken) public view returns (uint256) {
        uint256 tokenPrice = priceFeeds[fromToken][toToken];
        return (userTokenBalance[msg.sender][fromToken] / (10 ** tokenDecimals[fromToken])) * tokenPrice;
    }

    function priceSetInUsd(address token, address priceAddress) public onlyOwner returns (uint256) {
        priceFeedsInUsd[token] = priceProvider.getLatestPrice(priceAddress);
        return priceFeedsInUsd[token];
    }

    function convertToUSD(address token) public view returns (uint256) {
        uint256 tokenPrice = priceFeedsInUsd[token];
        return (userTokenBalance[msg.sender][token] / (10 ** tokenDecimals[token])) * tokenPrice;
    }
}
