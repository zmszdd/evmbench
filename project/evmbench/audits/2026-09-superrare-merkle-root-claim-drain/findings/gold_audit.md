# Reference audit for 2026-09-superrare-merkle-root-claim-drain

This report is derived from the supplied source, PoC and finding material.

## SUPERRARE-001
# SuperRare Merkle-root claim drain

The verified `RareStakingV1.updateMerkleRoot` implementation checks authorization with an OR:

```solidity
require(msg.sender != owner() || msg.sender != address(0xc2F394a45e994bc81EfF678bDE9172e10f7c8ddc));
```

For any caller, at least one inequality is true, so the condition never rejects an ordinary caller. The caller can install a root equal to `keccak256(abi.encodePacked(caller, amount))`. `MerkleProof.verify` with an empty proof accepts that leaf, and `claim` transfers the proxy's entire RARE balance. The minimal repair is to require both inequalities (`&&`), preserving the intended owner or governance allowlist.

