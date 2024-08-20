// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";

contract ToDoList is Ownable {
    // Struct to represent a Task
    struct Task {
        string description;
        bool isCompleted;
    }

    // Mapping to store tasks by their ID
    mapping(uint256 => Task) public tasks;
    uint256 private taskCount;

    constructor() Ownable(msg.sender){
        taskCount = 0;
    }

    // Function to add a new task (only owner)
    function addTask(string memory _description) public onlyOwner{
        
        tasks[taskCount] = Task(_description, false);
        taskCount++;
    }

    // Function to toggle the completion status of a task (only owner)
    function toggleTask(uint256 _taskId) public onlyOwner{
        require(_taskId < taskCount, "Task does not exist");
        tasks[_taskId].isCompleted = !tasks[_taskId].isCompleted;
    }

    // Function to get the total number of tasks
    function getTaskCount() public view returns (uint256) {
        return taskCount;
    }
}


