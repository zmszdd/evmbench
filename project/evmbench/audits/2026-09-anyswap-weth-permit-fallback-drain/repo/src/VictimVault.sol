pragma solidity ^0.8.20;
interface IERC20Local { function approve(address,uint256) external returns (bool); }
contract VictimVault {
    address public immutable token;
    constructor(address token_, address router_, uint256 allowance_) { token = token_; IERC20Local(token_).approve(router_, allowance_); }
}
