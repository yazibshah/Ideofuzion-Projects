const { ethers } = require("ethers");

// Connect to the Ethereum network (you can use a provider like Infura or a local blockchain)
const provider = new ethers.providers.JsonRpcProvider('http://localhost:8545');

// Create a wallet or use an existing one
const privateKey = 'your-private-key';
const wallet = new ethers.Wallet(privateKey, provider);

// The message to sign
const message = "Hello, this is a test message";

// Get the message hash
const messageHash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(message));

// Sign the message
wallet.signMessage(ethers.utils.arrayify(messageHash)).then((signature) => {
    console.log("Signature:", signature);
    // You can now send the signature to the smart contract for verification
}).catch((error) => {
    console.error("Error signing the message:", error);
});
