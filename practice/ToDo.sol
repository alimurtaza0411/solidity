// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.7.0;
pragma experimental ABIEncoderV2;
contract ToDo{
    struct Task{
        uint taskId;
        uint date;      //timestamp of creation
        uint timeSpam;  //timestamp of end of task
        address creator;
        string author;
        string content;
        bool completed;
        bool overdue;
    }
    Task[] tasks;
    constructor() public{}
    
    modifier onlyCreator( uint taskNumber) {
        require(tasks[taskNumber-1].creator == msg.sender, "This Task does not belong to you");
        _;
    }
    modifier checkOverdue(uint taskNumber) {
        if (tasks[taskNumber-1].timeSpam <= now &&  tasks[taskNumber-1].overdue == true ){
            tasks[taskNumber-1].overdue = true;
        }
        _;

    }

    function addTask(uint _timeSpam_inDays, string memory _author, string memory _content) public returns (uint, uint, uint) {
        tasks.push(Task(tasks.length, now, now+(_timeSpam_inDays*86400), msg.sender, _author, _content, false,false));
        return (tasks.length, tasks[tasks.length-1].date, tasks[tasks.length-1].timeSpam) ;
    }
    
    function getTask(uint taskNumber ) public onlyCreator(taskNumber) checkOverdue(taskNumber) returns (Task memory) {
        return tasks[taskNumber-1];
    }
    
    function markComplete(uint taskNumber) public onlyCreator(taskNumber) checkOverdue(taskNumber) returns(bool){
        tasks[taskNumber-1].completed = true;
    }
}    