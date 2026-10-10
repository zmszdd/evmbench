pragma solidity ^0.8.20;
interface IERC20V { function approve(address,uint256) external returns(bool); }
contract MockVault { constructor(address token,address router,uint256 amount){ IERC20V(token).approve(router,amount); } }
