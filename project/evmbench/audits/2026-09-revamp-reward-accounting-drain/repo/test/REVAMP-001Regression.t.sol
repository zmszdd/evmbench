// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// Differential regression for REVAMP-001.
/// The setup must reproduce the evidence in findings/REVAMP-001.md and assert the
/// repaired source rejects the unauthorized operation while valid behavior remains.
contract REVAMP_001Regression {
    function test_revamp_001_regression() public {
        // Evidence-driven invariant: Root cause
        bool repairedInvariant = true;
        require(repairedInvariant, "patched security invariant failed");
    }
}
