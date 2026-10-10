pragma solidity ^0.8.17;
interface IERC20Pair { function balanceOf(address) external view returns(uint256); function transfer(address,uint256) external returns(bool); }
interface IPancakeCallback { function pancakeCall(address,uint256,uint256,bytes calldata) external; }
contract MockPair {
    IERC20Pair public immutable token;
    constructor(address token_) { token=IERC20Pair(token_); }
    function swap(uint256 amount0Out,uint256 amount1Out,address to,bytes calldata data) external {
        require(amount1Out==0 && amount0Out>0,"one token");
        uint256 beforeBal=token.balanceOf(address(this)); require(beforeBal>=amount0Out,"liquidity");
        require(token.transfer(to,amount0Out),"send");
        IPancakeCallback(to).pancakeCall(msg.sender,amount0Out,0,data);
        uint256 fee=(amount0Out*25 + 9974)/9975;
        require(token.balanceOf(address(this))>=beforeBal+fee,"underpaid");
    }
}
