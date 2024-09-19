// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./LiquidityPool.sol";
import "./Interfaces/IPriceProvider.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

contract OrderBook is Ownable {
    using Math for uint256;  // Use Math library

    LiquidityPool public liquidityPool;
    IPriceProvider public priceOracle;
    uint256 public price = 1e15;

    struct Order {
        address user;
        address fromToken;
        address toToken;
        uint256 amount;
        uint256 priceInToken; 
        bool isBuyOrder;
        bool fulfilled;
    }

    Order[] public orders;

    event OrderPlaced(uint256 orderId, address indexed user, address fromToken, address toToken, uint256 amount, uint256 price, bool isBuyOrder);
    event OrderCanceled(uint256 orderId);
    event OrderMatched(uint256 orderId, address buyer, address seller, uint256 amount, uint256 price);
    
    constructor(address _priceOracle) Ownable() {
        priceOracle = IPriceProvider(_priceOracle);
    }

    // Place a sell order, seller specifies the price in USD
    function placeSellOrder(address fromToken, address toToken, uint256 amount, uint256 priceInToToken) external {
        require(liquidityPool.allowedTokens(fromToken, toToken), "Token not allowed");
        uint256 enoughPrice = liquidityPool.priceFeedsInUsd(toToken);
        require(enoughPrice >= price, "Price must be greater than enough price");

        require(liquidityPool.userTokenBalance(msg.sender, fromToken) >= amount, "Insufficient balance");

        orders.push(Order(msg.sender, fromToken, toToken, amount, priceInToToken, false, false));

        emit OrderPlaced(orders.length - 1, msg.sender, fromToken, toToken, amount, priceInToToken, false);
        matchOrders();
    }

    // Place a buy order where the buyer specifies how much they are willing to spend (in USD)
    function placeBuyOrder(address fromToken, address toToken, uint256 amount, uint256 priceInFromToken) external {
        require(liquidityPool.allowedTokens(fromToken, toToken), "Token not allowed");

        uint256 enoughPrice = liquidityPool.priceFeedsInUsd(fromToken);
        require(enoughPrice >= price, "Price must be greater than enough price");

        orders.push(Order(msg.sender, fromToken, toToken, amount, priceInFromToken, true, false));

        emit OrderPlaced(orders.length - 1, msg.sender, fromToken, toToken, amount, priceInFromToken, true);
        matchOrders();
    }

    // Match orders between buyers and sellers
    function matchOrders() internal {
        for (uint256 i = 0; i < orders.length; i++) {
            if (orders[i].fulfilled || !orders[i].isBuyOrder) continue;

            for (uint256 j = 0; j < orders.length; j++) {
                if (orders[j].fulfilled || orders[j].isBuyOrder) continue;

                // Match based on USD price set by the seller and buyer's offer
                if (
                    orders[i].fromToken == orders[j].toToken &&
                    orders[i].toToken == orders[j].fromToken &&
                    orders[i].priceInToken >= orders[j].priceInToken // Buyer's offer price should be >= seller's price
                ) {
                    uint256 tradeAmount = Math.min(orders[i].amount, orders[j].amount);
                    _executeTrade(i, j, tradeAmount);
                    break;
                }
            }
        }
    }

    function _executeTrade(uint256 buyOrderId, uint256 sellOrderId, uint256 tradeAmount) internal {
        Order storage buyOrder = orders[buyOrderId];
        Order storage sellOrder = orders[sellOrderId];

        // Get the current balance of the buyer and seller
        uint256 sellerBalance = liquidityPool.userTokenBalance(sellOrder.user, sellOrder.fromToken);

        // Ensure that the seller has enough tokens to fulfill the trade
        require(sellerBalance >= tradeAmount, "Insufficient seller balance");

        uint256 totalTokenRequired = Math.mulDiv(tradeAmount, sellOrder.priceInToken, liquidityPool.tokenDecimals(buyOrder.toToken));

        // Check if the buyer has enough token balance
        uint256 buyerTokenBalance = liquidityPool.userTokenBalance(buyOrder.user, buyOrder.fromToken); 
        require(buyerTokenBalance >= totalTokenRequired, "Insufficient balance to buy");

        // Reduce the order amounts
        buyOrder.amount = Math.trySub(buyOrder.amount, tradeAmount).1;
        sellOrder.amount = Math.trySub(sellOrder.amount, tradeAmount).1;

        // Update balance
        liquidityPool.increaseUserTokenBalance(buyOrder.user, buyOrder.toToken, tradeAmount);
        liquidityPool.increaseUserTokenBalance(sellOrder.user, sellOrder.toToken, totalTokenRequired);

        liquidityPool.reduceUserTokenBalance(buyOrder.user, buyOrder.fromToken, totalTokenRequired);
        liquidityPool.reduceUserTokenBalance(sellOrder.user, sellOrder.fromToken, tradeAmount);

        // Mark orders as fulfilled if the amount reaches zero
        if (buyOrder.amount == 0) buyOrder.fulfilled = true;
        if (sellOrder.amount == 0) sellOrder.fulfilled = true;

        emit OrderMatched(buyOrderId, buyOrder.user, sellOrder.user, tradeAmount, sellOrder.priceInToken);
    }

    // Set LiquidityPool
    function setLiquidityPool(address _liquidityPool) external onlyOwner {
        liquidityPool = LiquidityPool(_liquidityPool);
    }

    // Delete Order
    function deleteOrder(uint256 orderId) external {
        require(orderId < orders.length, "Invalid order ID");
        Order storage order = orders[orderId];
        require(order.user == msg.sender, "Only the order creator can delete the order");
        require(!order.fulfilled, "Cannot delete a fulfilled order");

        delete orders[orderId];

        emit OrderCanceled(orderId);
    }
}
