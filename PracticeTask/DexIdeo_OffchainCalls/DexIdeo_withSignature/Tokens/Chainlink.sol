// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Token: Chainlink (LINK) with 6 decimals
contract Chainlink is ERC20 {
    constructor() ERC20("Chainlink", "LINK") {
        _mint(msg.sender, 10000 * 10 ** decimals());  // 6 decimals
    }

    function decimals() public view virtual override returns (uint8) {
        return 6;
    }
}
