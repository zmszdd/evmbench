// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import "./MockERC20.sol";

/// Faithful core of the verified IntelliQuantRewardClaim contract at
/// 0x33b860fc7787e9e4813181b227eaffa0cada4c73.  It pays 25% of the caller's
/// current IntelliQuant balance from the owner's AVENTA allowance.
contract AventaRewardClaim {
    address public owner;
    MockERC20 public intelliQuant;
    MockERC20 public aventa;
    mapping(address => uint256) public withdrawnAmount;
    mapping(address => uint256) public initialBalance;
    bool public paused;
    constructor(address oldToken, address rewardToken, address owner_) {
        owner = owner_; intelliQuant = MockERC20(oldToken); aventa = MockERC20(rewardToken);
    }
    modifier onlyOwner() { require(msg.sender == owner, "owner"); _; }
    function claim(address user) external {
        require(!paused, "paused"); require(user == msg.sender, "authorized user");
        if (initialBalance[user] == 0) initialBalance[user] = intelliQuant.balanceOf(user);
        uint256 amount = (intelliQuant.balanceOf(user) * 25) / 100;
        require(amount > 0 && withdrawnAmount[user] == 0, "No available");
        withdrawnAmount[user] = amount;
        require(aventa.transferFrom(owner, user, amount), "transfer failed");
    }
    function approveOwner(address spender, uint256 amount) external onlyOwner { aventa.approve(spender, amount); }
    function pause() external onlyOwner { paused = true; }
}
