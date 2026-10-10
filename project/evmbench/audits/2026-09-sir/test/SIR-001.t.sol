// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../src/Scenario.sol";

contract SIR001PatchTest {
 function test_SIR_001_callback_cannot_cross_storage_boundary() public {
  Scenario scenario = new Scenario();
  LeverageSIR vault = scenario.vault();
  uint256 beforeBalance = scenario.usdc().balanceOf(address(vault));
  bytes memory data = abi.encode(address(scenario.usdc()), address(this));
  (bool ok,) = address(vault).call(abi.encodeWithSignature(
   "uniswapV3SwapCallback(int256,int256,bytes)", int256(0), int256(0), data
  ));
  require(!ok, "unauthenticated callback transferred vault assets");
  require(scenario.usdc().balanceOf(address(vault)) == beforeBalance, "vault balance changed");
 }
}
