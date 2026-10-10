# Sharwa spot-quoter collateral valuation

**Severity:** Critical. **Verified contract:** `UniswapModuleWithoutChainlink` at `0x729cf665c09ef112c607290415a566fffa45826f` (Arbitrum, Sourcify exact match).

`UniswapModuleBase.getInputPositionValue` returns `quoter.quoteExactInput(path, amountIn)`. The path is a Uniswap V3 spot path and the result is consumed as a collateral value. A thin pool can be moved before the valuation call, so a temporary spot price is accepted as solvency. The local lending harness uses this verified function to size a USDC borrow.

The root-cause patch fails closed on this spot valuation; production remediation should replace it with a time-weighted or independent oracle and freshness checks. The patch file is a minimal differential substitute for the verified module.
