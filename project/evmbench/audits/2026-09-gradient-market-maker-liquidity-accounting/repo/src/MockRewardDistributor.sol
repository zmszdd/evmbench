// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
interface IRewardPool { function receiveFeeDistribution(address token) external payable; }
contract MockRewardDistributor {
    receive() external payable {}
    function distribute(address pool,address token,uint256 amount) external { IRewardPool(pool).receiveFeeDistribution{value:amount}(token); }
}
