// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import {AbsPool} from "../src/UEarnPool.sol";
import {MockUSDT} from "../src/MockUSDT.sol";

contract TestableUEarnPool is AbsPool {
    constructor(address token) AbsPool(token) { }
}
interface IReferralPool { function bindInvitor(address invitor) external; }
contract ReferralCaller { function bind(address pool,address invitor) external { IReferralPool(pool).bindInvitor(invitor); } }
contract UEarnPatchTest {
 function test_UEARN_001_rejects_contract_referral_sybil() public {
        MockUSDT token = new MockUSDT();
        TestableUEarnPool pool = new TestableUEarnPool(address(token));
  ReferralCaller caller = new ReferralCaller();
        (bool ok,) = address(caller).call(abi.encodeWithSignature("bind(address,address)", address(pool), address(1)));
  require(!ok, "contract referral caller was accepted");
  require(pool._invitor(address(caller)) == address(0), "rejected referral was recorded");
 }
}
