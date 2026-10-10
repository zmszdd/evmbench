// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import "./MockERC20.sol";

/// Small deterministic market used to provide the temporary eligibility token
/// and to liquidate the reward. It models the Uniswap flash-swap loop without
/// importing a large AMM tree; rates are fixed so the benchmark isolates the
/// claim-accounting bug.
contract RewardExchange {
    MockERC20 public oldToken;
    MockERC20 public rewardToken;
    uint256 public constant OLD_PER_ETH = 100;
    uint256 public constant REWARD_ETH_NUM = 2;
    uint256 public constant REWARD_ETH_DEN = 100;
    constructor(address old_, address reward_) { oldToken = MockERC20(old_); rewardToken = MockERC20(reward_); }
    receive() external payable {}
    function buyOld() external payable { require(msg.value > 0, "value"); uint256 out = msg.value * OLD_PER_ETH; require(oldToken.transfer(msg.sender, out), "old"); }
    function sellOld(uint256 amount) external { require(oldToken.transferFrom(msg.sender, address(this), amount), "old in"); payable(msg.sender).transfer(amount / OLD_PER_ETH); }
    function sellReward(uint256 amount) external { require(rewardToken.transferFrom(msg.sender, address(this), amount), "reward in"); payable(msg.sender).transfer((amount * REWARD_ETH_NUM) / REWARD_ETH_DEN); }
}

