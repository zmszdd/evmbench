// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Carbon Controller interface
 */
interface ICarbonController {
    type Token is address;

    struct TradeAction {
        uint256 strategyId;
        uint128 amount;
    }

    /**
     * @dev performs a trade by specifying a fixed source amount
     *
     * notes:
     *
     * - excess native token is returned to the sender if any
     *
     * requirements:
     *
     * - the caller must have approved the source token
     */
    function tradeBySourceAmount(
        Token sourceToken,
        Token targetToken,
        TradeAction[] calldata tradeActions,
        uint256 deadline,
        uint128 minReturn
    ) external payable returns (uint128);
}
