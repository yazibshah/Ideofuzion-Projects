// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Token: Ripple (XRP) with 8 decimals
contract Ripple is ERC20 {
    constructor() ERC20("Ripple", "XRP") {
        _mint(msg.sender, 10000 * 10 ** decimals());  // 8 decimals
    }

    function decimals() public view virtual override returns (uint8) {
        return 8;
    }
}
