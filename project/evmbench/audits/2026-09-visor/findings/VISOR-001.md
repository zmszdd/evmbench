# Visor RewardsHypervisor deposit callback bypass

**Severity:** Critical. **Contract:** `contracts/RewardsHypervisor.sol`.

`deposit` computes shares from the user supplied `visrDeposit` before moving
VISR. For contract `from` addresses it only checks `IVisor(from).owner() ==
msg.sender` and then calls `delegatedTransferERC20`. The callback has no return
value or postcondition. A caller-controlled contract can therefore report itself
as owner and make the callback a no-op, receiving vVISR shares without paying
VISR. Those shares can immediately be redeemed through `withdraw`, draining the
real VISR balance held by the hypervisor.

The patch always executes `safeTransferFrom(from, address(this), visrDeposit)`;
the token balance delta is now required for every depositor, including contract
wallets. This is the root-cause fix rather than an unrelated access-control
hardening.
