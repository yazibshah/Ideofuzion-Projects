const { expect } = require("chai");
const { ethers } = require("hardhat");

let timelockWallet;
let owner;
let addr1;
const lockTime = 200; // 200 seconds lock time

beforeEach(async function () {
        const TimelockWallet = await ethers.getContractFactory("TimelockWallet");
        [owner, addr1] = await ethers.getSigners();
        timelockWallet = await TimelockWallet.deploy();
        
});
describe("TimelockWallet Contract", function () {
    

    it("should allow users to deposit Ether", async function () {
        const depositAmount = ethers.parseEther("1.0"); // 1 ETH
        await timelockWallet.connect(addr1).deposit({ value: depositAmount });

        const [amount, time] = await timelockWallet.connect(addr1).getDepositDetails();
        expect(amount).to.equal(depositAmount);
        expect(time).to.be.closeTo(await ethers.provider.getBlock("latest").then(block => block.timestamp), 2);
    });

    it("should emit a DepositMade event on deposit", async function () {
        const depositAmount = ethers.parseEther("1.0");
        await expect(await timelockWallet.connect(addr1).deposit({ value: depositAmount }))
            .to.emit(timelockWallet, "DepositMade")
            .withArgs(addr1.address, depositAmount,  await ethers.provider.getBlock("latest").then(block => block.timestamp));
    });

    it("should prevent withdrawal before the lock time has passed", async function () {
        const depositAmount = ethers.parseEther("1.0");
        await timelockWallet.connect(addr1).deposit({ value: depositAmount });

        await expect(timelockWallet.connect(addr1).withdraw()).to.be.revertedWith("Funds are still locked");
    });

    it("should allow withdrawal after the lock time has passed", async function () {
        const depositAmount = ethers.parseEther("1.0");
        await timelockWallet.connect(addr1).deposit({ value: depositAmount });

        // Increase the time in the EVM by 200 seconds
        await ethers.provider.send("evm_increaseTime", [lockTime]);
        await ethers.provider.send("evm_mine"); // mine a block to reflect the time change

        await expect(timelockWallet.connect(addr1).withdraw())
            .to.emit(timelockWallet, "WithdrawalMade")
            .withArgs(addr1.address, depositAmount);

        const [amount] = await timelockWallet.connect(addr1).getDepositDetails();
        expect(amount).to.equal(0);
    });

    it("should prevent withdrawal if no deposit was made", async function () {
        await expect(timelockWallet.connect(addr1).withdraw()).to.be.revertedWith("No funds to withdraw");
    });

});
