const {ethers}=require("ethers");

const testnetRPC="https://bsc-testnet.bnbchain.org/";

const provider=new ethers.JsonRpcProvider(testnetRPC);

const PrivateKey="79064b7cadf24c1b32c008c4823f35dc5f3c73d9a3e115784eaa0b52f075f41a";
const wallet=new ethers.Wallet(PrivateKey,provider);

const encodeCallAddress="0xb58EBd2113dc607C37c421976AC7dFD50f15aBF1";

const tokenAddress="0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06";
const priceeFeedAddress="0x1B329402Cb1825C6F30A0d92aB9E2862BE47333f";

async function main() {
    const iFace=new ethers.Interface([
         "function addToken(address token, address priceAddress)"
    ])

    const callData=iFace.encodeFunctionData("addToken",[tokenAddress,priceeFeedAddress]);
    console.log("Bytes Data ",callData);
    const encodeCallsContract = new ethers.Contract(encodeCallAddress, [
        "function callAddToken(bytes memory callData) public"
    ], wallet)

    // Send the transaction
    const tx = await encodeCallsContract.callAddToken(callData);
    console.log("Transaction confirmed:",await tx);

}

main().catch(console.error);
