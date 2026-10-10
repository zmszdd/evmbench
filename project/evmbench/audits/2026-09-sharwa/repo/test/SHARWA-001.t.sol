// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../src/Scenario.sol";

contract SHARWA001PatchTest {
 function test_SHARWA_001_disables_spot_collateral_quote() public {
  Scenario scenario = new Scenario();
  uint256 beforeFunds = scenario.victimFunds();
  scenario.quoter().setRate(100 ether);
  (bool ok,) = address(scenario.lending()).call(abi.encodeWithSignature("borrowAgainst()"));
  require(!ok, "manipulated spot quote authorized borrowing");
  require(scenario.victimFunds() == beforeFunds, "lending reserve changed");
 }
}
