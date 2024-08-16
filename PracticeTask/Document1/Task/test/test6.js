const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("AddressHasher Contract", function () {
    let AddressHasher;
    let hasher;
    let addr1;
    let addr2;
    let addr3;

    beforeEach(async function () {
        AddressHasher = await ethers.getContractFactory("AddressHasher");
        hasher = await AddressHasher.deploy();

        [addr1, addr2, addr3] = await ethers.getSigners();
    });

    describe("hashAddresses", function () {
        it("should generate the same hash for the same address pair", async function () {
            const hash1 = await hasher.hashAddresses(addr1.address, addr2.address);
            const hash2 = await hasher.hashAddresses(addr1.address, addr2.address);

            expect(hash1).to.equal(hash2);
        });

        it("should generate different hashes for different address pairs", async function () {
            const hash1 = await hasher.hashAddresses(addr1.address, addr2.address);
            const hash2 = await hasher.hashAddresses(addr1.address, addr3.address);

            expect(hash1).to.not.equal(hash2);
        });

        it("should revert if any address is zero", async function () {
            await expect(
                hasher.hashAddresses(await ethers.ZeroAddress, addr2.address)
            ).to.be.revertedWith("Invalid address: address cannot be zero");

            await expect(
                hasher.hashAddresses(addr1.address,await ethers.ZeroAddress)
            ).to.be.revertedWith("Invalid address: address cannot be zero");
        });
    });

    describe("validateHash", function () {
        it("should return true for a valid hash and matching address pair", async function () {
            const hash = await hasher.hashAddresses(addr1.address, addr2.address);
            const isValid = await hasher.validateHash(addr1.address, addr2.address, hash);

            expect(isValid).to.be.true;
        });

        it("should revert if the hash does not match the address pair", async function () {
            const hash = await hasher.hashAddresses(addr1.address, addr2.address);

            await expect(
                hasher.validateHash(addr1.address, addr3.address, hash)
            ).to.be.revertedWith("Data is not matched");
        });
    });
});
