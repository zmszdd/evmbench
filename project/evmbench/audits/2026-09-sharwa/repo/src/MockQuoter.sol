// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {IQuoter} from "contracts/interfaces/modularSwapRouter/uniswap/IQuoter.sol";
contract MockQuoter is IQuoter {
 uint256 public rate; constructor(uint256 r){rate=r;} function setRate(uint256 r) external { rate=r; }
 function quoteExactInput(bytes memory,uint256 a) external override returns(uint256){ return a*rate/1e18; }
 function quoteExactOutput(bytes memory,uint256 a) external override returns(uint256){ return a*1e18/rate; }
 function quoteExactInputSingle(address,address,uint24,uint256 a,uint160) external override returns(uint256){return a*rate/1e18;}
 function quoteExactOutputSingle(address,address,uint24,uint256 a,uint160) external override returns(uint256){return a*1e18/rate;}
}
