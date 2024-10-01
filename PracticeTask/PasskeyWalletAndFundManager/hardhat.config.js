require("@nomicfoundation/hardhat-toolbox");
require('@openzeppelin/hardhat-upgrades');

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.25",
    settings: {
      optimizer: {
        enabled: true,        // Enable the optimizer
        runs: 200             // Set the number of optimizer runs (default is 200)
      }
    }
  },
  networks: {
    hardhat: {
      // Configuration for local development
    },
    vanar: {
      url: `https://rpc-vanguard.vanarchain.com/`,
      accounts: [`0x79064b7cadf24c1b32c008c4823f35dc5f3c73d9a3e115784eaa0b52f075f41a`],
    },
    // Add other networks if required
  },
};
