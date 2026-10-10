pragma solidity ^0.8.20;
contract MockERC20 {
    string public name="USDC"; string public symbol="USDC"; uint8 public decimals=6;
    uint256 public totalSupply; mapping(address=>uint256) public balanceOf; mapping(address=>mapping(address=>uint256)) public allowance;
    constructor(uint256 supply,address holder){totalSupply=supply;balanceOf[holder]=supply;}
    function transfer(address to,uint256 a) external returns(bool){require(balanceOf[msg.sender]>=a);balanceOf[msg.sender]-=a;balanceOf[to]+=a;return true;}
    function approve(address s,uint256 a) external returns(bool){allowance[msg.sender][s]=a;return true;}
    function transferFrom(address f,address t,uint256 a) external returns(bool){require(allowance[f][msg.sender]>=a);require(balanceOf[f]>=a);allowance[f][msg.sender]-=a;balanceOf[f]-=a;balanceOf[t]+=a;return true;}
}
