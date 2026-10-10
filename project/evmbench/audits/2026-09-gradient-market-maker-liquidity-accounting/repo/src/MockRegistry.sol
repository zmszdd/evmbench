// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
contract MockRegistry {
    address public marketMakerPool; address public gradientToken; address public feeCollector; address public orderbook; address public fallbackExecutor; address public router;
    mapping(address=>bool) public blockedTokens; mapping(address=>bool) public authorizedContracts; mapping(address=>bool) public authorizedFulfillers; mapping(address=>bool) public isRewardDistributor; mapping(bytes32=>address) public additionalContracts;
    constructor(address r,address ob){router=r;orderbook=ob;}
    function setMainContracts(address p,address t,address f,address o,address x,address r) external {marketMakerPool=p;gradientToken=t;feeCollector=f;orderbook=o;fallbackExecutor=x;router=r;}
    function setRewardDistributor(address a) external {isRewardDistributor[a]=true;}
    function setTokenBlockStatus(address a,bool b) external {blockedTokens[a]=b;}
}
