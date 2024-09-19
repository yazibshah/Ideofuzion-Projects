require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: "0.8.25",
  networks: {
    bscTestnet: {
      url: `https://bsc-testnet-dataseed.bnbchain.org`,
      accounts: ["ac41266bca8c2a4bb1ed52359620928c52af8fffd792b74f1f01a2208b3da099","0231450b09e0d146025f404ce194e6659fd664015498d0108e8723238c53a89a" ] // Replace with your private key
    }
  },
  etherscan: {
    apiKey: process.env.BSCSCAN_API_KEY // Replace with your BscScan API key
  }
};