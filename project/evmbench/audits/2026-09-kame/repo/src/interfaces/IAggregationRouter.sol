// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IAggregationRouter {
    struct SwapParams {
        IERC20 srcToken;
        IERC20 dstToken;
        uint256 amount;
        address payable executor;
        bytes executeParams;
        bytes extraData;
    }

    event Swapped(address srcToken, address dstToken, uint256 amount, uint256 returnAmount, bytes extraData);
}
