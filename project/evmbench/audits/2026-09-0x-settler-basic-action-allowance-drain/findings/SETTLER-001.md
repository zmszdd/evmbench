# SETTLER-001 ? BASIC arbitrary target can spend a victim allowance

**Location.** `src/MainnetTakerSubmittedFlat.sol`, `Basic.basicSellToPool` (the `BASIC` dispatch in `Settler._dispatch`).

**Root cause.** The BASIC action accepts a caller-controlled `pool` and calldata. It rejects only the protocol's Permit2 and AllowanceHolder addresses through `_isRestrictedTarget`; it does not reject the sell-token contract itself. When `pool` equals the ERC-20 sell token, the function forwards a `transferFrom` payload directly to that token. In this branch the token is also the pool, so no approval is established by the Settler and the token executes `transferFrom` with the Settler as `msg.sender`, consuming any pre-existing allowance granted to the Settler.

**Impact.** An attacker who can submit a BASIC action can move tokens from an allowance-granting account to an attacker-controlled recipient. The affected account loses the transferred amount and the ERC-20 total supply is unchanged; the incident material identifies approximately 3,008 USDT.

**Attack path.** Submit `Settler.execute` with a BASIC action whose sell token and pool are the same ERC-20, whose payload is that token's `transferFrom(owner, attacker, amount)`, and whose owner has already approved the Settler. The vulnerable implementation forwards the call and the token treats the Settler as the approved spender.

**Remediation.** Restrict BASIC targets so the sell token itself (and any other non-swap target that can consume a generic allowance) cannot be used as the pool. Preserve an allowlist of legitimate protocol pool targets and add a regression test that the allowance-drain payload reverts while a supported pool remains usable.
