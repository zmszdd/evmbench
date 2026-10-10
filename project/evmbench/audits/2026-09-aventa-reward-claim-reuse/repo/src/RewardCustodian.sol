// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import "./MockERC20.sol";

/// Inert victim wallet: it approves only the reward claim contract at
/// construction and exposes no transfer/sweep method to the exploit wallet.
contract RewardCustodian {
    MockERC20 public immutable reward;
    address public immutable spender;
    bool public initialized;
    constructor(address reward_, address spender_) { reward = MockERC20(reward_); spender = spender_; }
    function approveClaim() external { require(!initialized, "initialized"); initialized = true; reward.approve(spender, type(uint256).max); }
}
