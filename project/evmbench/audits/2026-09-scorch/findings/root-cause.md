# SCORCH-001 — live AMM quote used as a redemption oracle

**Severity:** High. **Affected contract:** `Scorch` at `0xA3D0e72c8A2fE9127A77412BF34bEe5e4945bd49` (verified Solidity 0.8.19 source).

`scorch(uint256)` calls `uniswapV2Router.getAmountsOut(amount, [address(this), WETH])` and pays that spot quote from the contract's ETH balance before burning the caller's OTC. The quote is read from the manipulable OTC/WETH pair and has no TWAP, oracle freshness, or deviation check. A caller can first buy OTC with WETH/ETH, move the pair price, and then redeem OTC at the inflated quote. The 0.1 ETH per-call cap only limits each iteration; repeated calls drain the contract.

The reference attack buys OTC, repeatedly calls `scorch` while the quote is under the cap, sells remaining OTC back into the pair, and keeps the ETH reward. The patch pauses `scorch` until a manipulation-resistant oracle is installed; this is the smallest fail-closed remediation that removes the vulnerable spot-price dependency.
