# Reference audit report — SUPERRARE-001

## Finding

SUPERRARE-001: SuperRare RareStakingV1 unrestricted Merkle root update

## Root cause and impact

# SuperRare RareStakingV1 — unrestricted Merkle-root update

**Severity:** Critical (unauthorized transfer of the complete reward pool)

**Affected contract:** `RareStakingV1`, based on the verified mainnet contract at `0xfFB512B9176D527C5D32189c3e310Ed4aB2Bb9eC` (28 July 2025 incident).

**Root cause.** `updateMerkleRoot` attempted to authorize the owner or the designated updater with `require(msg.sender != owner() || msg.sender != authorized, ...)`. For any caller, at least one of the two addresses differs, so the OR expression is true. An arbitrary caller can therefore replace `currentClaimRoot`.

**Exploitability.** A caller chooses a root equal to the single-leaf commitment `keccak256(abi.encodePacked(caller, amount))`, submits an empty proof, and calls `claim(amount, [])`. The staking contract transfers the requested amount from its RARE balance to the caller. The benchmark seeds the full pool, so the reference path drains it and sweeps the reward to the funded wallet.

**Root-cause patch.** Require equality with an authorized principal: `require(msg.sender == owner() || msg.sender == authorized, "Not authorized to update merkle root");`. Claim verification and accounting remain unchanged.


## Expected remediation

The repair must enforce the security property described by the finding at the affected contract boundary, preserve legitimate protocol behavior, and prevent the unauthorized asset or accounting transition.
