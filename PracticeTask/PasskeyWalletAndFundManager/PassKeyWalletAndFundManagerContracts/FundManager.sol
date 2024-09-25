// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./Interface/IFundManager.sol";

contract FundManager is Ownable(tx.origin), ReentrancyGuard ,IFundManager{
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeMath for uint256;

    EnumerableSet.AddressSet private investors;

    mapping(address => uint256) public deposits;   // Tracks deposits per user
    mapping(address => bool) public hasDeposited;  // Track if an address has deposited

    struct Strategy {
        uint256 investPercentage;
        uint256 withdrawPercentage;
        uint256 dcaPercentage;
    }

    // User-defined strategy mapping
    mapping(address => Strategy) public userStrategies;

    // Deposit function
    function deposit() external payable {
        require(msg.value > 0, "Deposit must be greater than 0");

        // Add to user's deposit balance
        deposits[msg.sender] = deposits[msg.sender].add(msg.value);

        // Add to the investor set if not already present
        if (!hasDeposited[msg.sender]) {
            investors.add(msg.sender);
            hasDeposited[msg.sender] = true;
        }

        emit Deposited(msg.sender, msg.value);
    }

    // User-defined strategy
    function setStrategy(uint256 investPercentage, uint256 withdrawPercentage, uint256 dcaPercentage) external {
        require(investPercentage.add(withdrawPercentage).add(dcaPercentage) == 100, "Percentages must sum to 100");
        
        userStrategies[msg.sender] = Strategy(investPercentage, withdrawPercentage, dcaPercentage);

        emit StrategyUpdated(msg.sender, investPercentage, withdrawPercentage, dcaPercentage);
    }

    // Withdraw function for users
    function withdraw(uint256 amount) external nonReentrant {
        require(deposits[msg.sender] >= amount, "Insufficient balance");

        // Deduct from user's deposit
        deposits[msg.sender] = deposits[msg.sender].sub(amount);

        // Transfer the requested amount back to the user
        (bool success,) = payable(msg.sender).call{value: amount}("");
        require(success, "Withdrawal failed");

        emit Withdrawn(msg.sender, amount, success);
    }

    // Function to distribute funds based on user strategies
    // Function to distribute funds based on user strategies
    function distribute() external onlyOwner {
        uint256 totalFunds = address(this).balance;
        require(totalFunds > 0, "No funds to distribute");

        uint256 totalDeposits = getTotalDeposits();
        require(totalDeposits > 0, "Total deposits must be greater than 0");

        // Iterate through each investor
        for (uint256 i = 0; i < investors.length(); i++) {
            address user = investors.at(i);
            uint256 userDeposit = deposits[user];

            // Calculate the user's share of the total funds
            uint256 userShare = userDeposit.mul(totalFunds).div(totalDeposits);

            // Get user's strategy
            Strategy memory strategy = userStrategies[user];

            // Calculate amounts based on the user's strategy
            uint256 investAmount = userShare.mul(strategy.investPercentage).div(100);
            uint256 withdrawAmount = userShare.mul(strategy.withdrawPercentage).div(100);
            uint256 dcaAmount = userShare.mul(strategy.dcaPercentage).div(100);

            // Transfer the calculated amount to the user
            uint256 totalAmount = investAmount.add(withdrawAmount).add(dcaAmount);

            (bool success,) = payable(user).call{value: totalAmount}("");
            require(success, "Distribution transfer failed");

            emit Distributed(investAmount, withdrawAmount, dcaAmount);
        }      
        
        
    }

    // Function to return the number of investors
    function getInvestorCount() external view returns (uint256) {
        return investors.length();
    }

    // Function to return the total amount of all user deposits
    function getTotalDeposits() public view returns (uint256) {
        uint256 totalDeposits = 0;
        for (uint256 i = 0; i < investors.length(); i++) {
            totalDeposits = totalDeposits.add(deposits[investors.at(i)]);
        }
        return totalDeposits;
    }

    // Function to withdraw the remaining funds (optional cleanup)
    function withdrawRemaining() external onlyOwner nonReentrant {
        uint256 remainingFunds = address(this).balance;
        require(remainingFunds > 0, "No remaining funds to withdraw");

        (bool success,) = payable(owner()).call{value: remainingFunds}("");
        require(success, "Owner withdrawal failed");

        emit WithdrawByOwner(owner(), remainingFunds, success);
    }

    receive() external payable { }
}
