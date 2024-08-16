const { expect } = require("chai");
const { ethers } = require("hardhat");


    let todoList;
    let owner;
    let addr1;

    beforeEach(async function () {
        ToDoList = await ethers.getContractFactory("ToDoList");
        [owner, addr1] = await ethers.getSigners();
        todoList = await ToDoList.deploy();
        
    });

    



describe("Add Task", function () {

    it("should deploy and set the owner correctly", async function () {
        expect(await todoList.owner()).to.equal(owner.address);
    });

    it("should allow the owner to add a task", async function () {
        await todoList.addTask("My first task");
        const task = await todoList.getTask(0);
        expect(task.description).to.equal("My first task");
        expect(task.isCompleted).to.equal(false);
    });

    it("should increment the task count when a task is added", async function () {
        await todoList.addTask("Task 1");
        await todoList.addTask("Task 2");
        const taskCount = await todoList.getTaskCount();
        expect(taskCount).to.equal(2);
    });

    it("should not allow non-owners to add a task", async function () {
        await expect(todoList.connect(addr1).addTask("Task by non-owner")).to.be.revertedWith("Only Owner Can Access");
    });
});



describe("Toggle Task", function () {
    it("should allow the owner to toggle task completion", async function () {
        await todoList.addTask("Task to be toggled");
        await todoList.toggleTask(0);
        const task = await todoList.getTask(0);
        expect(task.isCompleted).to.equal(true);
    });

    it("should revert if trying to toggle a non-existent task", async function () {
        await expect(todoList.toggleTask(99)).to.be.revertedWith("Task does not exist");
    });

    it("should not allow non-owners to toggle a task", async function () {
        await todoList.addTask("Task 1");
        await expect(todoList.connect(addr1).toggleTask(0)).to.be.revertedWith("Only Owner Can Toggle");
    });
});


describe("Get Task", function () {
    it("should return the correct task details", async function () {
        await todoList.addTask("Task 1");
        const task = await todoList.getTask(0);
        expect(task.description).to.equal("Task 1");
        expect(task.isCompleted).to.equal(false);
    });

    it("should revert if trying to get a non-existent task", async function () {
        await expect(todoList.getTask(99)).to.be.revertedWith("Task does not exist");
    });
});


describe("Get Task Count", function () {
    it("should return the correct task count", async function () {
        await todoList.addTask("Task 1");
        await todoList.addTask("Task 2");
        const taskCount = await todoList.getTaskCount();
        expect(taskCount).to.equal(2);
    });
});

