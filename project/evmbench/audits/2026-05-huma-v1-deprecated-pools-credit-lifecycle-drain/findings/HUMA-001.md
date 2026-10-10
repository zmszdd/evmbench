# Root Cause: Huma V1 credit-lifecycle `Requested -> GoodStanding` promotion

**Severity**: Critical (full loss of each pool's stablecoin reserve)

**Vulnerable contract**: `BaseCreditPool` (`src/BaseCreditPool.sol`, the verified
implementation `0x57107D02C2b70e09aD77240dbDe7aD77fE91eA1c` behind the three
deprecated Huma V1 pool proxies on Polygon; the second implementation
`0x2cFfaAf7...` carries the identical logic).

**Incident**: txs `0x0adf9953...` (request), `0x7126ae1d...` (activation via
`refreshAccount`), `0x7b8d641d...` (drawdowns + sweep), 2026-05-11 — three
deprecated pools lost their residual 82,315.571143 USDC and 19,074.730401
USDC.e (≈ $101,390) to an attacker-controlled borrower.

## The code

The credit lifecycle is supposed to run `Requested -> (EA approval) ->
Approved -> first drawdown -> GoodStanding`. Three open functions together
skip the approval step entirely:

```solidity
function requestCredit(uint256 creditLimit, uint256 intervalInDays, uint256 numOfPayments)
    external virtual override
{
    _initiateCredit(msg.sender, creditLimit, _poolConfig.poolAprInBps(),
                    intervalInDays, numOfPayments, false);  // preApproved = false
}
// _initiateCredit stores attacker-chosen terms and leaves the record
// in BS.CreditState.Requested (state = 1).

function refreshAccount(address borrower) external virtual override
{
    if (_creditRecordMapping[borrower].state != BS.CreditState.Defaulted) {
        if (isDefaultReady(borrower)) return _updateDueInfo(borrower, false, false);
        else return _updateDueInfo(borrower, false, true);   // no state check
    }
}
// _updateDueInfo: any periodsPassed > 0 with missedPeriods == 0 sets
//     cr.state = BS.CreditState.GoodStanding;   (state 1 -> 3, no approval)

function drawdown(uint256 borrowAmount) external virtual override { ... }
// _checkDrawdownEligibility accepts Approved OR GoodStanding, and the
// GoodStanding "return drawdown" branch pays the pool's reserve to
// msg.sender, bounded only by the stored creditLimit.
```

The time precondition is free: `BaseFeeManager.getDueInfo()` (src/BaseFeeManager.sol:221)
treats a fresh record's `dueDate == 0` as one full period already passed
(`periodsPassed = 1` at any block timestamp), so the promotion happens in the
very next block after the request — the incident's request and activation
transactions are three minutes apart.

## Why it is exploitable

Every gate on the money path belongs to the pool's own bookkeeping, none of
it to underwriting:

1. `requestCredit` is open and records an **attacker-chosen**
   `creditLimit` (bounded only by the pool's `_maxCreditLine`).
2. `refreshAccount` is callable by **anyone** for **any** non-defaulted
   borrower — including a `Requested` record that was never approved.
   `_updateDueInfo` only inspects billing counters (`totalDue`,
   `missedPeriods`), all zero for a fresh request, so it writes
   `GoodStanding` and a first due date.
3. `drawdown`'s return-drawdown branch then validates the draw only against
   `creditLimit - unbilledPrincipal - (totalDue - feesAndInterestDue)` — all
   attacker-side quantities, all satisfied — and transfers
   `distBorrowingAmount(borrowAmount)` (with the incident pools' zero fee
   settings, the gross amount) straight to the caller.

The pool's USDC balance is never consulted on the drawdown path: the whole
seeded reserve can leave in one transaction. There is no flash loan, no AMM
and no oracle in the attack — the profit is the direct, approval-less draw
of the LPs' stake.

## The fix

The illegal transition is the billing refresh of a not-yet-approved record.
`refreshAccount` must refuse to bill a `Requested` credit line (refreshing
billing is meaningful only for active lines):

```solidity
if (_creditRecordMapping[borrower].state != BS.CreditState.Defaulted) {
    if (_creditRecordMapping[borrower].state == BS.CreditState.Requested)
        revert Errors.creditLineNotInStateForDrawdown();
    ...
}
```

With that guard, the `Requested` record stays `Requested` until an authorized
approval path (`preApproved = true` via the EA service, or
`_approveCredit`) explicitly activates it; the same request/refresh/drawdown
sequence reverts at the refresh, and the pool's reserve is untouchable
without underwriting. (Equivalent placements — gating the non-first-drawdown
`_updateDueInfo` calls, or requiring Approved/GoodStanding before billing —
close the same root cause; restricting `refreshAccount` to the
borrower/EA alone would not, since the borrower here is the attacker.)
