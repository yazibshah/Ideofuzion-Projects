const { expect } = require("chai");
const { ethers } = require("hardhat");


let task1;
let owner;
let addr1;
let addr2;

beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();
    task1 = await ethers.deployContract("Task1");
    
});

describe("Task1 Contract", function () {

    it("Should deploy and set the right owner", async function () {
        expect(await task1.owner()).to.equal(owner.address);
     });

    it("Should allow a user to store their data", async function () {
        await task1.connect(addr1).storeData("yazib", 25, "Blockchain Developer");

        const [name, age, designation] = await task1.connect(addr1).retrieveData(addr1.address);

        expect(name).to.equal("yazib");
        expect(age).to.equal(25);
        expect(designation).to.equal("Blockchain Developer");
    });

    it("Should allow the owner to retrieve any user's data", async function () {
        await task1.connect(addr1).storeData("Bob", 25, "Designer");

        const [name, age, designation] = await task1.connect(owner).retrieveData(addr1.address);

        expect(name).to.equal("Bob");
        expect(age).to.equal(25);
        expect(designation).to.equal("Designer");
    });

    it("Should not allow a user to retrieve another user's data", async function () {
        await task1.connect(addr1).storeData("Charlie", 28, "Manager");

        await expect(
            task1.connect(addr2).retrieveData(addr1.address)
        ).to.be.revertedWith("This Data is not yours");
    });

    it("Should update the data when the same user stores data again", async function () {
        await task1.connect(addr1).storeData("Alice", 30, "Developer");
        await task1.connect(addr1).storeData("Alice", 31, "Senior Developer");

        const [name, age, designation] = await task1.connect(addr1).retrieveData(addr1.address);

        expect(name).to.equal("Alice");
        expect(age).to.equal(31);
        expect(designation).to.equal("Senior Developer");
    });


    it("Should allow the owner to store their own data and retrieve it", async function () {
        await task1.connect(owner).storeData("Owner", 40, "CEO");

        const [name, age, designation] = await task1.retrieveData(owner.address);

        expect(name).to.equal("Owner");
        expect(age).to.equal(40);
        expect(designation).to.equal("CEO");
    });
});
