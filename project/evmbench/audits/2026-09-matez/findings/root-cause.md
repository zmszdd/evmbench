# Matez staking integer-truncation finding

## Severity and affected code

High severity: an unprivileged account can satisfy referral reward thresholds
without transferring the corresponding deposit token. The affected contract is
`MatezStakingProgram` at BSC address `0x326FB70eF9e70f8f4c38CFbfaF39F960A5C252fa`,
with verified source from Sourcify (compiler 0.7.6).

## Vulnerable operation

`stake(uint256 amnt)` passes `uint128(amnt)` to `estimateAmountOut`, then calls
`depositToken.transferFrom` for that quoted amount. The function subsequently
credits the original `amnt` to `selfInvest`, sponsor `directInvest`, and team
accounting. Solidity 0.7's explicit narrowing conversion silently discards the
upper bits, so `amnt = 2^128` is quoted as zero while the full 2^128 is recorded.

## Exploitability

The attacker registers under the initialized user, stakes the truncating value,
and creates 25 referral users that repeat the same zero-transfer stake. Referral
counts, generation depth, direct investment, and team investment then satisfy
reward package 1. `claim(3, 1, 0)` transfers the configured 200 MATEZ-equivalent
deposit tokens from the staking contract. The reference executor sweeps those
tokens to the attacker wallet.

## Root-cause patch

The patched source rejects any `amnt` outside the quote function's `uint128`
range before mutating accounting state. This preserves the existing quote path
and prevents a value from being credited at a different magnitude than the
transfer calculation. A production redesign could instead implement a full
`uint256` quote path, but that is broader than the minimal root-cause fix.

## Deterministic fixture scope

The staking contract and Uniswap math/interfaces are the verified sources.
The task uses three small fixtures for unavailable external deployment state:
`MockERC20` supplies ordinary BEP-20 balances, `MockFactory` returns the fixture
pool, and `MockPool.observe` reports a stationary tick of zero. None mints during
the attack, changes quote arithmetic, or supplies an anomalous transfer path.
