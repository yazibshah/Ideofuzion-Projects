// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";


contract SignatureVerification is Ownable{
    using ECDSA for bytes32;


    mapping (address user => bool checkStatus) public whiteListed;

    event depositAddress(address indexed  user, uint256 amount);

    constructor() Ownable(msg.sender){}
    modifier onlyWhiteListed(){
        require(whiteListed[msg.sender],"not in the list");
        _;
    }


    function whiteListUser(bytes memory signature) external payable {
        bytes32 dataHash= keccak256(abi.encodePacked(msg.sender));
        address signer= dataHash.recover(signature);
        require(signer==owner(),"Ivalid signature");

        // Whitelist the sender
        whiteListed[msg.sender] = true;

    }

    function deposit() external payable onlyWhiteListed{
        require(msg.value>0,"Must send Eth to Deposit");
        emit depositAddress(msg.sender,msg.value);
    }

    function withdraw(uint256 _amount) external onlyOwner returns(bool){
        (bool success,)=payable(owner()).call{value:_amount}("");
        return success;
    }

     function getMessageHash(address user) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(user));
    }


}