const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("EtherWallet Contract", function () {
    let etherWallet;
    let owner;
    let addr1;
    let addr2;

    beforeEach(async function () {
        const EtherWallet = await ethers.getContractFactory("EtherWallet");
        [owner, addr1, addr2] = await ethers.getSigners();
        etherWallet = await EtherWallet.deploy();
        
    });

    it("should deploy and set the owner correctly", async function () {
        expect(await etherWallet.owner()).to.equal(owner.address);
    });

    it("should allow users to deposit Ether", async function () {
        const depositAmount = ethers.parseEther("1.0"); // 1 ETH
        await etherWallet.connect(addr1).deposit({ value: depositAmount });
    });

    it("should emit a Deposit event on deposit", async function () {
        const depositAmount = ethers.parseEther("1.0");
        await expect(etherWallet.connect(addr1).deposit({ value: depositAmount })).to.emit(etherWallet, "Deposit")
            .withArgs(addr1.address, depositAmount);
    });

    it("should allow users to withdraw their deposited Ether", async function () {
        const depositAmount = ethers.parseEther("1.0");
        await etherWallet.connect(addr1).deposit({ value: depositAmount });

        const initialBalance = await ethers.provider.getBalance(addr1.address);
        console.log(initialBalance)
        await etherWallet.connect(addr1).withdraw(depositAmount);

        const finalBalance = await ethers.provider.getBalance(addr1.address);
        console.log(finalBalance);
        expect(finalBalance).to.be.above(initialBalance); // Consider gas fees
    });

    it("should emit a Withdraw event on withdrawal", async function () {
        const depositAmount = ethers.parseEther("1.0");
        await etherWallet.connect(addr1).deposit({ value: depositAmount });

        await expect(etherWallet.connect(addr1).withdraw(depositAmount))
            .to.emit(etherWallet, "Withdraw")
            .withArgs(addr1.address, true, depositAmount);
    });

    it("Insufficient Balance", async function () {
        await expect(etherWallet.connect(addr1).withdraw(ethers.parseEther("1.0"))).revertedWith("Insufficient balance")
    });

    it("should allow the owner to withdraw Ether", async function () {
        const depositAmount = ethers.parseEther("1.0");
        await etherWallet.connect(addr1).deposit({ value: depositAmount });

        const initialBalance = await ethers.provider.getBalance(owner.address);
        await etherWallet.withdrawByOwner(depositAmount);

        const finalBalance = await ethers.provider.getBalance(owner.address);
        expect(finalBalance).to.be.above(initialBalance); // Consider gas fees
        expect(await ethers.provider.getBalance(etherWallet)).to.equal(0);
    });

    it("should not allow non-owners to withdraw using withdrawByOwner", async function () {
        await expect(etherWallet.connect(addr1).withdrawByOwner(ethers.parseEther("1.0"))).to.be.revertedWithCustomError(
            etherWallet,
            "OwnableUnauthorizedAccount"
        ).withArgs(addr1.address);
    });

    it("should revert withdraw if insufficient balance", async function () {
        const depositAmount = ethers.parseEther("1.0");
        await etherWallet.connect(addr1).deposit({ value: depositAmount });

        await expect(etherWallet.connect(addr1).withdraw(ethers.parseEther("2.0"))).to.be.revertedWith("Insufficient balance");
    });

    it("should accept Ether via receive function", async function () {
        const sendAmount = ethers.parseEther("1.0");
        await addr1.sendTransaction({ to: etherWallet, value: sendAmount });

        expect(await etherWallet.balances(addr1.address)).to.equal(sendAmount);
        expect(await ethers.provider.getBalance(etherWallet)).to.equal(sendAmount);
    });
});
