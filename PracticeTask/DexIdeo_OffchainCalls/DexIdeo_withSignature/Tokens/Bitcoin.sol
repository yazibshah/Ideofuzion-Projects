// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Token: Bitcoin (BTC) with 18 decimals
contract Bitcoin is ERC20 {
    constructor() ERC20("Bitcoin", "BTC") {
        _mint(msg.sender, 10000 * 10 ** decimals());  // 18 decimals
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
}
