const {ethers}=require("ethers");


const rpcProvider=new ethers.JsonRpcProvider("https://rpc-vanguard.vanarchain.com/");
const privateKey="79064b7cadf24c1b32c008c4823f35dc5f3c73d9a3e115784eaa0b52f075f41a";

const wallet =new ethers.Wallet(privateKey,rpcProvider);


const domain={
    name:'FundManager',
    version:'1',
    chainId:78600,
    verifyingContract:"0xb9942B15ec24B820A00Cd22694fe5765c4D0b651"
}


const types={
    withdrawlData:[
        {name:'to', type:'address'},
        { name: 'owner', type: 'address' },
        { name: 'amount', type: 'uint256' },
    ]
}

async function signEIP712Data(to,amount){
    const data={
        to:to,
        owner:wallet.address,
        amount:ethers.parseEther(amount)
    }

    const signature=await wallet.signTypedData(domain,types,data);
    console.log("signature:",signature);
}

signEIP712Data("0x01296a5f651f40566f1cee73677d4f8f3954a9ae","0.1")