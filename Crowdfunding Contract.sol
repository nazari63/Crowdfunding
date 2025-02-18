// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Crowdfunding {
    address public admin;
    uint public goal;
    uint public raisedAmount;
    uint public deadline;
    
    mapping(address => uint) public contributions;

    event ContributionMade(address indexed contributor, uint amount);
    event GoalReached(uint totalAmountRaised);
    event RefundIssued(address indexed contributor, uint amount);

    constructor(uint _goal, uint _duration) {
        admin = msg.sender;
        goal = _goal;
        deadline = block.timestamp + _duration;
    }

    function contribute() external payable {
        require(block.timestamp < deadline, "The campaign has ended");
        require(raisedAmount < goal, "The goal has already been reached");

        contributions[msg.sender] += msg.value;
        raisedAmount += msg.value;

        emit ContributionMade(msg.sender, msg.value);

        if (raisedAmount >= goal) {
            emit GoalReached(raisedAmount);
        }
    }

    function issueRefund() external {
        require(block.timestamp > deadline, "Campaign is still ongoing");
        require(raisedAmount < goal, "Goal was reached, no refunds");

        uint refundAmount = contributions[msg.sender];
        require(refundAmount > 0, "No contributions to refund");

        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(refundAmount);

        emit RefundIssued(msg.sender, refundAmount);
    }

    function getCampaignStatus() external view returns (uint, uint, uint, uint) {
        return (raisedAmount, goal, deadline, block.timestamp);
    }
}