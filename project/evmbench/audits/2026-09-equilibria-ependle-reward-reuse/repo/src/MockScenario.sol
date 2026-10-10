// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "./@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Interfaces/IBaseRewardPool.sol";
import "./Interfaces/ISmartConvertor.sol";
import "./Interfaces/Balancer/IBalancerVault.sol";

contract MockERC20 is IERC20 {
    string public name; string public symbol; uint8 public decimals = 18; uint256 public override totalSupply;
    mapping(address=>uint256) public override balanceOf; mapping(address=>mapping(address=>uint256)) public override allowance;
    constructor(string memory n,string memory s){name=n;symbol=s;}
    function transfer(address to,uint256 a) external override returns(bool){require(balanceOf[msg.sender]>=a,"bal");balanceOf[msg.sender]-=a;balanceOf[to]+=a;emit Transfer(msg.sender,to,a);return true;}
    function approve(address s,uint256 a) external override returns(bool){allowance[msg.sender][s]=a;emit Approval(msg.sender,s,a);return true;}
    function transferFrom(address f,address t,uint256 a) external override returns(bool){require(balanceOf[f]>=a,"bal");uint256 al=allowance[f][msg.sender];require(al>=a,"allow");if(al!=type(uint256).max) allowance[f][msg.sender]=al-a;balanceOf[f]-=a;balanceOf[t]+=a;emit Transfer(f,t,a);return true;}
    function mint(address to,uint256 a) external {balanceOf[to]+=a;totalSupply+=a;emit Transfer(address(0),to,a);}
}
contract MockRewardPool is IBaseRewardPool {
    IERC20 public immutable token; address[] private rewardTokens; mapping(address=>uint256) public override balanceOf; uint256 public override totalSupply;
    constructor(address t,address reward){token=IERC20(t);rewardTokens.push(reward);}
    function setParams(uint256,address,address) external {} function stake(uint256 a) external {require(token.transferFrom(msg.sender,address(this),a));balanceOf[msg.sender]+=a;totalSupply+=a;}
    function stakeAll() external {this.stake(token.balanceOf(msg.sender));} function stakeFor(address a,uint256 x) external {require(token.transferFrom(msg.sender,address(this),x));balanceOf[a]+=x;totalSupply+=x;}
    function withdraw(uint256 a) external {require(balanceOf[msg.sender]>=a);balanceOf[msg.sender]-=a;totalSupply-=a;require(token.transfer(msg.sender,a));}
    function withdrawAll() external {this.withdraw(balanceOf[msg.sender]);} function donate(address,uint256) external payable {} function earned(address,address) external pure returns(uint256){return 0;} function getUserAmountTime(address) external pure returns(uint256){return 0;}
    function getRewardTokens() external view returns(address[] memory){return rewardTokens;} function getRewardTokensLength() external view returns(uint256){return rewardTokens.length;} function getReward(address) external {} function withdrawFor(address a,uint256 x) external {require(balanceOf[a]>=x);balanceOf[a]-=x;totalSupply-=x;require(token.transfer(msg.sender,x));} function queueNewRewards(address,uint256) external payable {}
}
contract MockSmartConvertor is ISmartConvertor { function estimateTotalConversion(uint256 a) external pure returns(uint256){return a;} function estimateOutAmount(address,uint256 a) external pure returns(uint256){return a;} function deposit(uint256) external pure returns(uint256){return 0;} function depositFor(uint256,address) external pure returns(uint256){return 0;} function swapEPendleForPendle(uint256,uint256,address) external pure returns(uint256){return 0;} }
contract MockBalancer is IBalancerVault { function swap(SingleSwap calldata,FundManagement calldata,uint256,uint256) external payable returns(uint256){return 0;} function batchSwap(SwapKind,BatchSwapStep[] calldata,IAsset[] calldata,FundManagement calldata,int256[] calldata,uint256) external payable returns(int256[] memory d){return d;} }contract SimpleProxy { address public immutable implementation; constructor(address impl,bytes memory init){implementation=impl;(bool ok,)=impl.delegatecall(init);require(ok,"init");} fallback() external payable {address impl=implementation;assembly{calldatacopy(0,0,calldatasize()) let r:=delegatecall(gas(),impl,0,calldatasize(),0,0) returndatacopy(0,0,returndatasize()) switch r case 0 {revert(0,returndatasize())} default{return(0,returndatasize())}}} receive() external payable{} }
contract RewardReceiver { address public immutable vault; address public immutable receiver; constructor(address v,address r){vault=v;receiver=r;IERC20(v).approve(msg.sender,type(uint256).max);} receive() external payable {payable(receiver).transfer(msg.value);} function claim(address reward) external {uint256 a=IERC20(reward).balanceOf(address(this));if(a>0) IERC20(reward).transfer(receiver,a);} }
