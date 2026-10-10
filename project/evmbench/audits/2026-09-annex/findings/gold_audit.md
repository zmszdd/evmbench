# Reference audit report — ANNEX-001

## Finding

ANNEX-001: Annex Liquidator accepts attacker-created factory pairs and attacker-controlled callback metadata

## Root cause and impact

# ANNEX-001 — unbound Liquidator callback pair and metadata

## Severity and affected contract

High impact: the verified BSC `Liquidator` at
`0xe65E970F065643bA80E5822edfF483A1d75263E3` can be induced to pay its full
WBNB inventory to an attacker-created Pancake pair. The supplied Sourcify v2
artifact (`matchId 7057616`) is the complete flattened `Liquidator.sol` source.

## Root cause

`pancakeCall` checks only `msg.sender == Factory.getPair(token0, token1)`. That
condition proves that the caller is registered in the factory, but does not
prove that it is the pair selected by an in-progress liquidation. The callback
also decodes `_borrower`, `_repayAToken`, and `_seizeAToken` from caller-supplied
bytes. When the two token addresses are an attacker-controlled no-op contract,
the liquidation and redemption calls do nothing, yet the callback still
executes:

```solidity
IERC20(estuary).transfer(msg.sender, (amount * 1000 / 997) + 1);
```

A malicious pair can therefore send WBNB to the Liquidator, invoke the callback,
and receive the Liquidator's pre-existing WBNB balance plus the fee. The attacker
then exits the pair and keeps the WBNB.

## Reproduction model

`repo/src/Liquidator.sol` is the verified source. `repo/src/Mocks.sol` contains
small local WBNB, factory, pair, and no-op aToken fixtures. The fixtures replace
BSC dependencies at their original constant addresses; they do not add minting
or callback behavior to Liquidator. The scenario seeds 8 WBNB in the Liquidator
and in the attacker-controlled pair.

## Root-cause patch

`patch/Liquidator.sol` records the pair selected by `liquidate()` in
`activePair` and requires `pancakeCall` to originate from that exact pair before
processing metadata. The same gold callback made directly by an arbitrary pair
therefore reverts, while a legitimate `liquidate()`-initiated callback remains
possible.


## Expected remediation

The repair must enforce the security property described by the finding at the affected contract boundary, preserve legitimate protocol behavior, and prevent the unauthorized asset or accounting transition.
