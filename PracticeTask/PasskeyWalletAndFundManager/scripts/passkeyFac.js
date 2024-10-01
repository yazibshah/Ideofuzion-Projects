const { ethers, upgrades } = require("hardhat");

async function main() {
  const [deployer]=await ethers.getSigners()

  const Factory = await ethers.getContractFactory("Factory");
    const factory = await Factory.deploy();
    console.log("Deploying Factory contract...",await factory.getAddress());

  // Initialize the Factory with the PasskeyWallet implementation address
  

  // // Deploy a proxy via the Factory
  const deployProxyTx = await factory.deployProxy(await deployer.getAddress());
  console.log("Implementation" , await factory.UserProxyAddress(await deployer.getAddress()))

   const proxyWallet = await ethers.getContractAt("PasskeyWallet", await factory.UserProxyAddress(await deployer.getAddress()));
  
  // // // Call deposit function to test
   const depositTx = await proxyWallet.deposit({ value: ethers.parseEther("0.1") });

   console.log("Deposit of 0.1 ETH to the proxy wallet successful.");

  // // // Call withdrawnByOwner function to test
   const withdrawTx = await proxyWallet.withdrawnByOwner(ethers.parseEther("0.1"));
   // await withdrawTx.wait();
   console.log("Withdrawal of 0.1 ETH from the proxy wallet successful.");


const upgradeProxy = await factory.upgradeProxy();
console.log("upgradeImplementation" , await factory.newUserProxyAddress(await deployer.getAddress()))


const proxyWalletV1 = await ethers.getContractAt("PasskeyWalletV1", await factory.newUserProxyAddress(await deployer.getAddress()));
console.log("Updated Function",await proxyWalletV1.mul());

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Error:", error);
    process.exit(1);
  });
