// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "hardhat/console.sol";

contract EIP712Example is EIP712 {
    using ECDSA for bytes32;

    // Struct for data to sign
    struct Greeting {
        string message;
        uint256 timestamp;
    }

    // Type hash for Greeting struct
    bytes32 private constant _GREETING_TYPEHASH = keccak256("Greeting(string message,uint256 timestamp)");

    // Constructor to initialize EIP712 with name and version
    constructor() EIP712("EIP712Example", "1") {}

    // Function to hash the typed data using EIP712
    function _hashTypedData(Greeting memory greeting) internal view returns (bytes32) {
        return _hashTypedDataV4(keccak256(abi.encode(
            _GREETING_TYPEHASH,
            keccak256(bytes(greeting.message)),
            greeting.timestamp
        )));
    }

    // Function to verify the signature using EIP712 standard
    function verifySignature(address signer,Greeting memory greeting,bytes memory signature) public view returns (bool) {
        bytes32 digest = _hashTypedData(greeting);
        
        return SignatureChecker.isValidSignatureNow(signer, digest, signature);
    }
}
