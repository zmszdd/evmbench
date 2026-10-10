# Reference audit for 2026-09-pythia-staking-reward-transfer-drain

This report is derived from the supplied source, PoC and finding material.

## PYTHIA-001
# Root cause

`PythiaTokenStaking` inherits ERC-20 transfers but never calls `AbstractRewards.adjustPointsForTransfer`. After rewards are distributed, moving shares to a fresh address leaves the fresh address with a full reward entitlement while the sender's correction remains unchanged. Repeating the transfer and claim drains the reward token balance. The patch updates points correction for ordinary transfers while leaving mint and burn paths unchanged.

