// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

interface IFundManager {
    // Events
    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount, bool success);
    event Distributed(uint256 investAmount, uint256 withdrawAmount, uint256 dcaAmount);
    event StrategyUpdated(address indexed user, uint256 investPercentage, uint256 withdrawPercentage, uint256 dcaPercentage);
    event WithdrawByOwner(address indexed owner, uint256 remainingFunds, bool success);

    // User functions
    function deposit() external payable;
    function setStrategy(uint256 investPercentage, uint256 withdrawPercentage, uint256 dcaPercentage) external;
    function withdraw(uint256 amount) external;

    // Owner functions
    function distribute() external;
    function withdrawRemaining() external;

    // View functions
    function getInvestorCount() external view returns (uint256);
    function getTotalDeposits() external view returns (uint256);

    // Fallback function
    receive() external payable;
}
