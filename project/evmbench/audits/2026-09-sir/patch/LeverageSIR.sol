// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract SirToken {
    string public name; string public symbol; uint8 public immutable decimals = 18;
    mapping(address => uint256) public balanceOf;
    constructor(string memory n, string memory s) { name=n; symbol=s; }
    function mint(address to, uint256 amount) external { balanceOf[to] += amount; }
    function transfer(address to, uint256 amount) external returns (bool) { require(balanceOf[msg.sender] >= amount, "balance"); balanceOf[msg.sender]-=amount; balanceOf[to]+=amount; return true; }
}

contract LeverageSIR {
    address public debtToken;
    address public collateralToken;
    address public callbackPool;
    bool public initialized;
    function initialize(address debt, address collateral, address pool) external {
        require(!initialized, "initialized"); initialized = true; debtToken = debt; collateralToken = collateral; callbackPool = pool;
    }
    function uniswapV3SwapCallback(int256, int256, bytes calldata data) external {
        require(msg.sender == callbackPool, "unauthorized callback");
        (address token, address receiver) = abi.decode(data, (address, address));
        uint256 amount = SirToken(token).balanceOf(address(this));
        require(SirToken(token).transfer(receiver, amount), "transfer");
    }
    function assetBalance(address token) external view returns (uint256) { return SirToken(token).balanceOf(address(this)); }
}
