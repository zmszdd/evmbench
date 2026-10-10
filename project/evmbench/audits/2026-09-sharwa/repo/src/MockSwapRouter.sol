// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {ISwapRouter} from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
interface IERC20M { function transferFrom(address,address,uint256) external returns(bool); function transfer(address,uint256) external returns(bool); }
contract MockSwapRouter is ISwapRouter {
 address public immutable tokenIn; address public immutable tokenOut; uint256 public rate;
 constructor(address a,address b,uint256 r){tokenIn=a;tokenOut=b;rate=r;} function setRate(uint256 r) external {rate=r;}
 function exactInput(ExactInputParams calldata p) external payable override returns(uint256 out){ IERC20M(tokenIn).transferFrom(msg.sender,address(this),p.amountIn); out=p.amountIn*rate/1e18; IERC20M(tokenOut).transfer(msg.sender,out); }
 function exactInputSingle(ExactInputSingleParams calldata p) external payable override returns(uint256 out){ IERC20M(p.tokenIn).transferFrom(msg.sender,address(this),p.amountIn); out=p.amountIn*rate/1e18; IERC20M(p.tokenOut).transfer(p.recipient,out); }
 function exactOutput(ExactOutputParams calldata p) external payable override returns(uint256 used){ used=p.amountOut*1e18/rate; IERC20M(tokenIn).transferFrom(msg.sender,address(this),used); IERC20M(tokenOut).transfer(msg.sender,p.amountOut); }
 function exactOutputSingle(ExactOutputSingleParams calldata p) external payable override returns(uint256 used){ used=p.amountOut*1e18/rate; IERC20M(p.tokenIn).transferFrom(msg.sender,address(this),used); IERC20M(p.tokenOut).transfer(p.recipient,p.amountOut); }
 function uniswapV3SwapCallback(int256,int256,bytes calldata) external pure override { revert("unused"); }
}

