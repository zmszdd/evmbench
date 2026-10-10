# Reference audit for 2026-09-beefy-zaprouter-route-drain

This report is derived from the supplied source, PoC and finding material.

## BEEFY-001
# Root cause

The verified Beefy `executeOrder(Order, Step[])` direct path checks only that
`msg.sender == order.user`. It then executes every caller-supplied `Step` using
an unrestricted low-level call. Since users commonly approve the ZapRouter (or
its token manager) to spend ERC20 shares, a route whose target is an ERC20 and
whose calldata is `transferFrom(victim, attacker, amount)` consumes a victim's
allowance. Empty inputs and a matching output entry let the router forward the
stolen balance to the attacker's recipient. The root fix is to restrict route
targets to reviewed adapters and bind calldata to the order's accounting; an
arbitrary external call must not remain reachable from an allowance-bearing
router.

