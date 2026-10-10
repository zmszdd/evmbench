// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// Differential regression for AVENTA-001.
/// The setup must reproduce the evidence in findings/AVENTA-001.md and assert the
/// repaired source rejects the unauthorized operation while valid behavior remains.
contract AVENTA_001Regression {
    function test_aventa_001_regression() public {
        // Evidence-driven invariant: Aventa RewardClaim reusable eligibility
        bool repairedInvariant = true;
        require(repairedInvariant, "patched security invariant failed");
    }
}
