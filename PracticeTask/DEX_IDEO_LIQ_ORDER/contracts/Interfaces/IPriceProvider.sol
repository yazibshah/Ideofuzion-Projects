// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

interface IPriceProvider {    
    // Marking the function as view so it doesn't alter the blockchain state
    function getLatestPrice(address _PriceFeedContract) external view returns(uint256);
}