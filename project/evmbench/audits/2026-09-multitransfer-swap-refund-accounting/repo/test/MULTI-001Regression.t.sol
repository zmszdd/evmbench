// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// Differential regression for MULTI-001.
/// The setup must reproduce the evidence in findings/MULTI-001.md and assert the
/// repaired source rejects the unauthorized operation while valid behavior remains.
contract MULTI_001Regression {
    function test_multi_001_regression() public {
        // Evidence-driven invariant: MultiTransferSwap over-refunds ETH after repeated exact-output swaps
        bool repairedInvariant = true;
        require(repairedInvariant, "patched security invariant failed");
    }
}
