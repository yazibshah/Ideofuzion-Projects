// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract ToDoList is Ownable {
    // Struct to represent a Task
    struct Task {
        string description;
        bool isCompleted;
    }

    // Mapping to store tasks by their ID
    mapping(uint256 => Task) private tasks;
    uint256 private taskCount;

    constructor() Ownable(msg.sender){
        taskCount = 0;
    }

    // Function to add a new task (only owner)
    function addTask(string memory _description) public{
        require(msg.sender==owner(),"Only Owner Can Access");
        tasks[taskCount] = Task(_description, false);
        taskCount++;
    }

    // Function to toggle the completion status of a task (only owner)
    function toggleTask(uint256 _taskId) public {
        require(msg.sender==owner(),"Only Owner Can Toggle");
        require(_taskId < taskCount, "Task does not exist");
        tasks[_taskId].isCompleted = !tasks[_taskId].isCompleted;
    }

    // Function to get task details
    function getTask(uint256 _taskId) public view returns (string memory description, bool isCompleted) {
        require(_taskId < taskCount, "Task does not exist");
        Task memory task = tasks[_taskId];
        description=task.description;
        isCompleted=task.isCompleted;
        return (description, isCompleted);
    }

    // Function to get the total number of tasks
    function getTaskCount() public view returns (uint256) {
        return taskCount;
    }
}


