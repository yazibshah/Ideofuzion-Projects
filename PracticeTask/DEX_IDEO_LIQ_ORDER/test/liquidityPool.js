require("dotenv").config();
const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("LiquidityPool on BSC Testnet", function () {
  let addr, addr1;
  let liquidityPool, token, priceProvider;

  before(async function () {
    // Set up the BSC Testnet provider
    const provider = new ethers.JsonRpcProvider('https://bsc-testnet-dataseed.bnbchain.org');

    // Load private keys from .env file
    const addrPrivateKey = "ac41266bca8c2a4bb1ed52359620928c52af8fffd792b74f1f01a2208b3da099";
    const addr1PrivateKey = "79064b7cadf24c1b32c008c4823f35dc5f3c73d9a3e115784eaa0b52f075f41a";

    // Create signers from private keys
    addr = new ethers.Wallet(addrPrivateKey, provider);
    addr1 = new ethers.Wallet(addr1PrivateKey, provider);

    console.log("addr address:",await  addr.getAddress());
    console.log("Addr1 address:",await addr1.getAddress());

    // Deploy the PriceProvider contract
    const PriceProvider = await ethers.getContractFactory("PriceProvider", addr1);
    priceProvider = await PriceProvider.deploy();
    console.log("PriceProvider deployed at:",await priceProvider.getAddress());

    // Deploy the LiquidityPool contract
    const LiquidityPool = await ethers.getContractFactory("LiquidityPool", addr1);
    liquidityPool = await LiquidityPool.deploy(await priceProvider.getAddress(),await addr1.getAddress());
    console.log("LiquidityPool deployed at:",await liquidityPool.getAddress());

    // Deploy the Token (Bitcoin) contract
    const Token = await ethers.getContractFactory("Bitcoin", addr1);
    token = await Token.deploy();
    console.log("Token deployed at:", await token.getAddress());

    // // Add the token to the liquidity pool
    await liquidityPool.connect(addr1).addToken(await token.getAddress(),"0x5741306c21795FdCBb9b265Ea0255F499DFe515C",{gasLimit: 1000000});
    console.log("Token added to LiquidityPool");
  });

  it("should add liquidity", async function () {
    // Mint tokens to addr1 and approve them for liquidity addition
    // await token.connect(addr).transfer(addr1.getAddress(), ethers.parseEther("1000", 18)); // 1000 tokens to addr1
    await token.connect(addr1).approve(await liquidityPool.getAddress(), ethers.parseEther("1000")); // Approve 500 tokens
    console.log(await liquidityPool.owner()==await addr1.getAddress());

    // Add the token to the liquidity pool
    
    try {
        await liquidityPool.connect(addr1).addToken(await token.getAddress(), "0x5741306c21795FdCBb9b265Ea0255F499DFe515C", { gasLimit: 1000000 });
    } catch (error) {
        console.error("Transaction reverted:", error);
    }
    
    console.log(await liquidityPool.allowedTokens(await token.getAddress()))
    console.log(await priceProvider.getLatestPrice("0x5741306c21795FdCBb9b265Ea0255F499DFe515C"));
    // Add liquidity
    await expect(await liquidityPool.connect(addr1).addLiquidity(await token.getAddress(), ethers.parseEther("500")))
       .to.emit(liquidityPool, "LiquidityAdded")
       .withArgs(await addr.getAddress(),await token.getAddress(), ethers.parseEther("500", 18));

     const balance = await liquidityPool.userTokenBalance(await addr1.getAddress(),await token.getAddress());
     expect(balance).to.equal(ethers.parseEther("500"));
  });

  it("should remove liquidity", async function () {
    // Add liquidity first
    await token.connect(addr1).approve(liquidityPool.getAddress(), ethers.parseEther("500", 18));
    await liquidityPool.connect(addr1).addLiquidity(token.getAddress(), ethers.parseEther("500", 18));

    // Remove liquidity
    await expect(liquidityPool.connect(addr1).removeLiquidity(token.getAddress(), ethers.parseEther("200", 18)))
      .to.emit(liquidityPool, "LiquidityRemoved")
      .withArgs(addr1.getAddress(), token.getAddress(), ethers.parseEther("200", 18));

    const balance = await liquidityPool.userTokenBalance(addr1.getAddress(), token.getAddress());
    expect(balance).to.equal(ethers.parseEther("300", 18)); // After removing 200 tokens
  });

  it("should revert if removing more liquidity than available", async function () {
    // Add liquidity first
    await token.connect(addr1).approve(liquidityPool.getAddress(), ethers.parseEther("500", 18));
    await liquidityPool.connect(addr1).addLiquidity(token.getAddress(), ethers.parseEther("500", 18));

    // Attempt to remove more than available liquidity
    await expect(liquidityPool.connect(addr1).removeLiquidity(token.getAddress(), ethers.parseEther("600", 18)))
      .to.be.revertedWith("Insufficient liquidity");
   });
});
