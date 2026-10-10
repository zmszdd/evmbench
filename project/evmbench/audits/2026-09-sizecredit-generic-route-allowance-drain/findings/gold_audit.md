# Reference audit for 2026-09-sizecredit-generic-route-allowance-drain

This report is derived from the supplied source, PoC and finding material.

## SIZE-001
# Root cause

The verified Size Credit LeverageUp generic route accepts a caller-selected target and calldata and performs a low-level call after setting an approval. The call is not constrained to a trusted swap router or validated for token, amount, and recipient. Existing allowances to the leverage contract can therefore be used by an arbitrary ERC-20 transferFrom call. The minimal patch restricts route targets to an immutable approved router before the external call.

