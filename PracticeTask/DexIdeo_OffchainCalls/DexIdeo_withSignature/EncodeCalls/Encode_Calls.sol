// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
// import "../Swapping/Swap.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";
contract  EncodeCalls is Ownable {

    address public targetContract;
    constructor() Ownable(msg.sender){
        
    }

    function callOwnerShip(address newOwner) public onlyOwner {
        bytes4 func=bytes4(keccak256("transferOwnership(address)"));
        bytes memory callAddtokenFunc=abi.encodeWithSelector(func,newOwner);
        (bool success,)=targetContract.call(callAddtokenFunc);
        console.log(success);
        
    }

    function callAddtoken(address tokenAddress , address PriceAddress) public onlyOwner {
        bytes memory callAddtokenFunc=abi.encodeWithSignature("addToken(address,address)",tokenAddress,PriceAddress);
        (bool success,)=targetContract.call(callAddtokenFunc);
        console.log(success);
        
    }
    
    function callgetLatestPrice(address latestPrice) public onlyOwner {
        bytes memory callAddtokenFunc=abi.encodeWithSignature("getLatestPrice(address)",latestPrice);
        (bool success,bytes memory data)=targetContract.call(callAddtokenFunc);
        console.log(success);
        console.logBytes(data);
    }

      function callWithdrawBNB(address recipient, uint256 amount) public {
        // Encode the function signature and arguments
        bytes memory callData = abi.encodeWithSignature("withdrawBNB(address,uint256)", recipient, amount);

        // Call the target contract with the encoded data
        (bool success, ) = targetContract.call(callData);
        require(success, "Call to withdrawBNB failed");
    }

    function update(address _targetContract) public onlyOwner {
        targetContract=_targetContract;
    }



    receive() external payable { }


}
