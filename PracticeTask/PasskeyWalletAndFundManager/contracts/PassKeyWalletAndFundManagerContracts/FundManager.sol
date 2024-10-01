/* // SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/Math.sol"; // Import Math.sol
import "./Interface/IFundManager.sol";

contract FundManager is Ownable(tx.origin), ReentrancyGuard, IFundManager {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Math for uint256; // Use Math library functions

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

        // Add to user's deposit balance using tryAdd
        (bool success, uint256 newDeposit) = deposits[msg.sender].tryAdd(msg.value);
        require(success, "Addition overflow");

        deposits[msg.sender] = newDeposit;

        // Add to the investor set if not already present
        if (!hasDeposited[msg.sender]) {
            investors.add(msg.sender);
            hasDeposited[msg.sender] = true;
        }

        emit Deposited(msg.sender, msg.value);
    }

    // User-defined strategy
    function setStrategy(uint256 investPercentage, uint256 withdrawPercentage, uint256 dcaPercentage) external {
        // Ensure percentages sum to 100 using Math.sol functions
        uint256 totalPercentage = investPercentage+(withdrawPercentage)+(dcaPercentage);
        require(totalPercentage == 100, "Percentages must sum to 100");
        
        userStrategies[msg.sender] = Strategy(investPercentage, withdrawPercentage, dcaPercentage);

        emit StrategyUpdated(msg.sender, investPercentage, withdrawPercentage, dcaPercentage);
    }

    // Withdraw function for users
    function withdraw(uint256 amount) external nonReentrant {
        require(deposits[msg.sender] >= amount, "Insufficient balance");

        // Deduct from user's deposit using trySub
        (bool success, uint256 newDeposit) = deposits[msg.sender].trySub(amount);
        require(success, "Subtraction underflow");

        deposits[msg.sender] = newDeposit;

        // Transfer the requested amount back to the user
        (bool transferSuccess,) = payable(msg.sender).call{value: amount}("");
        require(transferSuccess, "Withdrawal failed");

        emit Withdrawn(msg.sender, amount, transferSuccess);
    }

    // Function to distribute funds based on user strategies
    function distribute() external onlyOwner {
    uint256 totalFunds = address(this).balance;
    require(totalFunds > 0, "No funds to distribute");

    uint256 totalDeposits = getTotalDeposits();
    require(totalDeposits > 0, "Total deposits must be greater than 0");

    for (uint256 i = 0; i < investors.length(); i++) {
        address user = investors.at(i);
        uint256 userDeposit = deposits[user];

        // Calculate the user's share of the total funds
        uint256 shareAmount = userDeposit * totalFunds / totalDeposits;

        Strategy memory strategy = userStrategies[user];

        uint256 investAmount = (shareAmount * strategy.investPercentage) / 100;
        uint256 withdrawAmount = (shareAmount * strategy.withdrawPercentage) / 100;
        uint256 dcaAmount = (shareAmount * strategy.dcaPercentage) / 100;

        uint256 finalAmount = investAmount + withdrawAmount + dcaAmount;

        // Transfer the calculated amount to the user
        (bool transferSuccess,) = payable(user).call{value: finalAmount}("");
        require(transferSuccess, "Distribution transfer failed");

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
            (bool success, uint256 deposit) = totalDeposits.tryAdd(deposits[investors.at(i)]);
            require(success, "Addition overflow");
            totalDeposits = deposit;
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
 */