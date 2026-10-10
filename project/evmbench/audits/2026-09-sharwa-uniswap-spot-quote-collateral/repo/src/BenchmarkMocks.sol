// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MockToken {
    string public name; string public symbol; uint8 public decimals = 18;
    uint256 public totalSupply; mapping(address=>uint256) public balanceOf; mapping(address=>mapping(address=>uint256)) public allowance;
    constructor(string memory n,string memory s){name=n;symbol=s;}
    function mint(address to,uint256 a) external {balanceOf[to]+=a;totalSupply+=a;}
    function approve(address s,uint256 a) external returns(bool){allowance[msg.sender][s]=a;return true;}
    function transfer(address to,uint256 a) external returns(bool){require(balanceOf[msg.sender]>=a,"balance");balanceOf[msg.sender]-=a;balanceOf[to]+=a;return true;}
    function transferFrom(address f,address t,uint256 a) external returns(bool){require(balanceOf[f]>=a,"balance");if(msg.sender!=f){require(allowance[f][msg.sender]>=a,"allowance");allowance[f][msg.sender]-=a;}balanceOf[f]-=a;balanceOf[t]+=a;return true;}
}

contract MockQuoter {
    uint256 public rate = 1e18;
    function setRate(uint256 r) external { rate = r; }
    function quoteExactInput(bytes calldata, uint256 amountIn) external returns (uint256) { return amountIn * rate / 1e18; }
    function quoteExactOutput(bytes calldata, uint256 amountOut) external returns (uint256) { return amountOut * 1e18 / rate; }
    function quoteExactInputSingle(address,address,uint24,uint256 amountIn,uint160) external returns(uint256){return amountIn*rate/1e18;}
    function quoteExactOutputSingle(address,address,uint24,uint256 amountOut,uint160) external returns(uint256){return amountOut*1e18/rate;}
}

interface IValueModule { function getInputPositionValue(uint256 amountIn) external returns(uint256); }
interface IERC20M { function transfer(address,uint256) external returns(bool); function transferFrom(address,address,uint256) external returns(bool); }
contract MockCollateralLender {
    address public immutable module; address public immutable collateral; address public immutable payout;
    constructor(address m,address c,address p){module=m;collateral=c;payout=p;}
    function borrow(uint256 amount) external {
        IERC20M(collateral).transferFrom(msg.sender,address(this),amount);
        uint256 value=IValueModule(module).getInputPositionValue(amount);
        require(IERC20M(payout).transfer(msg.sender,value),"payout liquidity");
    }
}
