const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ChallengeTwo Contract", function () {
    let ChallengeTwo;
    let challengeTwo;
    let owner;
    let addr1;

    beforeEach(async function () {
        ChallengeTwo = await ethers.getContractFactory("ChallengeTwo");
        [owner, addr1] = await ethers.getSigners();
        challengeTwo = await ChallengeTwo.deploy();
        
    });

    describe("Deployment", function () {
        it("should set the correct owner", async function () {
            expect(await challengeTwo.owner()).to.equal(owner.address);
        });

        it("should set the initial counter to 2", async function () {
            expect(await challengeTwo.counter()).to.equal(2);
        });
    });

    describe("incrementCounter", function () {
        it("should allow the owner to increment the counter", async function () {
            await challengeTwo.incrementCounter();
            expect(await challengeTwo.counter()).to.equal(3);

            await challengeTwo.incrementCounter();
            expect(await challengeTwo.counter()).to.equal(4);
        });

        it("should not allow non-owners to increment the counter", async function () {
            await expect(
                challengeTwo.connect(addr1).incrementCounter()
            ).to.be.revertedWithCustomError(challengeTwo, "OwnableUnauthorizedAccount")
              .withArgs(addr1.address);
        });
    });
});
