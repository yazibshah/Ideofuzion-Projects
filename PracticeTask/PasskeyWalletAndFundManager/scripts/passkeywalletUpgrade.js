/* // scripts/deploy_proxy.js

const { ethers, upgrades } = require("hardhat");

async function main() {
  const PasskeyWalletUPgrade = await ethers.getContractFactory("PasskeyWalletUPgrade");
  console.log("Upgrading to PasskeyWalletUPgrade...");
  const walletProxyUpgrade = await upgrades.upgradeProxy("0x8757709aCbEa01D992E58231DF3a100c912Ee366", PasskeyWalletUPgrade);
  await walletProxy.deployed();

  console.log("PasskeyWallet upgraded to:", await walletProxyUpgrade.getAddress());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
 */