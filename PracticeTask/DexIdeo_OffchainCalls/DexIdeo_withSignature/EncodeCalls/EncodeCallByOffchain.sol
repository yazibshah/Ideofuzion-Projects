// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract EncodeCalls is Ownable {

    address public targetContract;

    constructor() Ownable(msg.sender) { }

    function callAddToken(bytes memory callData) public onlyOwner {
        (bool success,) = targetContract.call(callData);
        require(success, "Call to addToken failed");
    }

    function updateTargetContract(address _targetContract) public onlyOwner {
        targetContract = _targetContract;
    }

    receive() external payable { }
}
