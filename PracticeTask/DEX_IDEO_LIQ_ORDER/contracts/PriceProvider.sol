// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract PriceProvider {
    
    // Marking the function as view so it doesn't alter the blockchain state
    function getLatestPrice(address _PriceFeedContract) public view returns(uint256) {
        // Initialize the price feed contract
        AggregatorV3Interface priceFeed = AggregatorV3Interface(_PriceFeedContract);
        
        // Get the latest price from the Chainlink Oracle
        (
            , 
            int256 price,
            ,
            ,
        ) = priceFeed.latestRoundData();
        
        // Return the price converted to 18 decimals
        return uint256(price) * (10**10);
    }
}