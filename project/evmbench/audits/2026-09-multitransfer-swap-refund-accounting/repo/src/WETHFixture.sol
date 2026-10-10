pragma solidity ^0.8.20;
contract WETHFixture {
    string public constant name = "Wrapped Ether";
    string public constant symbol = "WETH";
    uint8 public constant decimals = 18;
    mapping(address=>uint256) public balanceOf;
    event Transfer(address indexed from,address indexed to,uint256 value);
    receive() external payable { deposit(); }
    function deposit() public payable { balanceOf[msg.sender] += msg.value; emit Transfer(address(0),msg.sender,msg.value); }
    function withdraw(uint256 value) external { require(balanceOf[msg.sender]>=value,"WETH: insufficient"); balanceOf[msg.sender]-=value; payable(msg.sender).transfer(value); emit Transfer(msg.sender,address(0),value); }
    function transfer(address to,uint256 value) external returns(bool) { require(balanceOf[msg.sender]>=value,"WETH: insufficient"); balanceOf[msg.sender]-=value; balanceOf[to]+=value; emit Transfer(msg.sender,to,value); return true; }
}
