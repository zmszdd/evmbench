# SWAPP Staking emergency withdrawal

The pinned PoC deposits the staking contract's cUSDC balance through the generic deposit path and invokes `emergencyWithdraw`. The verified source treats any token outside the three stablecoin constants as an emergency-withdrawable asset, while cUSDC is a Compound receipt token used by the protocol. The complete verified source and original PoC are included for review.
