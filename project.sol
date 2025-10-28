// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Decentralized Fund
 * @dev A simple decentralized funding smart contract where users can contribute ETH
 *      to support a project, and the owner can withdraw the funds once the goal is met.
 */
contract Project {
    address public owner;
    uint256 public fundingGoal;
    uint256 public totalFunds;
    bool public goalReached;
    bool public fundsWithdrawn;

    mapping(address => uint256) public contributions;

    event Funded(address indexed contributor, uint256 amount);
    event GoalReached(uint256 totalFunds);
    event FundsWithdrawn(address indexed owner, uint256 amount);
    event Refunded(address indexed contributor, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor(uint256 _fundingGoal) {
        owner = msg.sender;
        fundingGoal = _fundingGoal;
    }

    /**
     * @dev Allow users to contribute ETH to the project.
     */
    function contribute() external payable {
        require(msg.value > 0, "Must send ETH");
        require(!goalReached, "Funding goal already reached");

        contributions[msg.sender] += msg.value;
        totalFunds += msg.value;

        emit Funded(msg.sender, msg.value);

        if (totalFunds >= fundingGoal) {
            goalReached = true;
            emit GoalReached(totalFunds);
        }
    }

    /**
     * @dev Allow the project owner to withdraw funds once the goal is reached.
     */
    function withdrawFunds() external onlyOwner {
        require(goalReached, "Goal not reached");
        require(!fundsWithdrawn, "Funds already withdrawn");

        uint256 amount = address(this).balance;
        fundsWithdrawn = true;
        payable(owner).transfer(amount);

        emit FundsWithdrawn(owner, amount);
    }

    /**
     * @dev Allow contributors to request refunds if the goal is not reached.
     */
    function refund() external {
        require(!goalReached, "Goal was reached, no refunds available");
        uint256 amount = contributions[msg.sender];
        require(amount > 0, "No contribution to refund");

        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(amount);

        emit Refunded(msg.sender, amount);
    }
}
