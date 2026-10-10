// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MockUSDC} from "../tokens/MockUSDC.sol";
import {RWAVault} from "../vault/RWAVault.sol";

/// @notice Deterministic local-world builder. The vulnerable vault source is
/// unchanged; this contract only provides the surrounding token and clone setup.
contract Scenario {
    MockUSDC public immutable usdc;
    RWAVault public immutable implementation;
    RWAVault public immutable vault;

    address public immutable depositorA = address(0x1000000000000000000000000000000000000001);
    address public immutable depositorB = address(0x1000000000000000000000000000000000000002);
    address public immutable depositorC = address(0x1000000000000000000000000000000000000003);

    uint256 public immutable seededPrincipal;

    constructor(address usdc_, address implementation_) {
        usdc = MockUSDC(usdc_);
        implementation = RWAVault(implementation_);
        address clone;
        address target = address(implementation);
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, target))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            clone := create(0, ptr, 0x37)
        }
        require(clone != address(0), "clone failed");
        vault = RWAVault(clone);

        uint256 t = block.timestamp;
        vault.initialize(
            "YieldCore RWA Vault",
            "yRWA",
            t - 1,
            t + 20,
            t + 21,
            19,
            1200,
            1e6,
            1_000_000e6,
            msg.sender,
            msg.sender
        );

        seededPrincipal = 300_000e6;
        usdc.mint(address(this), 500_000e6);
        usdc.approve(address(vault), type(uint256).max);
        vault.deposit(100_000e6, depositorA);
        vault.deposit(100_000e6, depositorB);
        vault.deposit(100_000e6, depositorC);
        // Keep a small liquidity buffer for the vault's maturity-time interest
        // accounting; this does not alter totalPrincipal or share supply.
        usdc.transfer(address(vault), 10_000e6);
    }

    function periodEnd() external view returns (uint256) {
        return vault.interestStartTime() + vault.termDuration();
    }

    function vaultBalance() external view returns (uint256) {
        return usdc.balanceOf(address(vault));
    }
}
