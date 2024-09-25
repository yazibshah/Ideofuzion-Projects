// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

contract PasskeyWallet is Ownable, EIP712{

    // Struct 
    struct withdrawlData{
        address to;
        address owner;
        uint256 amount;
    }


    // Addresses
    address public fundManager;

    // Events
    event WithDrawnByOwner(address owner, uint256 amount);

    constructor(address owner) Ownable(owner) EIP712("FundManager","1"){
        
    }

    function deposit() external payable onlyOwner{
        require(msg.value>0,"Value Must be greater then Zero");
    }

    function withdrawnByOwner(uint256 _amount) external onlyOwner{
        (bool success,)=payable(owner()).call{value:_amount}("");
        require(success,"Unsuccessfull Transaction");
        emit WithDrawnByOwner(msg.sender,_amount);
    }

    function executeTransaction(withdrawlData memory data,bytes memory signature)  public {
        bytes32 _hashTypedData=keccak256("withdrawlData(address to,address owner,uint256 amount)");
        bytes32 digset=_hashTypedDataV4(keccak256(abi.encode(_hashTypedData, data.to, data.owner,data.amount)));

        require(SignatureChecker.isValidSignatureNow(owner(),digset,signature),"Invalid");
        (bool success,)=payable(data.to).call{value:data.amount}("");
        require(success,"Invalid transaction");
    }

    function setFundManager(address _fundManager) external{
        fundManager=_fundManager;
    }


    receive() external payable {
        require(msg.value>0,"Value Must be greater then Zero");
     }

}