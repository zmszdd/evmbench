# 0x MainnetSettler BASIC action allowance drain

The repository contains the verified flattened `MainnetSettler` source used at Ethereum address `0x0d0e364aa7852291883c162b22d6d81f6355428f`. Review how the BASIC action executes a caller-supplied pool and calldata. Demonstrate an exploit in the provided Anvil scenario that moves tokens out of the seeded victim only through an existing allowance to the Settler. The exploit wallet must receive the drained tokens. Do not mint, burn, or alter token supply, and do not impersonate privileged token ownership.

The intended vulnerable behavior is an ERC20 `transferFrom(victim, exploitWallet, amount)` encoded as BASIC action calldata with the token itself as the pool target. A successful submission should leave the victim poorer and the exploit wallet richer by the same amount.
