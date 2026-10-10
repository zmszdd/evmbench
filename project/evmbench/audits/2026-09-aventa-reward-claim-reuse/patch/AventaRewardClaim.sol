// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import "./MockERC20.sol";

/// Root-cause repair: eligibility is an owner-bound allocation. A transient
/// balance in a fresh helper is not sufficient to claim; each beneficiary must
/// be registered once with a fixed allocation before the claim window.
contract AventaRewardClaim {
    address public owner;
    MockERC20 public intelliQuant;
    MockERC20 public aventa;
    mapping(address => uint256) public allocation;
    mapping(address => bool) public claimed;
    bool public paused;
    constructor(address oldToken, address rewardToken, address owner_) { owner = owner_; intelliQuant = MockERC20(oldToken); aventa = MockERC20(rewardToken); }
    modifier onlyOwner() { require(msg.sender == owner, "owner"); _; }
    function register(address user, uint256 amount) external onlyOwner { require(!claimed[user], "claimed"); allocation[user] = amount; }
    function claim(address user) external {
        require(!paused && user == msg.sender, "unauthorized");
        uint256 amount = allocation[user]; require(amount > 0 && !claimed[user], "No available");
        claimed[user] = true; allocation[user] = 0;
        require(aventa.transferFrom(owner, user, amount), "transfer failed");
    }
    function approveOwner(address spender, uint256 amount) external onlyOwner { aventa.approve(spender, amount); }
    function pause() external onlyOwner { paused = true; }
}
