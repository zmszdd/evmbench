# SIR Leverage callback authorization bypass

**Severity:** Critical. **Affected contract/function:** `LeverageSIR.uniswapV3SwapCallback`.

**Code excerpt (local reconstruction):**

```solidity
function uniswapV3SwapCallback(int256, int256, bytes calldata data) external {
    (address token, address receiver) = abi.decode(data, (address, address));
    uint256 amount = SirToken(token).balanceOf(address(this));
    SirToken(token).transfer(receiver, amount);
}
```

**Root cause:** The March 2025 PoC creates attacker-controlled token contracts and uses a transient/storage slot collision to make the vault accept attacker-controlled callback context. Once the callback path is reached, the vault transfers its USDC, WBTC, and WETH holdings to attacker-controlled receivers. The callback must authenticate the calling pool and bind token/receiver data to that pool invocation before paying any asset.

**Why exploitable:** Any externally owned account can submit callback calldata naming a vault-held token and its own receiver. The vulnerable implementation transfers the complete balance without checking the caller, so the attacker obtains all three fixture assets in separate transactions.

**Root-cause patch:** The patch rejects every callback unless `msg.sender == callbackPool`, before decoding and transferring assets. It leaves the transfer path unchanged for the configured pool.

The current task contains a deterministic semantic reconstruction of that boundary. A later Sourcify v2 query recovered an exact-match `src/Vault.sol:Vault` source set (match 6194153), archived under `authoring/2026-09-sir/source/sourcify-verified/`; migrating this task to that five-argument Vault and its dependency graph remains a separate required change before calling the task byte-for-byte verified.
