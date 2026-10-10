# Reference audit for 2026-09-yieldcore-rwavault-unauthorized-withdrawal

This report is derived from the supplied source, PoC and finding material.

## YIELDCORE-001
# Root cause: missing ERC4626 allowance spending

`RWAVault` overrides both `withdraw(uint256 assets,address receiver,address owner)` and
`redeem(uint256 shares,address receiver,address owner)`. They read
`_depositInfos[owner]`, burn the owner's shares, and transfer USDC to `receiver`,
but never enforce the ERC4626 delegated-withdraw rule:

```solidity
if (msg.sender != owner) {
    _spendAllowance(owner, msg.sender, shares);
}
```

Consequently any account can pass another depositor as `owner` and itself as
`receiver`. The vault burns the victim's shares and pays the corresponding
principal without an approval. The missing check is the complete authorization
boundary; phase and liquidity checks do not distinguish the caller from the
share owner.

The minimal repair is to spend allowance in both functions after computing the
final share amount and before mutating/burning the owner's shares. A direct owner
call remains valid because no allowance is consumed.


