// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC20Local {
    function balanceOf(address) external view returns (uint256);
    function transfer(address,uint256) external returns (bool);
    function transferFrom(address,address,uint256) external returns (bool);
    function approve(address,uint256) external returns (bool);
}

contract WETH9Local {
    string public name = "Wrapped Ether";
    string public symbol = "WETH";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    event Approval(address indexed owner,address indexed spender,uint256 value);
    event Transfer(address indexed from,address indexed to,uint256 value);
    event Deposit(address indexed dst,uint256 wad);
    event Withdrawal(address indexed src,uint256 wad);
    receive() external payable { deposit(); }
    function deposit() public payable { balanceOf[msg.sender] += msg.value; totalSupply += msg.value; emit Deposit(msg.sender,msg.value); emit Transfer(address(0),msg.sender,msg.value); }
    function withdraw(uint256 wad) public { require(balanceOf[msg.sender] >= wad,"balance"); balanceOf[msg.sender]-=wad; totalSupply-=wad; payable(msg.sender).transfer(wad); emit Withdrawal(msg.sender,wad); emit Transfer(msg.sender,address(0),wad); }
    function approve(address guy,uint256 wad) external returns(bool){ allowance[msg.sender][guy]=wad; emit Approval(msg.sender,guy,wad); return true; }
    function transfer(address dst,uint256 wad) external returns(bool){ return transferFrom(msg.sender,dst,wad); }
    function transferFrom(address src,address dst,uint256 wad) public returns(bool){ if(src!=msg.sender){uint256 a=allowance[src][msg.sender]; require(a>=wad,"allowance"); if(a!=type(uint256).max) allowance[src][msg.sender]=a-wad;} require(balanceOf[src]>=wad,"balance"); balanceOf[src]-=wad; balanceOf[dst]+=wad; emit Transfer(src,dst,wad); return true; }
}

interface IPairLocal {
    function token0() external view returns(address);
    function token1() external view returns(address);
    function getReserves() external view returns(uint112,uint112,uint32);
    function sync() external;
    function transfer(address,uint256) external returns(bool);
    function transferToken(address,address,uint256) external returns(bool);
}

contract PairLocal {
    address public immutable token0;
    address public immutable token1;
    uint112 private reserve0;
    uint112 private reserve1;
    uint32 private blockTimestampLast;
    constructor(address a,address b){ require(a!=b); (token0,token1)=a<b?(a,b):(b,a); }
    function getReserves() external view returns(uint112,uint112,uint32){ return(reserve0,reserve1,blockTimestampLast); }
    function sync() public { reserve0=uint112(IERC20Local(token0).balanceOf(address(this))); reserve1=uint112(IERC20Local(token1).balanceOf(address(this))); blockTimestampLast=uint32(block.timestamp); }
    function transfer(address to,uint256 amount) external returns(bool){ return IERC20Local(msg.sender).transfer(to,amount); }
    function transferToken(address token,address to,uint256 amount) external returns(bool){ return IERC20Local(token).transfer(to,amount); }
    function swap(uint256 amount0Out,uint256 amount1Out,address to,bytes calldata) external { require(amount0Out==0 || amount1Out==0,"one side"); if(amount0Out>0) IERC20Local(token0).transfer(to,amount0Out); if(amount1Out>0) IERC20Local(token1).transfer(to,amount1Out); sync(); }
}

contract FactoryLocal {
    address public feeToSetter;
    mapping(address=>mapping(address=>address)) public getPair;
    event PairCreated(address indexed token0,address indexed token1,address pair,uint256);
    constructor(address setter){ feeToSetter=setter; }
    function createPair(address a,address b) external returns(address pair){ require(getPair[a][b]==address(0)); pair=address(new PairLocal(a,b)); getPair[a][b]=pair; getPair[b][a]=pair; emit PairCreated(a,b,pair,1); }
}

contract RouterLocal {
    address public immutable factory;
    address public immutable WETH;
    constructor(address f,address w){factory=f;WETH=w;}
    function _pair(address a,address b) internal view returns(address){return FactoryLocal(factory).getPair(a,b);}
    function getAmountsOut(uint amountIn,address[] calldata path) external view returns(uint[] memory out){ require(path.length==2); out=new uint[](2); out[0]=amountIn; (uint112 r0,uint112 r1,)=IPairLocal(_pair(path[0],path[1])).getReserves(); (uint256 rin,uint256 rout)=path[0]<path[1]?(uint256(r0),uint256(r1)):(uint256(r1),uint256(r0)); out[1]=amountIn*997*rout/(rin*1000+amountIn*997); }
    function _swapFrom(address input,address output,uint amountIn,address src,address to) internal returns(uint amountOut){ address p=_pair(input,output); (uint112 r0,uint112 r1,)=IPairLocal(p).getReserves(); (uint256 rin,uint256 rout)=input<output?(uint256(r0),uint256(r1)):(uint256(r1),uint256(r0)); amountOut=amountIn*997*rout/(rin*1000+amountIn*997); require(amountOut>0 && amountOut<rout,"liquidity"); IERC20Local(input).transferFrom(src,p,amountIn); IPairLocal(p).transferToken(output,to,amountOut); IPairLocal(p).sync(); }
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn,uint,address[] calldata path,address to,uint) external { _swapFrom(path[0],path[1],amountIn,msg.sender,to); }
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn,uint,address[] calldata path,address to,uint) external { uint n=_swapFrom(path[0],WETH,amountIn,msg.sender,address(this)); WETH9Local(payable(WETH)).withdraw(n); payable(to).transfer(n); }
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint,address[] calldata path,address to,uint) external payable { WETH9Local(payable(WETH)).deposit{value:msg.value}(); _swapFrom(WETH,path[1],msg.value,address(this),to); }
    function addLiquidityETH(address token,uint amountTokenDesired,uint,uint,address to,uint) external payable returns(uint,uint,uint){ IERC20Local(token).transferFrom(msg.sender,_pair(token,WETH),amountTokenDesired); WETH9Local(payable(WETH)).deposit{value:msg.value}(); IERC20Local(WETH).transfer(_pair(token,WETH),msg.value); IPairLocal(_pair(token,WETH)).sync(); return(amountTokenDesired,msg.value,1); }
    receive() external payable {}
}
