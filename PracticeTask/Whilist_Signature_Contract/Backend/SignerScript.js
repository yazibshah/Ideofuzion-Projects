const { ethers } = require("ethers");
require("dotenv").config(); // Load environment variables from .env file

// Import the ABI from the JSON file
const { abi } = require("../artifacts/contracts/EthSigner.sol/SignatureVerifier.json");

// Load environment variables
const API_URL = "https://bsc-testnet-dataseed.bnbchain.org/";
const PRIVATE_KEY = "0x79064b7cadf24c1b32c008c4823f35dc5f3c73d9a3e115784eaa0b52f075f41a";
const CONTRACT_ADDRESS = "0x9AC3318571dFE25A2ABDcF8668C23452980C6684";

// Connect to the Ethereum network
const provider = new ethers.JsonRpcProvider(API_URL);
const signer = new ethers.Wallet(PRIVATE_KEY, provider);

const contractInstance = new ethers.Contract(CONTRACT_ADDRESS, abi, signer);

const message = "0xd64FC754e10dE60651Ffd6C618c99A08269fb4D5";

// Hash the message
let hash = ethers.keccak256(ethers.solidityPacked(["address"], [message])); //encoded packed

const signMessage = async () => {
    // Sign the hash
    const signature = await signer.signMessage(ethers.getBytes(hash));

    // Create the Ethereum signed message hash
    const ethHash = ethers.keccak256(
        ethers.solidityPacked(
            ["string", "bytes32"], 
            ["\x19Ethereum Signed Message:\n32", hash]
        )
    );

    console.log("Signer Address:", signer.address);
    
    // Extract v, r, s from the signature
    const { v, r, s } = ethers.Signature.from(signature);

    // Verify the signature with the contract
    let boolean = await contractInstance.verify(signer, ethHash, r, s, v);
    console.log("Signer Matched?", boolean);
};

signMessage();
