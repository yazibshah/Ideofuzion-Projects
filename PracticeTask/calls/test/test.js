const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Contract B interacting with Contract A", function () {
  let A, B;
  let contractA, contractB;
  let owner, addr1, addr2;

  beforeEach(async function () {
    // Get the ContractFactory and Signers here.
    A = await ethers.getContractFactory("A");
    B = await ethers.getContractFactory("B");
    [owner, addr1, addr2, _] = await ethers.getSigners();

    // Deploy Contract A
    contractA = await A.deploy();
    

    // Deploy Contract B with address of Contract A
    contractB = await B.deploy(contractA.getAddress());
    
  });

  describe("setValue function", function () {
    it("should set value in Contract A through Contract B", async function () {
      // Call set function from Contract B, which will interact with Contract A
      await contractB.set(42);

      // Check if the value is set correctly in Contract A
      expect(await contractA.a()).to.equal(42);
    });

    it("should emit an event when setting value in Contract A through Contract B", async function () {
      // We can listen to events as well (if there's any in your implementation)

      // Perform the set operation
      await contractB.set(100, { value: ethers.parseEther("0.5") });

      // Check if the value is set correctly in Contract A
      expect(await contractA.a()).to.equal(100);
    });

    it("should accept Ether during the set operation", async function () {
      // Check balance before
      const initialBalance = await ethers.provider.getBalance(contractA.getAddress());
      expect(initialBalance).to.equal(ethers.parseEther("0.0"));

      // Perform the set operation with Ether
      await contractB.set(55, { value: ethers.parseEther("2.0") });

      // Check if the contract balance increased
      const finalBalance = await ethers.provider.getBalance(contractA.getAddress());
      expect(finalBalance).to.equal(ethers.parseEther("2.0"));
    });
  });
});
