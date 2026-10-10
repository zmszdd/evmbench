// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IOxiumMgvCore {
    type Tick is int256;

    struct OLKey {
        address outbound_tkn;
        address inbound_tkn;
        uint256 tickSpacing;
    }

    ///@notice Performs a market order on a specified offer list taking offers up to a limit price.
    ///@param olKey The offer list key given by (maker) `outbound_tkn`, (maker) `inbound_tkn`, and `tickSpacing`.
    ///@param maxTick Must be `>= MIN_TICK` and `<= MAX_TICK`. The log of the limit price the taker is ready to pay (meaning: the log base 1.0001 of the ratio of inbound tokens over outbound tokens).
    ///@param fillVolume Must be `<= MAX_SAFE_VOLUME`. If `fillWants` is true, the amount of `olKey.outbound_tkn` the taker wants to buy; otherwise, the amount of `olKey.inbound_tkn` the taker wants to sell.
    ///@param fillWants If true, the matching engine tries to get the taker all they want; otherwise, the matching engine tries to sell all that the taker gives. In both cases subject to the price limit.
    ///@return takerGot The amount of `olKey.outbound_tkn` the taker got.
    ///@return takerGave The amount of `olKey.inbound_tkn` the taker gave.
    ///@return bounty The amount of native token the taker got as a bounty due to failing offers (in wei).
    ///@return feePaid The amount of `olKey.outbound_tkn` the taker paid as a fee to Mangrove.
    ///@dev The market order stops when there are no more offers at or below `maxTick`, when the end of the book has been reached, or:
    ///@dev - If `fillWants` is true, the market order stops when `fillVolume` units of `olKey.outbound_tkn` have been obtained. To buy a specific volume of `olKey.outbound_tkn` at any price, set `fillWants` to true, set `fillVolume` to the volume you want to buy, and set `maxTick` to the `MAX_TICK` constant.
    ///@dev - If `fillWants` is false, the market order stops when `fillVolume` units of `olKey.inbound_tkn` have been paid. To sell a specific volume of `olKey.inbound_tkn` at any price, set `fillWants` to false, set `fillVolume` to the volume you want to sell, and set `maxTick` to the `MAX_TICK` constant.
    function marketOrderByTick(OLKey memory olKey, Tick maxTick, uint256 fillVolume, bool fillWants)
        external
        returns (uint256 takerGot, uint256 takerGave, uint256 bounty, uint256 feePaid);
}
