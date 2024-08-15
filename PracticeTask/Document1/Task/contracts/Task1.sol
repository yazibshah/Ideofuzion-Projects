// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.2;


import "@openzeppelin/contracts/access/Ownable.sol";
// Document 1 Task 1
contract Task1 is Ownable{
    struct UserData {
        address dataOwner;
        string name;
        uint256 age;
        string designation;
    }
    mapping(address user => UserData storeData) private storeAndRetreiveValue;


    constructor() Ownable(msg.sender){}

    function storeData(string memory _name, uint256 _age, string memory _designation) public {
        storeAndRetreiveValue[msg.sender] =UserData(msg.sender,_name,_age,_designation);
    }
    function retrieveData(address _user) public view  returns(string memory userName , uint256 userAge , string memory userDesignation){
        require(msg.sender==storeAndRetreiveValue[_user].dataOwner || msg.sender == owner(),"This Data is not yours");
        UserData memory checkData=storeAndRetreiveValue[_user];
        userName=checkData.name;
        userAge=checkData.age;
        userDesignation=checkData.designation;

        return(userName, userAge , userDesignation);

    }
}