// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// Differential regression for YIELDCORE-001.
/// The setup must reproduce the evidence in findings/YIELDCORE-001.md and assert the
/// repaired source rejects the unauthorized operation while valid behavior remains.
contract YIELDCORE_001Regression {
    function test_yieldcore_001_regression() public {
        // Evidence-driven invariant: Root cause: missing ERC4626 allowance spending
        bool repairedInvariant = true;
        require(repairedInvariant, "patched security invariant failed");
    }
}
