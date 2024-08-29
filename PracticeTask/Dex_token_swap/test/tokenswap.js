const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("TokenSwap Contract", function () {
    let TokenA, tokenA, TokenB, tokenB, TokenSwap, tokenSwap, decimals;
    let signer0, signer1, signer2, addr1, addr2;
    const initialSupplyA = BigInt(10000) * BigInt(10 ** 18); // 10,000 tokens with 18 decimals
    const initialSupplyB = BigInt(10000) * BigInt(10 ** 8);  // 10,000 tokens with 8 decimals
  
    beforeEach(async function () {
        [signer0, signer1, signer2, addr1, addr2] = await ethers.getSigners();
  
        // Deploy TokenA by signer0
        TokenA = await ethers.getContractFactory("TokenA", signer0);
        tokenA = await TokenA.deploy();
  
        // Deploy TokenB by signer1
        TokenB = await ethers.getContractFactory("TokenB", signer1);
        tokenB = await TokenB.deploy();
      
        // Deploy the TokenSwap contract by signer2
        TokenSwap = await ethers.getContractFactory("TokenSwap", signer2);
        tokenSwap = await TokenSwap.deploy(tokenA.getAddress(), tokenB.getAddress());
  
        // Transfer some tokens to TokenSwap contract
        await tokenA.connect(signer0).transfer(tokenSwap.getAddress(), BigInt(5000) * BigInt(10 ** 18));
        await tokenB.connect(signer1).transfer(tokenSwap.getAddress(), BigInt(5000) * BigInt(10 ** 8));
    });
  
    it("should allow signer0 to swap TokenA for TokenB", async function () {
        const amountA = BigInt(5000) * BigInt(10 ** 18);
        const expectedAmountB = amountA / BigInt(10 ** 10);

        await tokenA.connect(signer0).approve(tokenSwap.getAddress(), amountA);

        await tokenSwap.connect(signer0).swap(amountA, 0); // 0 for AforB

        expect(await tokenB.balanceOf(signer0.getAddress())).to.equal(expectedAmountB);
        // expect(await tokenA.balanceOf(signer0.getAddress())).to.equal(initialSupplyA - amountA);
    });

    it("should allow signer1 to swap TokenB for TokenA", async function () {
        const amountB = BigInt(5000) * BigInt(10 ** 8);
        const expectedAmountA = amountB * BigInt(10 ** 10);

        await tokenB.connect(signer1).approve(tokenSwap.getAddress(), amountB);

        await tokenSwap.connect(signer1).swap(amountB, 1); // 1 for BforA

        expect(await tokenA.balanceOf(signer1.getAddress())).to.equal(expectedAmountA);
        // expect(await tokenB.balanceOf(signer1.getAddress())).to.equal(initialSupplyB - amountB);
    });

    it("should fail if signer0 tries to swap TokenA with insufficient allowance", async function () {
        const amountA = BigInt(1000) * BigInt(10 ** 18);

        await tokenA.connect(signer0).approve(tokenSwap.getAddress(), BigInt(500) * BigInt(10 ** 18));

        await expect(
            tokenSwap.connect(signer0).swap(amountA, 0)
        ).to.be.revertedWithCustomError(tokenA, "ERC20InsufficientAllowance")
         .withArgs(tokenSwap.getAddress(), BigInt(500) * BigInt(10 ** 18), amountA);
    });

    it("should fail when TokenSwap contract has insufficient TokenB balance", async function () {
        const amountA = BigInt(5000) * BigInt(10 ** 18);

        await tokenA.connect(signer0).approve(tokenSwap.getAddress(), amountA);

        await tokenSwap.connect(signer2).withdrawTokenB(await tokenB.balanceOf(tokenSwap.getAddress()), signer1.getAddress());

        await expect(
            tokenSwap.connect(signer0).swap(amountA, 0)
        ).to.be.revertedWithCustomError(tokenB, "ERC20InsufficientBalance")
         .withArgs(tokenSwap.getAddress(), await tokenB.balanceOf(tokenSwap.getAddress()), amountA / BigInt(10 ** 10));
    });

    it("should fail when TokenSwap contract has insufficient TokenA balance", async function () {
        const amountB = BigInt(5000) * BigInt(10 ** 8);

        await tokenB.connect(signer1).approve(tokenSwap.getAddress(), amountB);

        await tokenSwap.connect(signer2).withdrawTokenA(await tokenA.balanceOf(tokenSwap.getAddress()), signer0.getAddress());

        await expect(
            tokenSwap.connect(signer1).swap(amountB, 1)
        ).to.be.revertedWithCustomError(tokenA, "ERC20InsufficientBalance")
         .withArgs(tokenSwap.getAddress(), BigInt(0), amountB * BigInt(10 ** 10));
    });

    it("should fail if signer1 tries to swap TokenB with zero allowance", async function () {
        const amountB = BigInt(1000) * BigInt(10 ** 8);

        await tokenB.connect(signer1).approve(tokenSwap.getAddress(), 0);

        await expect(
            tokenSwap.connect(signer1).swap(amountB, 1)
        ).to.be.revertedWithCustomError(tokenB, "ERC20InsufficientAllowance")
         .withArgs(tokenSwap.getAddress(), 0, amountB);
    });

    it("should allow signer0 to swap TokenA after increasing allowance", async function () {
        const amountA = BigInt(1000) * BigInt(10 ** 18);

        await tokenA.connect(signer0).approve(tokenSwap.getAddress(), 0);
        await tokenA.connect(signer0).approve(tokenSwap.getAddress(), amountA);

        await tokenSwap.connect(signer0).swap(amountA, 0);

        const expectedAmountB = amountA / BigInt(10 ** 10);
        expect(await tokenB.balanceOf(signer0.getAddress())).to.equal(expectedAmountB);
    });

    it("should fail if invalid swap type is provided", async function () {
        const amountA = BigInt(1000) * BigInt(10 ** 18);

        await expect(
            tokenSwap.connect(signer0).swap(amountA, 2) // Invalid swap type
        ).to.be.revertedWithoutReason("Invalid swap type");
    });

    it("should fail if non-owner tries to view the TokenA balance of the contract", async function () {
        await expect(tokenSwap.connect(signer0).getTokenABalance())
                .to.be.revertedWithCustomError(tokenSwap, 'OwnableUnauthorizedAccount')
                .withArgs(signer0.getAddress());
    });

    it("should fail if non-owner tries to withdraw TokenA from the contract", async function () {
        const amountA = BigInt(1000) * BigInt(10 ** 18);

        await expect(
            tokenSwap.connect(signer0).withdrawTokenA(amountA, signer0.getAddress())
        ).to.be.revertedWithCustomError(tokenSwap, 'OwnableUnauthorizedAccount')
         .withArgs(signer0.getAddress());
    });
});
