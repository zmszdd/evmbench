// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import "../src/MatezStakingProgram.sol";
import "../src/MockERC20.sol";
import "../src/MockFactory.sol";
import "../src/MockPool.sol";

contract StakeCaller {
    function register(address staking, address sponsor) external {
        MatezStakingProgram(staking).register(sponsor);
    }
    function stake(address staking, uint256 amount) external {
        MatezStakingProgram(staking).stake(amount);
    }
}

contract MATEZ001PatchTest {
    function test_MATEZ_001_preserves_full_stake_amount() public {
        MockERC20 token0 = new MockERC20("USD Coin", "USDC", 0);
        MockERC20 token1 = new MockERC20("MATEZ", "MATEZ", 0);
        MockPool pool = new MockPool();
        MockFactory factory = new MockFactory(address(pool));
        MatezStakingProgram staking = new MatezStakingProgram(
            address(factory), address(token0), address(token1), 3000
        );
        staking.init(address(this), address(token0));
        StakeCaller account = new StakeCaller();
        account.register(address(staking), address(this));

        uint256 truncatingAmount = uint256(1) << 128;
        (bool ok,) = address(account).call(
            abi.encodeWithSignature("stake(address,uint256)", address(staking), truncatingAmount)
        );
        require(!ok, "stake credited uint256 while quoting a truncated uint128 amount");
    }
}
