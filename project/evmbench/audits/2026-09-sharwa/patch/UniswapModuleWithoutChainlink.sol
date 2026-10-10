// Root-cause patch: reject the manipulable Uniswap spot quote as collateral value.
pragma solidity 0.8.20;
import {UniswapModuleBase} from "contracts/modularSwapRouter/uniswap/UniswapModuleBase.sol"; import {ISwapRouter} from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol"; import {IQuoter} from "contracts/interfaces/modularSwapRouter/uniswap/IQuoter.sol";
contract UniswapModuleWithoutChainlink is UniswapModuleBase { constructor(address a,address b,uint24 c,address d,ISwapRouter e,IQuoter f) UniswapModuleBase(a,b,c,d,e,f) {} function getInputPositionValue(uint256) external pure override returns(uint amountOut){ revert("spot quote disabled"); } }
