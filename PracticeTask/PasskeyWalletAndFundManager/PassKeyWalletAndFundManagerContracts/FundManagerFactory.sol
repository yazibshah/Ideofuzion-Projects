// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "./Interface/IFundManager.sol";  // Import the FundManager contract
import "./FundManager.sol";

contract FundManagerFactory {
    // Struct to keep track of the deployed FundManager contracts
    struct DeployedFundManager {
        address owner;
        address fundManagerContract;
    }

    // List of all deployed FundManager contracts
    DeployedFundManager[] public fundManagers;

    // Mapping to track all fund managers created by an owner
    mapping(address => address[]) public ownerFundManagers;

    // Event to log when a new FundManager contract is deployed
    event FundManagerDeployed(address indexed owner, address indexed fundManager);

    // Function for any user to deploy their own FundManager contract
    function deployFundManager() external {
        // Create a new instance of the FundManager contract
        FundManager fundManager = new FundManager();

        // Store the deployed contract details
        fundManagers.push(DeployedFundManager({
            owner: msg.sender,
            fundManagerContract: address(fundManager)
        }));

        // Track the contracts created by the sender
        ownerFundManagers[msg.sender].push(address(fundManager));

        // Emit an event for the newly deployed contract
        emit FundManagerDeployed(msg.sender, address(fundManager));
    }

    // Function to get the total number of deployed FundManager contracts
    function getDeployedFundManagersCount() external view returns (uint256) {
        return fundManagers.length;
    }

    // Function to get all FundManager contracts deployed by a particular owner
    function getOwnerFundManagers(address owner) external view returns (address[] memory) {
        return ownerFundManagers[owner];
    }
}
