const {ethers, solidityPacked}=require("ethers");

const testnetRPC="https://bsc-testnet.bnbchain.org/";

const provider=new ethers.JsonRpcProvider(testnetRPC);

const PrivateKey="";
const wallet=new ethers.Wallet(PrivateKey,provider);

const encodeCallAddress="0x300c4a0414fc38662A50ddEC19C5fDA8Ec71b18c";

const tokenAddress="0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06";
const priceeFeedAddress="0x9331b55D9830EF609A2aBCfAc0FBCE050A52fdEa";

async function main() {
    const iFace=new ethers.Interface([
         "function addToken(address token, address priceAddress)"
    ])

    const callData=iFace.encodeFunctionData("addToken",[tokenAddress,priceeFeedAddress]);
    console.log("Bytes Data ",callData);

    const callDataHash=await ethers.keccak256(ethers.solidityPacked(["bytes"],[callData]))
    console.log("Hash: ",callDataHash);
    
    const signMessage=await wallet.signMessage(ethers.getBytes(callDataHash));
    console.log("Signature: ",signMessage)

    const ethHash = ethers.keccak256(
        ethers.solidityPacked(
            ["string", "bytes32"], 
            ["\x19Ethereum Signed Message:\n32", callDataHash]
        )
    );
    console.log("ETH Hash: ",ethHash);

    const  verify=await ethers.verifyMessage(ethers.getBytes(callDataHash),signMessage);
    console.log(verify==wallet.address)
    console.log(wallet.address)
    

}

main().catch(console.error);
