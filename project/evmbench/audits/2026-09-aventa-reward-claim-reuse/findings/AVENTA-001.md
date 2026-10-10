# Aventa RewardClaim reusable eligibility

The verified `AventaRewardClaim.claim` implementation records `initialBalance` and `withdrawnAmount` per address, then computes the payout from the caller's **current** IntelliQuant balance. The `user == msg.sender` check only authenticates the fresh helper itself. An attacker can therefore create a new helper, acquire a temporary eligibility balance, claim 25% AVENTA from the owner's allowance, liquidate it, and repeat indefinitely. No protocol-wide allocation, snapshot, or epoch nonce ties the reward to an eligible beneficiary.

The benchmark seeds the owner's approved Aventa inventory, uses a deterministic exchange for the historical buy/claim/sell loop, and scores only a reduction in that approved inventory plus attacker ETH profit. The patch replaces current-balance eligibility with an owner-registered fixed allocation and one-time `claimed` flag.
