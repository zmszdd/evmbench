# Reference audit for 2026-09-matez-staking-integer-truncation

This report is derived from the supplied source, PoC and finding material.

## MATEZ-001
# Root cause

`MatezStakingProgram.stake(uint256)` converts the caller's amount to `uint128` only when calculating the token transfer, then records the original `uint256` in `selfInvest`, `directInvest`, `teamInvest`, and the order. An amount of `2**128` therefore transfers zero deposit tokens while satisfying the level requirements used by `claim(3, 1, 0)`. Twenty-five zero-cost referrals are enough to meet the direct, team, and generation thresholds, so the contract transfers the level-1 reward from its funded balance. The fix rejects values that cannot be represented by the transfer amount before any accounting is updated.

