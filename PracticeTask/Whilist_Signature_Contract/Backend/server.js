const { abi } = require("../artifacts/contracts/SignatureVerification.sol/SignatureVerification.json");
require('dotenv').config();
const { ethers } = require('ethers');

// Load environment variables
const provider = new ethers.JsonRpcProvider("https://bsc-testnet-dataseed.bnbchain.org/");
const wallet = new ethers.Wallet("0x79064b7cadf24c1b32c008c4823f35dc5f3c73d9a3e115784eaa0b52f075f41a", provider); // Ensure PRIVATE_KEY is set in .env
const contractAddress = "0xFE44520f1365f54A58dC26d30E4Ef07745DC76ee";

// Create a contract instance
const contract = new ethers.Contract(contractAddress, abi, wallet);

// Function to whitelist a user
async function whitelistUser() {
    const userAddress = wallet.address;
    console.log(userAddress)
    // Correct message hash calculation
    const message = ethers.solidityPacked(['address'], [userAddress]);
    const messageHash = ethers.keccak256(message);
    console.log("Message Hash:", messageHash);

    // Sign the message hash
    const signature = await wallet.signMessage(ethers.getBytes(messageHash));
    console.log("Signature:", signature);


    const ethHash = ethers.keccak256(
        ethers.solidityPacked(
            ["string", "bytes32"], 
            ["\x19Ethereum Signed Message:\n32", messageHash]
        )
    );

    // Verify the signature
    const recoveredAddress = ethers.verifyMessage(ethers.getBytes(messageHash), signature);
    console.log("Recovered Address:", recoveredAddress === userAddress);

    const { v, r, s } = ethers.Signature.from(signature);

    // Send the transaction to whitelist the user
    const tx = await contract.whiteListUser(ethHash,v,r,s);

    console.log("Transaction hash:", tx);

    // // Wait for the transaction to be mined
    // await tx.wait();
    // console.log("User whitelisted!");
}

// Example usage
whitelistUser();/* 
async function main() {
    // Whitelist the user
    await 
}

main().catch(error => {
    console.error("Error:", error);
}); */
