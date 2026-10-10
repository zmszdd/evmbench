pragma solidity ^0.8.20;
contract HelperToken {
    string public constant name="Exploit Helper Token"; string public constant symbol="EHT"; uint8 public constant decimals=18;
    uint256 public totalSupply; mapping(address=>uint256) public balanceOf; mapping(address=>mapping(address=>uint256)) public allowance;
    function mint(address to,uint256 value) external { balanceOf[to]+=value; totalSupply+=value; }
    function approve(address spender,uint256 value) external returns(bool){allowance[msg.sender][spender]=value;return true;}
    function transfer(address to,uint256 value) external returns(bool){require(balanceOf[msg.sender]>=value,"EHT: insufficient");balanceOf[msg.sender]-=value;balanceOf[to]+=value;return true;}
    function transferFrom(address from,address to,uint256 value) external returns(bool){require(balanceOf[from]>=value,"EHT: insufficient");uint a=allowance[from][msg.sender];require(a>=value,"EHT: allowance");if(a!=type(uint256).max)allowance[from][msg.sender]=a-value;balanceOf[from]-=value;balanceOf[to]+=value;return true;}
}
