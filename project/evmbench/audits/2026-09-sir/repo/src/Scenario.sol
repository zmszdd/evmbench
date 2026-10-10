// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./LeverageSIR.sol";
contract Scenario {
    LeverageSIR public vault;
    SirToken public usdc;
    SirToken public wbtc;
    SirToken public weth;
    constructor() {
        usdc = new SirToken("USD Coin", "USDC"); wbtc = new SirToken("Wrapped Bitcoin", "WBTC"); weth = new SirToken("Wrapped Ether", "WETH");
        vault = new LeverageSIR();
        vault.initialize(address(usdc), address(weth), address(0x0000000000000000000000000000000000000001));
        usdc.mint(address(vault), 17814860000000000000000); // 17,814.86 USDC at 18 decimals
        wbtc.mint(address(vault), 1408500000000000000);      // 1.4085 WBTC
        weth.mint(address(vault), 119870000000000000000);    // 119.87 WETH
    }
}
