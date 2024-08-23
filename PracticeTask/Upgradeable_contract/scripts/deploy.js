const { ethers, upgrades } = require("hardhat");

async function main() {
    // Deploy the implementation contract with initialization using the add function
    const Upgrade = await ethers.getContractFactory("Upgrade");
    const upgrade = await upgrades.deployProxy(Upgrade, [1, 2], { initializer: "add" });
    console.log("Upgrade deployed to:", upgrade.address);
    console.log("Add Value:", await upgrade.num());

    // Upgrade to Upgrade2
    const Upgrade2 = await ethers.getContractFactory("Upgrade2");
    const upgrade2 = await upgrades.upgradeProxy(upgrade.address, Upgrade2);
    console.log("Upgrade2 deployed to:", upgrade2.address);

    // Interact with the upgraded contract
    const val = await upgrade2.mul(2, 2);
    console.log("Multiplication result in Upgrade2:", await upgrade2.num());
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
