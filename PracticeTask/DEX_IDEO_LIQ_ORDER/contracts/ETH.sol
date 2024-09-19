// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Token: Bitcoin (BTC) with 18 decimals
contract ETH is ERC20 {
    constructor() ERC20("Ethereum", "ETH") {
        _mint(msg.sender, 10000 * 10 ** decimals());  // 18 decimals
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
}