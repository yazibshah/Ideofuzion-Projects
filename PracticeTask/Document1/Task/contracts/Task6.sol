// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AddressHasher {

    // Function to generate a hash of a pair of addresses
    function hashAddresses(address _addr1, address _addr2) public pure returns (bytes32) {
        require(_addr1 != address(0) && _addr2 != address(0), "Invalid address: address cannot be zero");
        return keccak256(abi.encodePacked(_addr1,_addr2));
    }

    function validateHash(address _addr1, address _addr2, bytes32 hash) pure public returns(bool){
        require(hash==keccak256(abi.encodePacked(_addr1,_addr2)),"Data is not matched");
        return true;

    }
}   
