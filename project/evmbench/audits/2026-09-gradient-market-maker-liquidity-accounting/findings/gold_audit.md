# Reference audit for 2026-09-gradient-market-maker-liquidity-accounting

This report is derived from the supplied source, PoC and finding material.

## GRADIENT-001
# GradientMarketMakerPool reward accounting

`GradientMarketMakerPool` stores two different units for a market maker: the deposited token-plus-ETH amount and `lpShares`. The share count is computed from the pool's total share and liquidity counters. The orderbook entry points update `totalLiquidity` and `totalEth` without minting or burning LP shares, so these counters can diverge during normal protocol operation.

On a later withdrawal the vulnerable implementation computes pending rewards as `userLiquidity * accRewardPerShare / SCALE`, while rewards are distributed per LP share. When `totalLiquidity` is increased without shares, a user's LP shares are smaller than their recorded liquidity, and the bookkeeping path can credit an amount that is not backed by that user's share. A partial withdrawal stores the inflated pending amount; a subsequent full withdrawal transfers it as ETH.

The minimal fix is to use `mm.lpShares` for pending reward computation and to update partial-withdrawal `rewardDebt` in the same unit. The patch in `patch/GradientMarketMakerPool.sol` makes those two substitutions. The fixture's router, factory, pair, registry, and token only provide protocol surroundings; the vulnerable logic remains the verified GradientMarketMakerPool source.

