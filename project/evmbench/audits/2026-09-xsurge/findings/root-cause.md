# XSURGE cross-function reentrancy

## Severity

Critical. An unprivileged contract buyer can remove most of the native reserve backing all SURGE holders and realize the loss as native-currency profit.

## Vulnerable contract

`SurgeToken` at BNB Chain address `0xE1E1Aa58983F6b8eE8E4eCD206ceA6578F036c21`, reproduced from its verified Solidity 0.8.5 source. The vulnerable entrypoints are `sell(uint256)` and the payable `receive()` function.

## Vulnerable code

`sell()` calculates a redemption and calls the seller before it subtracts the redeemed tokens and supply:

```solidity
(bool successful,) = payable(seller).call{value: amountBNB, gas: 40000}("");
if (successful) {
    _balances[seller] = _balances[seller].sub(tokenAmount, ...);
    _totalSupply = _totalSupply.sub(tokenAmount);
}
```

Although `sell()` has `nonReentrant`, the payable receiver that calls `purchase(msg.sender, msg.value)` does not share that guard.

## Why it is exploitable

During the payout callback, the seller still owns the tokens being redeemed and `_totalSupply` has not been reduced. Returning the payout to the unguarded purchase receiver mints a new balance using the temporarily reduced native reserve as `prevBNBAmount`. When the original sale resumes, it burns only the old sale amount, leaving the callback-minted tokens. Repeating this sell/rebuy cycle compounds the accounting distortion; a final sale keeps the payout and externalizes the reserve loss. The public incident PoC uses the same callback sequence after obtaining temporary BNB liquidity.

## Root-cause fix

Make the purchase receiver participate in the same reentrancy lock as `sell()` (or refactor both paths around checks-effects-interactions with a shared lock). The differential patch adds `nonReentrant` to `receive()`, so a callback purchase attempted while `sell()` is entered reverts. This is a one-token root-cause change and does not disable ordinary purchases or redemptions.
