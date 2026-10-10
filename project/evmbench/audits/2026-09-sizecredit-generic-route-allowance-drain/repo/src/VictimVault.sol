pragma solidity ^0.8.20;
interface IERC20Vault { function approve(address,uint256) external returns(bool); }
contract VictimVault {
    address public immutable asset; address public immutable spender;
    constructor(address asset_, address spender_, uint256 allowanceAmount) { asset=asset_; spender=spender_; IERC20Vault(asset_).approve(spender_, allowanceAmount); }
}
