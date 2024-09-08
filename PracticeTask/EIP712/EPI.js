const { ethers } = require("ethers");

// Connect to your Ethereum provider (MetaMask or other wallet)
const provider = new ethers.JsonRpcProvider("https://bsc-testnet-dataseed.bnbchain.org/");

// Get the signer (e.g., MetaMask account)
const signer = new ethers.Wallet("0x79064b7cadf24c1b32c008c4823f35dc5f3c73d9a3e115784eaa0b52f075f41a")

// Define the domain for EIP-712
const domain = {
  name: "EIP712Example",
  version: "1",
  chainId: 97,  // Mainnet chainId
  verifyingContract: "0xBc86c8D4F1bCDaDa54C474B1a6186fbA626567A7",  // Contract address
};

// Define the types for the EIP-712 data
const types = {
  Greeting: [
    { name: "message", type: "string" },
    { name: "timestamp", type: "uint256" }
  ],
};

// Define the actual message to sign
const message = {
  message: "Hello EIP-712",
  timestamp: 1682098399,  // Example timestamp
};

// Sign the typed data (EIP-712 signature)
async function signTypedData() {
  const signature = await signer.signTypedData(domain, types, message);
  console.log("Signature: ", signature);

  console.log(signer.address);
}

signTypedData();
