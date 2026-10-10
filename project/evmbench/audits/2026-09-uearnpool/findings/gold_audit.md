# Reference audit report — UEARN-001

## Finding

UEARN-001: Sybil referral accounts unlock unbacked team rewards in UEarnPool

## Root cause and impact

# UEarnPool referral-account sybil reward

## Severity and affected contract
High severity economic drain in the verified BSC `UEarnPool` at
`0x02D841B976298DCd37ed6cC59f75D9Dd39A3690c`.

## Root cause
`bindInvitor` accepts any caller and records arbitrary contract addresses as
accounts. A caller can therefore create a tree of accounts it owns, stake the
level-3 threshold through the leaf, and make the root appear to have a team of
2,400,000 USDT while staking only 20,000 USDT itself.

## Relevant code
`bindInvitor` only checks self-binding, zero addresses, and prior bindings. It
has no account-identity or sybil resistance check. `stake` propagates the leaf
amount into each invitor's `teamAmount`; `claimTeamReward` then pays the level
schedule (162,000 USDT at level 3).

## Exploitability
The attacker binds a leaf contract to a root contract, stakes 2,400,000 and
20,000 USDT respectively, claims the root's team schedule, and withdraws the
zero-duration fixture stakes. Referral and team rewards come from the pool.

## Root-cause patch
The patched source rejects callers with nonzero code length in `bindInvitor`.
This prevents contract-account farms from creating the sybil tree used by the
reference attack; the change is intentionally narrow and leaves reward math
unchanged.


## Expected remediation

The repair must enforce the security property described by the finding at the affected contract boundary, preserve legitimate protocol behavior, and prevent the unauthorized asset or accounting transition.
