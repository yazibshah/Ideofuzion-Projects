// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IPriceProvider {
    function getLatestPrice(address priceAddress) external view returns (uint256);
}
