// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {ICarbonController} from "./sources/ICarbonController.sol";
import {IOxiumMgvCore} from "./sources/IOxiumMgvCore.sol";

interface IAggregationExecutor {
    function execute(bytes calldata executeParams) external payable returns (uint256 returnAmount);

    struct ExecuteParams {
        Path[] paths;
        IERC20 srcToken;
        IERC20 dstToken;
        address payable recipient;
        uint256 expectedReturnAmount;
        uint16 slippageTolerance;
        Fee fee;
    }

    struct Path {
        Swap[] swaps;
        uint256 amountIn;
    }

    struct Swap {
        bytes data;
        SourceType sourceType;
    }

    struct Fee {
        // feeInBps is the fee in basis points
        uint64 feeInBps;
        // isFeeTakenFromInput is a flag that indicates whether the fee is taken from the input amount
        bool isFeeTakenFromInput;
        // feeRecipient is the address that receives the fee
        address payable feeRecipient;
    }

    enum SourceType {
        UniswapV2,
        UniswapV3,
        Iziswap,
        BalancerV2,
        VelodromeV1,
        CarbonDefi,
        Oxium
    }

    struct UniswapV2Data {
        address pair;
        address srcToken;
        address dstToken;
        uint32 fee;
        uint32 feeDenominator;
    }

    struct UniswapV3Data {
        address pool;
        address srcToken;
        address dstToken;
    }

    struct IziswapData {
        address pool;
        address srcToken;
        address dstToken;
        int24 limitPoint;
    }

    struct BalancerV2Data {
        address vault;
        bytes32 poolId;
        address srcToken;
        address dstToken;
    }

    struct VelodromeV1Data {
        address pair;
        address srcToken;
        address dstToken;
    }

    struct CarbonDefiData {
        address controller;
        address pair;
        address srcToken;
        address dstToken;
        ICarbonController.TradeAction[] tradeActions;
    }

    struct OxiumSwapData {
        address mgvCore;
        address pool;
        IOxiumMgvCore.OLKey olKey;
        IOxiumMgvCore.Tick maxTick;
    }

    // Exchanged is emitted when a swap is executed
    event Exchanged(address pool, address srcToken, address dstToken, uint256 swapAmount, uint256 returnAmount);

    // FeeTaken is emitted when a fee is taken
    event FeeTaken(address feeToken, address feeRecipient, uint256 feeAmount);

    // SurplusCaptured is emitted when surplus is captured
    event SurplusCaptured(address indexed token, uint256 surplusAmount, address indexed surplusRecipient);
}
