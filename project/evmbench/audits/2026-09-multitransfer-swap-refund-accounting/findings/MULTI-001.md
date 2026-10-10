# MultiTransferSwap over-refunds ETH after repeated exact-output swaps

**Severity:** High. **Affected contract:** Ethereum `MultiTransferSwap`, `multiSwapETHForExactTokens`.

The function accepts one `msg.value` payment, then executes `times` exact-output swaps. Each loop obtains a fresh `amounts[0]` quote and deposits that much ETH into WETH. The pair reserves can change between iterations, so the successive input amounts need not be equal. After the loop, the contract refunds `msg.value - amounts[0] * times`. That expression assumes each swap consumed the last iteration's input. If a later quote is lower than an earlier one, the refund exceeds the unused payment and is paid from the contract's pre-existing ETH.

The DeFiHackLabs PoC uses a malicious helper token and new Uniswap V2 pairs to change apparent pair pricing between swaps. It reports approximately 0.34 ETH taken from the contract. The task fixture is meant to isolate the same accounting defect while keeping the verified victim source unchanged.

A root-cause fix accumulates every `amounts[0]` inside the loop and refunds only `msg.value - totalInput`. The patch in `patch/src/MultiTransferSwap.sol` implements that change.
