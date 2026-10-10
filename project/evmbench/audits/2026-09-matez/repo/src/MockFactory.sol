// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

/// @dev Minimal deterministic stand-in for the external Uniswap V3 factory.
/// It returns one preconfigured observation pool for every lookup; it does not
/// alter quote arithmetic or provide any token balances.
contract MockFactory {
    address public immutable configuredPool;
    constructor(address pool_) { configuredPool = pool_; }
    function getPool(address, address, uint24) external view returns (address) {
        return configuredPool;
    }
}
