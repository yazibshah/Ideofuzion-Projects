const { ethers } = require("ethers");

async function main() {
    // Setup provider and signer (e.g., MetaMask or a private key wallet)
    const provider = new ethers.JsonRpcProvider("https://bsc-testnet-dataseed.bnbchain.org/");
    const signer = new ethers.Wallet("", provider);

    // Contract address and ABI (Application Binary Interface)
    const contractAddress = "0x639C9EFc88adD39665f710Ef0F6D79633539a1b9"; // Replace with your deployed contract address
  
    
    

    // Define the domain for EIP-712
    const domain = {
        name: "DexIdeo",
        version: "1",
        chainId: 97,  // BSC Testnet
        verifyingContract: contractAddress
    };

    // Define the types for the EIP-712 data
    const types = {
        tokenData: [
            { name: "tokenAddress", type: "address" },
            { name: "priceFeed", type: "address" }
        ]
    };

    // Define the data to be signed
    const message = {
        tokenAddress: "0xeD697A29009B6F78d342807f22B3e4AC61706718",  // Replace with the token address
        priceFeed: "0x957Eb0316f02ba4a9De3D308742eefd44a3c1719"  // Replace with the price feed address
    };

    // Sign the EIP-712 typed data
    const signature = await signer.signTypedData(domain, types, message);
    console.log("Signature:", signature);
    console.log("Address",signer.address)
    // Call the verifyAndAddToken function in the contract with the signed data

}

// Run the main function
main().catch((error) => {
    console.error(error);
    process.exit(1);
});
