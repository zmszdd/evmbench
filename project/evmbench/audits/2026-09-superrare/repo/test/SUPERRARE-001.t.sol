// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "../src/RareStakingV1.sol";
import "../src/RareToken.sol";
interface IRareRootUpdater { function updateMerkleRoot(bytes32) external; }
contract RareRootAttacker {
 function update(address staking, bytes32 root) external { IRareRootUpdater(staking).updateMerkleRoot(root); }
}
contract SuperRarePatchTest {
 function test_SUPERRARE_001_restricts_merkle_root_update() public {
  RareToken token = new RareToken(1_000 ether);
  RareStakingV1 staking = new RareStakingV1(address(token), address(0xBEEF));
  RareRootAttacker attacker = new RareRootAttacker();
  bytes32 originalRoot = staking.currentClaimRoot();
  (bool ok,) = address(attacker).call(abi.encodeCall(attacker.update, (address(staking), bytes32(uint256(1)))));
  require(!ok, "outsider changed merkle root");
  require(staking.currentClaimRoot() == originalRoot, "root changed despite rejected update");
 }
}
