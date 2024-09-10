// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract EIP712Example is EIP712, Ownable {
    using ECDSA for bytes32;

    struct tokenData {
        address tokenAddress;
        address priceFeed;
    }

    bytes32 private constant _GREETING_TYPEHASH = keccak256("tokenData(address tokenAddress,address priceFeed)");

    address public tokenSwapAddress;

    constructor() EIP712("DexIdeo", "1") Ownable(msg.sender) {}

    function _hashTypedData(tokenData memory data) internal view returns (bytes32) {
        return _hashTypedDataV4(keccak256(abi.encode(_GREETING_TYPEHASH, data.tokenAddress, data.priceFeed)));
    }

    function verifyAndAddToken(tokenData memory data, bytes memory signature) public returns (bool) {
        bytes32 digest = _hashTypedData(data);

        if (SignatureChecker.isValidSignatureNow(owner(), digest, signature)) {
            console.log("Signature verified. Proceeding with addToken.");
            console.log("Target address: ", tokenSwapAddress);

            // bytes memory dataToCall = abi.encodeWithSignature("addToken(address,address)", data.tokenAddress, data.priceFeed);
            (bool success,) = tokenSwapAddress.call(abi.encodeWithSignature("addToken(address,address)", data.tokenAddress, data.priceFeed));
            if (!success) {
                revert("Delegatecall to addToken failed");
            }

            return true;
        } else {
            console.log("Signature verification failed.");
            return false;
        }
    }

    function TargetAddress(address _tokenSwapAddress) public onlyOwner returns (address) {
        tokenSwapAddress = _tokenSwapAddress;
        return tokenSwapAddress;
    }
}
