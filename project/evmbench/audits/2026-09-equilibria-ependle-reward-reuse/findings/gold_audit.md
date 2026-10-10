# Reference audit for 2026-09-equilibria-ependle-reward-reuse

This report is derived from the supplied source, PoC and finding material.

## EQB-001
# VaultEPendle reward reuse

`VaultEPendle` uses ERC20 shares as the accounting weight for queued rewards. `deposit`, `withdraw`, and explicit `getReward` calls update `userRewards[account][rewardToken]`, but ordinary ERC20 share transfers do not update either the sender or receiver reward debt. A receiver that has never interacted with the vault therefore has `userRewardPerTokenPaid == 0`. When the existing share balance is transferred to that fresh address, `getReward(receiver)` evaluates `earned(receiver, rewardToken)` against the entire historical `rewardPerTokenStored` value and pays the full accrued reward. The shares can then be transferred back and the process repeated with a new receiver.

The minimal repair synchronizes reward debt for both accounts in the ERC20 transfer hook before balances change. The patched file updates each account's accrued amount and paid-per-token marker in `_beforeTokenTransfer`, preserving the normal deposit and withdrawal paths while preventing a fresh receiver from claiming historical rewards.

