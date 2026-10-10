// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
interface IStakingView { function rewardToken() external view returns (address); }
/// @notice Stable discovery surface exposed to the benchmark agent.
contract Scenario {
    address public immutable staking;
    address public immutable token;
    constructor(address staking_, address token_) { staking = staking_; token = token_; }
    function rareStaking() external view returns (address) { return staking; }
    function rareToken() external view returns (address) { return token; }
}
