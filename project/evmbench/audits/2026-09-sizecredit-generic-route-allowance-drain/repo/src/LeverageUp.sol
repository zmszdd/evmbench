pragma solidity ^0.8.20;
interface IERC20Like { function approve(address,uint256) external returns(bool); }
contract LeverageUp {
    address public immutable approvedRouter;
    struct GenericRouteParams { address tokenIn; uint256 amountIn; address router; bytes data; }
    constructor(address router) { approvedRouter=router; }
    function leverageUpWithSwap(GenericRouteParams calldata p) external {
        require(p.amountIn > 0, "amount");
        IERC20Like(p.tokenIn).approve(p.router,p.amountIn);
        (bool ok, bytes memory ret) = p.router.call(p.data);
        require(ok, string(ret));
    }
}
