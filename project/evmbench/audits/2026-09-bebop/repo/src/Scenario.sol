// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;
import {JamSettlement} from "./JamSettlement.sol";
import {MockUSDC} from "./MockUSDC.sol";
/// @notice Isolated Bebop world: a user balance approved the verified settlement contract.
contract Scenario {
    MockUSDC public immutable usdc;
    JamSettlement public immutable settlement;
    uint256 public immutable seededFunds;
    constructor() {
        seededFunds = 1_000_000 * 10 ** 6;
        usdc = new MockUSDC(seededFunds, address(this));
        settlement = new JamSettlement(address(0), address(0), address(0));
        usdc.approve(address(settlement), type(uint256).max);
    }
    function victimFundsHeld() external view returns (uint256) { return usdc.balanceOf(address(this)); }
}
