// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
/// @notice Fixed-supply ERC-20 used only to seed deterministic local state.
/// It implements ordinary allowance and transfer semantics and exposes no mint or burn method.
contract MockUSDC {
    string public constant name = "USD Coin";
    string public constant symbol = "USDC";
    uint8 public constant decimals = 6;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    constructor(uint256 supply, address recipient) { totalSupply = supply; balanceOf[recipient] = supply; emit Transfer(address(0), recipient, supply); }
    function approve(address spender, uint256 value) external returns (bool) { allowance[msg.sender][spender] = value; emit Approval(msg.sender, spender, value); return true; }
    function transfer(address to, uint256 value) external returns (bool) { _move(msg.sender, to, value); return true; }
    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        uint256 a = allowance[from][msg.sender]; require(a >= value, "ERC20: insufficient allowance"); unchecked { allowance[from][msg.sender] = a - value; } _move(from, to, value); return true;
    }
    function _move(address from, address to, uint256 value) internal { require(to != address(0), "ERC20: transfer to zero"); uint256 b = balanceOf[from]; require(b >= value, "ERC20: transfer amount exceeds balance"); unchecked { balanceOf[from] = b - value; } balanceOf[to] += value; emit Transfer(from, to, value); }
}
