// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EncodeCalls is Ownable {
    using SignatureChecker for bytes32;

    address public targetContract;

    constructor() Ownable(msg.sender) {}

    
    function callAddTokenWithSignature(
        bytes memory callData,
        bytes32  dataHash,
        bytes memory signature
    ) public {      

        // Verify the signature using SignatureChecker
        require(
            SignatureChecker.isValidSignatureNow(owner(), dataHash, signature),
            "Invalid signature"
        );

        // Call the addToken function in the target contract
        // bytes memory callData = abi.encodeWithSignature("callAddToken(address,address,bytes)", token, priceFeed);
        (bool success, ) = targetContract.call(callData);
        require(success, "Call to addToken failed");
    }

    /**
     * @dev Updates the target contract address.
     * @param _targetContract The address of the new target contract.
     */
    function updateTargetContract(address _targetContract) public onlyOwner {
        require(_targetContract != address(0), "Invalid target contract address");
        targetContract = _targetContract;
    }

    /**
     * @dev Allows the contract to receive ETH.
     */
    receive() external payable {}
}
