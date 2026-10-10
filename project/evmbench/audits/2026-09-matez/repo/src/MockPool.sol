// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

/// @dev Minimal Uniswap V3 oracle fixture. A stationary tick of zero gives a
/// one-to-one quote while preserving the production observe() call path.
contract MockPool {
    function observe(uint32[] calldata secondsAgos)
        external
        pure
        returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s)
    {
        tickCumulatives = new int56[](secondsAgos.length);
        secondsPerLiquidityCumulativeX128s = new uint160[](secondsAgos.length);
    }
}
