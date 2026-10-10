// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

interface IERC20Minimal { function balanceOf(address) external view returns (uint); function transfer(address, uint) external returns (bool); }

/// @dev Minimal deterministic infrastructure around the verified Liquidator.
contract MockWBNB {
    string public constant name = "Wrapped BNB";
    string public constant symbol = "WBNB";
    uint8 public constant decimals = 18;
    uint public totalSupply;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    function mint(address to, uint amount) external { balanceOf[to] += amount; totalSupply += amount; emit Transfer(address(0), to, amount); }
    function approve(address spender, uint amount) external returns (bool) { allowance[msg.sender][spender] = amount; emit Approval(msg.sender, spender, amount); return true; }
    function transfer(address to, uint amount) external returns (bool) { require(balanceOf[msg.sender] >= amount, "balance"); balanceOf[msg.sender] -= amount; balanceOf[to] += amount; emit Transfer(msg.sender, to, amount); return true; }
    function transferFrom(address from, address to, uint amount) external returns (bool) { require(allowance[from][msg.sender] >= amount, "allowance"); allowance[from][msg.sender] -= amount; require(balanceOf[from] >= amount, "balance"); balanceOf[from] -= amount; balanceOf[to] += amount; emit Transfer(from, to, amount); return true; }
}

contract MockComptroller {
    function oracle() external pure returns (address) { return address(0x0000000000000000000000000000000000000111); }
    function closeFactorMantissa() external pure returns (uint) { return 5e17; }
    function liquidationIncentiveMantissa() external pure returns (uint) { return 11e17; }
}

contract MockFactory {
    mapping(bytes32 => address) public pairs;
    function _key(address a, address b) internal pure returns (bytes32) { return keccak256(abi.encodePacked(a, b)); }
    function setPair(address a, address b, address pair) external { pairs[_key(a,b)] = pair; pairs[_key(b,a)] = pair; }
    function getPair(address a, address b) external view returns (address) { return pairs[_key(a,b)]; }
}

/// @dev Attacker-controlled Annex-like market token. Its no-op methods model
/// the callback ABI used by the historical proof of concept.
contract MockAToken {
    function liquidateBorrow(address, uint, address) external pure returns (uint) { return 0; }
    function balanceOf(address) external pure returns (uint) { return 0; }
    function redeem(uint) external pure returns (uint) { return 0; }
    function underlying() external pure returns (address) { return address(0); }
}

interface ILiquidatorCallback { function pancakeCall(address, uint, uint, bytes calldata) external; }

/// @dev Minimal Pancake pair: a flash-swap output invokes pancakeCall, and
/// exit models burning the attacker's temporary LP position.
contract MockPair {
    address public token0;
    address public token1;
    constructor(address a, address b) public { token0 = a; token1 = b; }
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external {
        require(amount0Out == 0 || amount1Out == 0, "one-sided");
        if (amount0Out > 0) require(IERC20Minimal(token0).transfer(to, amount0Out), "out0");
        if (amount1Out > 0) require(IERC20Minimal(token1).transfer(to, amount1Out), "out1");
        ILiquidatorCallback(to).pancakeCall(msg.sender, amount0Out, amount1Out, data);
    }
    function exit(address to) external {
        uint a = IERC20Minimal(token0).balanceOf(address(this));
        uint b = IERC20Minimal(token1).balanceOf(address(this));
        if (a > 0) IERC20Minimal(token0).transfer(to, a);
        if (b > 0) IERC20Minimal(token1).transfer(to, b);
    }
}
