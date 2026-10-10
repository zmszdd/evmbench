pragma solidity ^0.8.20;

contract WETHLike {
    string public constant name = "Wrapped Ether";
    string public constant symbol = "WETH";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    receive() external payable { deposit(); }
    function deposit() public payable { balanceOf[msg.sender] += msg.value; totalSupply += msg.value; }
    function withdraw(uint256 amount) external { require(balanceOf[msg.sender] >= amount); balanceOf[msg.sender] -= amount; totalSupply -= amount; payable(msg.sender).transfer(amount); }
    function approve(address spender, uint256 amount) external returns (bool) { allowance[msg.sender][spender] = amount; return true; }
    function transfer(address to, uint256 amount) external returns (bool) { require(balanceOf[msg.sender] >= amount); balanceOf[msg.sender] -= amount; balanceOf[to] += amount; return true; }
    function transferFrom(address from, address to, uint256 amount) external returns (bool) { require(balanceOf[from] >= amount && allowance[from][msg.sender] >= amount); allowance[from][msg.sender] -= amount; balanceOf[from] -= amount; balanceOf[to] += amount; return true; }
    // WETH-style fallback: unknown permit selectors return successfully and change no state.
    fallback() external {}
}
