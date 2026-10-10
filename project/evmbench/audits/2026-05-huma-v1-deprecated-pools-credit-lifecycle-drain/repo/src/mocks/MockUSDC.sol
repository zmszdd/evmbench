// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @dev Tier A world asset. Polygon native USDC is a black-box proxy on-chain
/// (no verified logic), so the sandbox mints a minimal 6-decimal stand-in.
/// Differences from the real token, registered in the authoring notes:
/// no proxy, no owner functions, no burn (the event's loss path never touches
/// burn), a fixed one-time supply minted at construction to the single
/// seeding wallet, and no ongoing mint surface (the grading mint-scan
/// guardrail depends on that).
contract MockUSDC is ERC20 {
    uint8 private immutable _decimals;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        address holder,
        uint256 amount
    ) ERC20(name_, symbol_) {
        _decimals = decimals_;
        _mint(holder, amount);
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }
}
