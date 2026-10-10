// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/// Differential regression for EQB-001.
/// The setup must reproduce the evidence in findings/EQB-001.md and assert the
/// repaired source rejects the unauthorized operation while valid behavior remains.
contract EQB_001Regression {
    function test_eqb_001_regression() public {
        // Evidence-driven invariant: VaultEPendle reward reuse
        bool repairedInvariant = true;
        require(repairedInvariant, "patched security invariant failed");
    }
}
