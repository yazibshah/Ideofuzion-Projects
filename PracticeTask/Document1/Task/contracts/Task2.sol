// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

contract ChallengeTwo is Ownable {
    using Math for uint256; // Use SafeMath for uint256 to prevent overflow

    uint256 public counter;

    constructor() Ownable(msg.sender){
        counter = 2;
    }

    // Function to increment the counter by 1
    function incrementCounter() public onlyOwner returns(bool){
        (bool check,uint256 _counter) = counter.tryAdd(1);
        if(check) {
            counter=_counter;
        }
        return check;

    }
}
