// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;


contract TargetCon{
    uint256 public num;
    function myFunc(uint256 _num , string memory str) public  returns(uint256 , string memory){
        num=_num;
        return (num, str);
    } 
}
contract ABISignature{
    function encodeFuncCall(address target,uint256 num, string memory str) public  returns(bytes memory){
        bytes memory data= abi.encodeWithSignature("myFunc(uint256,string)", num, str);
        (bool success, bytes memory result)=target.call(data);
         require(success, "Function call failed");
         return result;
    }
}