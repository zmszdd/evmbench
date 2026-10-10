pragma solidity ^0.8.25;
contract MockERC20 {
 string public name; string public symbol; uint8 public decimals=6; uint256 public totalSupply;
 mapping(address=>uint256) public balanceOf; mapping(address=>mapping(address=>uint256)) public allowance;
 constructor(string memory n,string memory s,address victim,uint256 amount){name=n;symbol=s;balanceOf[victim]=amount;totalSupply=amount;}
 function approve(address s,uint256 a) external returns(bool){allowance[msg.sender][s]=a;return true;}
 function transfer(address to,uint256 a) external returns(bool){require(balanceOf[msg.sender]>=a);balanceOf[msg.sender]-=a;balanceOf[to]+=a;return true;}
 function transferFrom(address f,address t,uint256 a) external returns(bool){require(balanceOf[f]>=a && allowance[f][msg.sender]>=a);allowance[f][msg.sender]-=a;balanceOf[f]-=a;balanceOf[t]+=a;return true;}
 function mint(address to,uint256 amount) external {balanceOf[to]+=amount;totalSupply+=amount;}
}
