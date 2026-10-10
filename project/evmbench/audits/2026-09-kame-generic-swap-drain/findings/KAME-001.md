# Kame generic executor drain

`AggregationRouter.swap` first calls `srcToken.safeTransferFrom(msg.sender, params.executor, params.amount)` and then executes `params.executor.call(params.executeParams)`. Both executor and calldata are supplied by the caller. Setting the token itself as executor allows the call data to be `transferFrom(victim, attacker, amount)` against a victim allowance granted to the router. The minimal repair is to restrict executors to an approved set and validate the token/function calldata against the signed route.
