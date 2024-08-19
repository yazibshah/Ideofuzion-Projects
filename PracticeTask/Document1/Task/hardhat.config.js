require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

const API_KEY = process.env.API_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.24",
  networks: {
    BSC: {
      url: API_KEY,
      accounts: [PRIVATE_KEY],
    },
  },
};
