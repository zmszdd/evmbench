// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @notice Minimal local reconstruction of the SIR Leverage vault boundary.
/// The production case used a storage-slot collision to make an attacker
/// contract pass the Uniswap V3 callback path. This reconstruction preserves
/// the affected asset-transfer boundary while keeping the local fixture deterministic.
contract SirToken {
    string public name;
    string public symbol;
    uint8 public immutable decimals = 18;
    mapping(address => uint256) public balanceOf;
    event Transfer(address indexed from, address indexed to, uint256 amount);
    constructor(string memory n, string memory s) { name = n; symbol = s; }
    function mint(address to, uint256 amount) external { balanceOf[to] += amount; emit Transfer(address(0), to, amount); }
    function transfer(address to, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "balance");
        balanceOf[msg.sender] -= amount; balanceOf[to] += amount; emit Transfer(msg.sender, to, amount); return true;
    }
}

contract LeverageSIR {
    address public debtToken;
    address public collateralToken;
    address public callbackPool;
    bool public initialized;
    event Initialized(address debtToken, address collateralToken, address callbackPool);

    function initialize(address debt, address collateral, address pool) external {
        require(!initialized, "initialized");
        initialized = true; debtToken = debt; collateralToken = collateral; callbackPool = pool;
        emit Initialized(debt, collateral, pool);
    }

    /// @dev Vulnerable pre-patch behavior: callback data is trusted for token
    /// selection and no caller authentication is enforced before paying assets.
    function uniswapV3SwapCallback(int256, int256, bytes calldata data) external {
        (address token, address receiver) = abi.decode(data, (address, address));
        uint256 amount = SirToken(token).balanceOf(address(this));
        require(SirToken(token).transfer(receiver, amount), "transfer");
    }

    function assetBalance(address token) external view returns (uint256) { return SirToken(token).balanceOf(address(this)); }
}
