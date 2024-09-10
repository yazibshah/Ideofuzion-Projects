const { ethers } = require("ethers");

// Contract ABI (You need to replace this with the actual ABI of your contract)
const abi = [
  "function verifyAndAddToken(tokenData memory data, bytes signature) public returns (bool)"
];

// Contract address (replace with your deployed contract address)
const contractAddress = "0xF67d5F3d255F443D79ede31E3F64F81FbC0357aD";  // Your contract address

// Signer (You can use your wallet's private key for signing transactions)
const privateKey = "0xac41266bca8c2a4bb1ed52359620928c52af8fffd792b74f1f01a2208b3da099";
const provider = new ethers.JsonRpcProvider("https://bsc-testnet-dataseed.bnbchain.org/");
const signer = new ethers.Wallet(privateKey, provider);

// Connect to the deployed contract
const contract = new ethers.Contract(contractAddress, abi, signer);

// Define the tokenData struct
const tokenData = {
  tokenAddress: "0xeD697A29009B6F78d342807f22B3e4AC61706718",  // Token address
  priceFeed: "0x957Eb0316f02ba4a9De3D308742eefd44a3c1719"     // Price feed address
};

// Signature that was generated earlier (replace with your actual signature)
const signature = "0xb4a92df53324cf785f1ae8a7990f56847fd1ca39eefb6c92c51c170be66f852d51eee0986cd620ac1e03819dc7aa8a01be38a078c00811c06c2bc422fcf40d4e1b";  // EIP-712 signature you generated earlier

// Call the verifyAndAddToken function
async function callVerifyAndAddToken() {
  try {
    // Call the smart contract's verifyAndAddToken function
    const tx = await contract.verifyAndAddToken(
      signer.address,  // The address of the signer (from wallet)
      tokenData,       // The struct data to be verified
      signature        // The EIP-712 signature
    );

    console.log("Transaction sent:", tx);
    // const receipt = await tx.wait();  // Wait for transaction confirmation
    // console.log("Transaction confirmed:", receipt);

  } catch (error) {
    console.error("Error calling verifyAndAddToken:", error);
  }
}

// Call the function
callVerifyAndAddToken();
