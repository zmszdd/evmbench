# Reference audit report — KAME-001

## Finding

KAME-001: AggregationRouter executes arbitrary calldata as an untrusted executor

## Root cause and impact

# KAME-001 — arbitrary executor call drains approved USDC

## Severity and affected contract

Critical loss of any ERC-20 allowance granted to the verified Sei
`AggregationRouter` at `0x14bb98581Ac1F1a43fD148db7d7D793308Dc4d80`. The
verified contract is `src/AggregationRouter.sol` (compiler 0.8.26, optimizer
200 runs; source verified by SeiScan).

## Root cause

`swap` copies `params.executor` and `params.executeParams` supplied by the
caller, then invokes `params.executor.call(...)`. The only source-token action
before that call is skipped when `params.amount` is zero. There is no allowlist,
selector restriction, or consistency check tying the executor call to the swap
parameters. A caller can therefore select an ERC-20 token as executor and make
the router call `transferFrom(victim, recipient, amount)`. The token sees the
router as `msg.sender`, so a prior victim approval authorizes the drain.

## Exploitability and accounting

The isolated world seeds 1,000,000 USDC (six decimals) in `Scenario`, which
approves the router for the maximum allowance. The reference transaction uses
`amount = 0`, sets the executor to the USDC contract, and encodes
`transferFrom(Scenario, exploitWallet, 1_000,000e6)`. The victim balance falls
by exactly that amount and the exploit wallet gains the same amount. No supply
is minted or burned.

## Fix

The patched source records the deployment-time trusted executor and rejects any
swap whose executor is different before making the external call. This closes
the arbitrary-target call primitive at its root; the reference transaction's
executor is the USDC token and therefore reverts on the patched build.

## Source and mock boundary

`AggregationRouter.sol`, its interfaces, `UniERC20`, and the OpenZeppelin
support files are the exact verified source snapshot. `MockUSDC.sol` is a
minimal standard ERC-20 used to create deterministic local state; it has fixed
supply, ordinary allowance accounting, and no mint or burn entry point. It
stands in for the real USDC token only because the task runs offline and does
not recreate Sei's historical state.


## Expected remediation

The repair must enforce the security property described by the finding at the affected contract boundary, preserve legitimate protocol behavior, and prevent the unauthorized asset or accounting transition.
