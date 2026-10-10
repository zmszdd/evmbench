// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
contract MockPair {
    address public token0; address public token1; uint112 private r0; uint112 private r1;
    constructor(address a,address b){token0=a;token1=b;}
    function setReserves(uint112 a,uint112 b) external {r0=a;r1=b;}
    function getReserves() external view returns(uint112,uint112,uint32){return(r0,r1,uint32(block.timestamp));}
}
contract MockFactory {
    mapping(address=>mapping(address=>address)) public pairs;
    function setPair(address a,address b,address p) external {pairs[a][b]=p;pairs[b][a]=p;}
    function getPair(address a,address b) external view returns(address){return pairs[a][b];}
}
contract MockRouter { address public immutable factory; address public immutable WETH; constructor(address f,address w){factory=f;WETH=w;} }
