// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
contract MockERC20 {
    string public name="Gradient Token"; string public symbol="GRAY"; uint8 public decimals=18;
    uint256 public totalSupply; mapping(address=>uint256) public balanceOf; mapping(address=>mapping(address=>uint256)) public allowance;
    function mint(address to,uint256 amount) external { balanceOf[to]+=amount; totalSupply+=amount; }
    function approve(address s,uint256 a) external returns(bool){allowance[msg.sender][s]=a;return true;}
    function transfer(address to,uint256 a) external returns(bool){require(balanceOf[msg.sender]>=a);balanceOf[msg.sender]-=a;balanceOf[to]+=a;return true;}
    function transferFrom(address f,address to,uint256 a) external returns(bool){uint256 x=allowance[f][msg.sender];require(x>=a && balanceOf[f]>=a);if(x!=type(uint256).max)allowance[f][msg.sender]=x-a;balanceOf[f]-=a;balanceOf[to]+=a;return true;}
}
