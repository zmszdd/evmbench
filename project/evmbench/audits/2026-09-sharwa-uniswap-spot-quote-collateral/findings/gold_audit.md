# Reference audit for 2026-09-sharwa-uniswap-spot-quote-collateral

This report is derived from the supplied source, PoC and finding material.

## SHARWA-001
# Root cause

The verified `UniswapModuleBase` stores a Uniswap V3 path and implements `getInputPositionValue` by calling `quoter.quoteExactInput` on the current pool state. The function has no TWAP, Chainlink, or deviation bound. Sharwa uses this value while valuing collateral, so a flash swap that moves a thin USDC/USDC.e pool can make a Hegic option appear much more valuable and unlock excess borrowing. The patch adds a deviation guard in the benchmark module; production remediation should use a manipulation-resistant oracle.

