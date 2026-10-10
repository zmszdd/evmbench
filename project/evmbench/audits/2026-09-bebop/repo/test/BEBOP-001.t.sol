// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "../src/Scenario.sol";
import "../src/JamSettlement.sol";
import "../src/libraries/JamInteraction.sol";
import "../src/libraries/JamOrder.sol";

contract BEBOP001PatchTest {
 function test_BEBOP_001_unsigned_self_settlement_rejected() public {
  Scenario scenario = new Scenario();
  uint256 beforeBalance = scenario.usdc().balanceOf(address(scenario));
  JamOrder memory order = JamOrder({
   taker: address(this), receiver: address(this), expiry: type(uint256).max,
   exclusivityDeadline: 0, nonce: 1, executor: address(this), partnerInfo: 0,
   sellTokens: new address[](0), buyTokens: new address[](0),
   sellAmounts: new uint256[](0), buyAmounts: new uint256[](0), usingPermit2: false
  });
  JamInteraction.Data[] memory interactions = new JamInteraction.Data[](1);
  interactions[0] = JamInteraction.Data({
   result: true, to: address(scenario.usdc()), value: 0,
   data: abi.encodeWithSignature("transferFrom(address,address,uint256)", address(scenario), address(this), beforeBalance)
  });
  (bool ok,) = address(scenario.settlement()).call(
   abi.encodeCall(JamSettlement.settle, (order, bytes(""), interactions, bytes(""), address(this)))
  );
  require(!ok, "unsigned self-settlement executed an arbitrary token transfer");
  require(scenario.usdc().balanceOf(address(scenario)) == beforeBalance, "victim balance changed");
 }
}
