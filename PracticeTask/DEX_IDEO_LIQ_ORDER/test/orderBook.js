const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("OrderBook Contract Tests", function () {
    let OrderBook, orderBook;
    let LiquidityPool, liquidityPool;
    let PriceProvider, priceProvider;
    let Bitcoin, bitcoin;
    let ETH, eth;
    let addr, addr1;
    const provider = new ethers.JsonRpcProvider('https://bsc-testnet-dataseed.bnbchain.org');
    const addrPrivateKey = "ac41266bca8c2a4bb1ed52359620928c52af8fffd792b74f1f01a2208b3da099";
    const addr1PrivateKey = "79064b7cadf24c1b32c008c4823f35dc5f3c73d9a3e115784eaa0b52f075f41a";

    before(async function () {
        // Set up signers
        addr = new ethers.Wallet(addrPrivateKey, provider);
        addr1 = new ethers.Wallet(addr1PrivateKey, provider);

        // Deploy PriceProvider contract
        PriceProvider = await ethers.getContractFactory("PriceProvider");
        priceProvider = await PriceProvider.deploy();

        // Deploy Bitcoin and ETH token contracts
        Bitcoin = await ethers.getContractFactory("Bitcoin");
        bitcoin = await Bitcoin.deploy();
        
        ETH = await ethers.getContractFactory("ETH");
        eth = await ETH.deploy();

        // Deploy LiquidityPool contract
        LiquidityPool = await ethers.getContractFactory("LiquidityPool");
        liquidityPool = await LiquidityPool.deploy(priceProvider.getAddress(), addr.getAddress());

        // Deploy OrderBook contract
        OrderBook = await ethers.getContractFactory("OrderBook");
        orderBook = await OrderBook.deploy(liquidityPool.getAddress());

        // Add BTC and ETH tokens to the liquidity pool
        await liquidityPool.addToken(bitcoin.getAddress(), priceProvider.getAddress());
        await liquidityPool.addToken(eth.getAddress(), priceProvider.getAddress());

        // Provide liquidity
        await bitcoin.connect(addr).approve(liquidityPool.getAddress(), ethers.parseEther("100"));
        await eth.connect(addr).approve(liquidityPool.getAddress(), ethers.parseEther("100"));
        await liquidityPool.connect(addr).addLiquidity(bitcoin.getAddress(), ethers.parseEther("100"));
        await liquidityPool.connect(addr).addLiquidity(eth.getAddress(), ethers.parseEther("100"));
    });

    it("should deploy the contracts correctly", async function () {
        expect(await orderBook.liquidityPool()).to.equal(liquidityPool.getAddress());
    });

    it("should allow placing a sell order with BTC", async function () {
        await orderBook.connect(addr).placeSellOrder(bitcoin.getAddress(), eth.getAddress(), ethers.parseEther("10"), ethers.parseUnits("50000", 18));
        const order = await orderBook.orders(0);

        expect(order.user).to.equal(addr.getAddress());
        expect(order.amount).to.equal(ethers.parseEther("10"));
        expect(order.price).to.equal(ethers.parseUnits("50000", 18));
        expect(order.isBuyOrder).to.be.false;
    });

    it("should allow placing a buy order with ETH", async function () {
        await orderBook.connect(addr1).placeBuyOrder(bitcoin.getAddress(), eth.getAddress(), ethers.parseEther("10"), ethers.parseUnits("50000", 18));
        const order = await orderBook.orders(1);

        expect(order.user).to.equal(addr1.getAddress());
        expect(order.amount).to.equal(ethers.parseEther("10"));
        expect(order.price).to.equal(ethers.parseUnits("50000", 18));
        expect(order.isBuyOrder).to.be.true;
    });

    it("should match orders correctly", async function () {
        await orderBook.connect(addr1).placeSellOrder(bitcoin.getAddress(), eth.getAddress(), ethers.parseEther("10"), ethers.parseUnits("50000", 18));
        await orderBook.connect(addr).placeBuyOrder(bitcoin.getAddress(), eth.getAddress(), ethers.parseEther("10"), ethers.parseUnits("50000", 18));
        const sellOrder = await orderBook.orders(0);
        const buyOrder = await orderBook.orders(1);

        expect(sellOrder.amount).to.equal(ethers.parseEther("0"));
        expect(buyOrder.amount).to.equal(ethers.parseEther("0"));
    });

    it("should fail to place sell order with insufficient balance", async function () {
        await bitcoin.connect(addr1).transfer(addr.getAddress(), ethers.parseEther("50"));
        await bitcoin.connect(addr).approve(liquidityPool.getAddress(), ethers.parseEther("50"));
        await liquidityPool.connect(addr).addLiquidity(bitcoin.getAddress(), ethers.parseEther("50"));

        await expect(
            orderBook.connect(addr).placeSellOrder(bitcoin.getAddress(), eth.getAddress(), ethers.parseEther("100"), ethers.parseUnits("50000", 18))
        ).to.be.revertedWith("Insufficient seller balance");
    });

    it("should fail to place buy order with invalid token", async function () {
        const invalidToken = ethers.Wallet.createRandom().address;

        await expect(
            orderBook.connect(addr).placeBuyOrder(invalidToken, eth.getAddress(), ethers.parseEther("100"), ethers.parseUnits("50000", 18))
        ).to.be.revertedWith("Token not allowed");
    });

    it("should match orders with partial fulfillment", async function () {
        await orderBook.connect(addr1).placeSellOrder(bitcoin.getAddress(), eth.getAddress(), ethers.parseEther("100"), ethers.parseUnits("50000", 18));
        await orderBook.connect(addr).placeBuyOrder(bitcoin.getAddress(), eth.getAddress(), ethers.parseEther("50"), ethers.parseUnits("50000", 18));
        
        const sellOrder = await orderBook.orders(0);
        const buyOrder = await orderBook.orders(1);

        expect(sellOrder.amount).to.equal(ethers.parseEther("50"));
        expect(buyOrder.amount).to.equal(ethers.parseEther("0"));
    });

    it("should match multiple orders", async function () {
        await orderBook.connect(addr1).placeSellOrder(bitcoin.getAddress(), eth.getAddress(), ethers.parseEther("50"), ethers.parseUnits("50000", 18));
        await orderBook.connect(addr1).placeSellOrder(bitcoin.getAddress(), eth.getAddress(), ethers.parseEther("50"), ethers.parseUnits("60000", 18));
        await orderBook.connect(addr).placeBuyOrder(bitcoin.getAddress(), eth.getAddress(), ethers.parseEther("30"), ethers.parseUnits("55000", 18));
        await orderBook.connect(addr).placeBuyOrder(bitcoin.getAddress(), eth.getAddress(), ethers.parseEther("70"), ethers.parseUnits("60000", 18));

        const orders = await Promise.all([
            orderBook.orders(0),
            orderBook.orders(1),
            orderBook.orders(2),
            orderBook.orders(3)
        ]);

        expect(orders[0].amount).to.equal(ethers.parseEther("20"));
        expect(orders[1].amount).to.equal(ethers.parseEther("0"));
        expect(orders[2].amount).to.equal(ethers.parseEther("0"));
        expect(orders[3].amount).to.equal(ethers.parseEther("50"));
    });

    it("should not process order with zero amount", async function () {
        await expect(
            orderBook.connect(addr1).placeSellOrder(bitcoin.getAddress(), eth.getAddress(), ethers.parseEther("0"), ethers.parseUnits("50000", 18))
        ).to.be.revertedWith("Invalid amount");

        await expect(
            orderBook.connect(addr).placeBuyOrder(bitcoin.getAddress(), eth.getAddress(), ethers.parseEther("0"), ethers.parseUnits("50000", 18))
        ).to.be.revertedWith("Invalid amount");
    });

    it("should fail to delete a non-existent order", async function () {
        await expect(
            orderBook.connect(addr).deleteOrder(999)
        ).to.be.revertedWith("Invalid order ID");
    });

    it("should emit correct events for order actions", async function () {
        await expect(
            orderBook.connect(addr1).placeSellOrder(bitcoin.getAddress(), eth.getAddress(), ethers.parseEther("100"), ethers.parseUnits("50000", 18))
        ).to.emit(orderBook, "OrderPlaced")
        .withArgs(0, addr1.getAddress(), bitcoin.getAddress(), eth.getAddress(), ethers.parseEther("100"), ethers.parseUnits("50000", 18), false);

        await expect(
            orderBook.connect(addr).placeBuyOrder(bitcoin.getAddress(), eth.getAddress(), ethers.parseEther("100"), ethers.parseUnits("50000", 18))
        ).to.emit(orderBook, "OrderPlaced")
        .withArgs(1, addr.getAddress(), bitcoin.getAddress(), eth.getAddress(), ethers.parseEther("100"), ethers.parseUnits("50000", 18), true);

        await expect(
            orderBook.connect(addr1).deleteOrder(0)
        ).to.emit(orderBook, "OrderCanceled")
        .withArgs(0);
    });

    it("should fail to change owner by non-owner", async function () {
        await expect(
            orderBook.connect(addr1).transferOwnership(await addr.getAddress())
        ).to.be.revertedWith("Ownable: caller is not the owner");
    });
});
