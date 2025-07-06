// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SubscriptionService {
    address public owner;
    uint public monthlyFee = 0.01 ether;
    uint public duration = 30 days;

    mapping(address => uint) public subscriptions; // address => expiry timestamp

    event Subscribed(address indexed user, uint expiry);
    event Cancelled(address indexed user);
    event FeeUpdated(uint newFee);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /// Subscribe or renew for 1 month
    function subscribe() external payable {
        require(msg.value == monthlyFee, "Incorrect ETH amount");

        if (block.timestamp > subscriptions[msg.sender]) {
            subscriptions[msg.sender] = block.timestamp + duration;
        } else {
            subscriptions[msg.sender] += duration;
        }

        emit Subscribed(msg.sender, subscriptions[msg.sender]);
    }

    /// Cancel your subscription (no refund, just expires)
    function cancel() external {
        require(subscriptions[msg.sender] > block.timestamp, "Not subscribed");
        subscriptions[msg.sender] = block.timestamp;
        emit Cancelled(msg.sender);
    }

    /// Check if a user is subscribed
    function isSubscribed(address user) public view returns (bool) {
        return subscriptions[user] > block.timestamp;
    }

    /// Owner can update fee
    function updateFee(uint newFeeInWei) external onlyOwner {
        require(newFeeInWei > 0, "Fee must be > 0");
        monthlyFee = newFeeInWei;
        emit FeeUpdated(newFeeInWei);
    }

    /// Withdraw contract balance
    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}
