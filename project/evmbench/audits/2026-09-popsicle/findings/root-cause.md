# Popsicle Sorbetto Fragola fee-accounting flaw

**Severity:** critical custody loss. **Contract:** verified `SorbettoFragola.sol`, deployed Popsicle Fragola vault (`0xc4ff55a4329f84f9Bf0F5619998aB570481EBB48`).

`_updateFeesReward(address account)` calculates earned fees for `account`, but stores the result in `userInfo[msg.sender]`. ERC-20 share transfers do not update reward debt. An attacker can move all shares between addresses and call fee collection from each address; each address is evaluated with a zero/stale paid-per-share value and can claim the same pool fees repeatedly.

The local fixture preserves the verified vault and uses a minimal constant-price Uniswap-V3-shaped pool with finite pre-seeded fees. The fixture has no privileged transfer or mint behavior and is documented in authoring notes.

The root-cause patch stores rewards in `userInfo[account]` and settles both accounts in an ERC-20 transfer hook before balances change. This keeps reward debt aligned with the balances used for fee calculation and prevents duplicate claims after share transfers.
