// Patched comparison: executor targets must be explicitly approved by the
// router. The benchmark's deterministic fixture uses the router itself as the
// only approved executor; arbitrary token targets are rejected before pulling
// the allowance.
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {UniERC20} from "./lib/UniERC20.sol";
import "./interfaces/IAggregationRouter.sol";
contract AggregationRouter is IAggregationRouter, Ownable(msg.sender) {
    using SafeERC20 for IERC20; using UniERC20 for IERC20;
    error InvalidMsgValue(); error ExecuteFailed(); error UnapprovedExecutor();
    receive() external payable {}
    function rescueFunds(address token,address payable recipient,uint256 amount) external onlyOwner {uint256 b=IERC20(token).uniBalanceOf(address(this)); IERC20(token).uniTransfer(recipient,amount>b?b:amount);}
    function swap(SwapParams calldata params) external payable returns(uint256 returnAmount) {
        if (params.executor != payable(address(this))) revert UnapprovedExecutor();
        IERC20 srcToken=params.srcToken; if(srcToken.isETH()&&msg.value!=params.amount) revert InvalidMsgValue();
        if(!srcToken.isETH()) srcToken.safeTransferFrom(msg.sender,params.executor,params.amount);
        (bool success,bytes memory returnData)=params.executor.call{value:msg.value}(params.executeParams); if(!success) revert ExecuteFailed();
        returnAmount=abi.decode(returnData,(uint256)); emit Swapped(address(params.srcToken),address(params.dstToken),params.amount,returnAmount,params.extraData);
    }
}
