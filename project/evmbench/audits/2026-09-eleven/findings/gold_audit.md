# Reference audit report — ELEVEN-001

## Finding

ELEVEN-001: Eleven Finance vault emergencyBurn share accounting

## Root cause and impact

# ElevenNeverSellVault emergency exit accounting

## Severity
High: a holder can redeem the same vault shares twice and drain strategy liquidity.

## Vulnerable code
`emergencyBurn()` reads `balanceOf(msg.sender)`, withdraws that many underlying tokens, and transfers them to the caller, but never calls `_burn` or otherwise decreases the caller's share balance. `withdrawAll()` subsequently sees the unchanged balance and executes a second withdrawal.

## Why exploitable
The vault's normal `withdraw` burns shares before obtaining strategy liquidity. The emergency path omits that accounting effect. A user can deposit LP tokens, invoke the emergency path, then invoke the ordinary exit while still holding the original shares. The deterministic strategy fixture retains enough reserve for both calls and restricts withdrawals to the vault, so the measured loss is attributable to this vault bug.

## Root-cause fix
Burn the caller's shares in `emergencyBurn()` before transferring the underlying. This is the minimal differential patch and leaves normal deposits and withdrawals unchanged.


## Expected remediation

The repair must enforce the security property described by the finding at the affected contract boundary, preserve legitimate protocol behavior, and prevent the unauthorized asset or accounting transition.
