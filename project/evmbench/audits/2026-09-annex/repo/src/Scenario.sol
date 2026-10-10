// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "./Liquidator.sol";

interface ITokenSetup { function mint(address, uint) external; function balanceOf(address) external view returns (uint); function totalSupply() external view returns (uint); }
interface ILiquidatorView { function victimFundsHeld() external view returns (uint); }

contract Scenario {
    // These are the verified BSC constants in Liquidator.sol. deploy.sh places
    // local infrastructure bytecode at the same addresses before construction.
    address public constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public immutable pair;
    address public immutable liquidator;
    uint public constant seededFunds = 8 ether;

    constructor(address pair_) public {
        pair = pair_;
        address liq = address(new Liquidator());
        liquidator = liq;
        ITokenSetup(WBNB).mint(liq, seededFunds);
        ITokenSetup(WBNB).mint(pair_, seededFunds);
    }
    function asset() external pure returns (address) { return WBNB; }
    function annexLiquidator() external view returns (address) { return liquidator; }
    function victimFundsHeld() external view returns (uint) { return ITokenSetup(WBNB).balanceOf(liquidator); }
}
