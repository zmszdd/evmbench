# Reference audit report — BEBOP-001

## Finding

BEBOP-001: Unsigned self-settlement permits arbitrary allowance-draining interactions

## Root cause and impact

# BEBOP-001 — unsigned self-settlement drains approved USDC

## Severity and affected contract

Critical loss of ERC-20 allowances granted to the verified Arbitrum Bebop
`JamSettlement` at `0xbeb0b0623f66bE8cE162EbDfA2ec543A522F4ea6`. The settlement
implementation is the Bebop Jam source snapshot at commit `d12ec63`.

## Root cause

`JamValidation.validateOrder` skips signature validation whenever
`order.taker == msg.sender`. `JamSettlement.settle` then executes each
caller-supplied `JamInteraction` with the settlement contract as the caller.
There is no requirement that a self-addressed order contain a signed trade or
non-empty sell/buy legs. A caller can therefore submit an empty order and make
the settlement contract call an ERC-20's `transferFrom(victim, recipient,
amount)`. The token observes the settlement contract as `msg.sender` and uses
the victim's existing allowance.

## Exploitability and accounting

The isolated world seeds 1,000,000 USDC (six decimals) in `Scenario`, approves
`JamSettlement` for the maximum amount, and records the baseline. The reference
sequence uses a helper as both `taker` and `executor`, leaves all order arrays
empty, supplies an empty signature, and submits one interaction targeting
`MockUSDC.transferFrom(Scenario, exploitWallet, 1_000_000e6)`. The victim loses
exactly the amount and the wallet gains it. Total supply is unchanged.

## Fix

The patched `src/base/JamValidation.sol` rejects an empty signature for a
self-addressed order before nonce or interaction processing. A caller must
provide a valid signed order, so the reference unsigned interaction cannot
execute.

## Source and mock boundary

All Bebop settlement, validation, transfer, interface, and library files under
`repo/src` are copied from the public Bebop Jam source snapshot. `MockUSDC.sol`
is a minimal fixed-supply ERC-20 used to construct deterministic offline state;
it has ordinary allowance accounting and no mint or burn entry point.
`Scenario.sol` is benchmark scaffolding that deploys the real settlement and
seeds the mock token; it does not add an attack behavior.


## Expected remediation

The repair must enforce the security property described by the finding at the affected contract boundary, preserve legitimate protocol behavior, and prevent the unauthorized asset or accounting transition.
