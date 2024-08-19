const { ethers } = require("ethers");
require("dotenv").config(); // Load environment variables from .env file

// Import the ABI from the JSON file
const { abi } = require("../artifacts/contracts/EthSigner.sol/SignatureVerifier.json");

// Load environment variables
const API_URL = process.env.API_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const CONTRACT_ADDRESS = process.env.CONTRACT_ADDRESS;

// Connect to the Ethereum network
const provider = new ethers.JsonRpcProvider(API_URL);
const signer = new ethers.Wallet(PRIVATE_KEY, provider);

const contractInstance = new ethers.Contract(CONTRACT_ADDRESS, abi, signer);

const message = "Hello Yazib";

// Hash the message
let hash = ethers.keccak256(ethers.solidityPacked(["string"], [message])); //encoded packed

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
    let boolean = await contractInstance.verify(signer.address, ethHash, r, s, v);
    console.log("Signer Matched?", boolean);
};

signMessage();
