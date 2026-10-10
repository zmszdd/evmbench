# Reference audit for 2026-09-anyswap-weth-permit-fallback-drain

This report is derived from the supplied source, PoC and finding material.

## ANYSWAP-001
# Root cause

`anySwapOutUnderlyingWithPermit` assumes that a call to `permit` means an ERC-2612 signature was checked. The underlying WETH implementation has a fallback that accepts unknown selectors, so the call succeeds without changing authorization. The router then consumes the victim's pre-existing allowance in `transferFrom` and deposits the tokens into an attacker-controlled AnySwap token. A minimal repair rejects underlying tokens that do not expose the ERC-2612 `nonces(address)` interface before invoking `permit`.

