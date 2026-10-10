// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {AggregationRouter} from "./AggregationRouter.sol";
import {MockUSDC} from "./MockUSDC.sol";

/// @notice Self-contained world state for the Kame aggregation-router case.
/// The scenario contract represents a user that granted the router an allowance.
contract Scenario {
    MockUSDC public immutable usdc;
    AggregationRouter public immutable router;
    uint256 public immutable seededFunds;
    constructor() {
        seededFunds = 1_000_000 * 10 ** 6;
        usdc = new MockUSDC(seededFunds, address(this));
        router = new AggregationRouter();
        usdc.approve(address(router), type(uint256).max);
    }
    function victimFundsHeld() external view returns (uint256) {
        return usdc.balanceOf(address(this));
    }
}
