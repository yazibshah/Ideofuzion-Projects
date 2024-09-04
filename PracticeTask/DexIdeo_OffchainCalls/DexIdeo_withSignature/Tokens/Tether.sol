// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Token: Tether (USDT) with 0 decimals
contract Tether is ERC20 {
    constructor() ERC20("Tether", "USDT") {
        _mint(msg.sender, 10000 * 10 ** decimals());  // 0 decimals
    }

    function decimals() public view virtual override returns (uint8) {
        return 0;
    }
}
