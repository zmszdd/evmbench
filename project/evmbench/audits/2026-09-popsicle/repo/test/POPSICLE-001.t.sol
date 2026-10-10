// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma abicoder v2;

import "../src/SorbettoFragola.sol";
import "../src/MockPool.sol";
import "../src/MockStrategy.sol";

contract PopsicleTestToken {
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    function mint(address to, uint256 amount) external { balanceOf[to] += amount; }
    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }
    function transfer(address to, uint256 amount) external returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }
    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        uint256 allowed = allowance[from][msg.sender];
        require(allowed >= amount, "allowance");
        if (allowed != uint256(-1)) allowance[from][msg.sender] = allowed - amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}

contract PopsicleFeeClaimant {
    function claim(address vault, uint256 amount0) external {
        SorbettoFragola(vault).collectFees(amount0, 0);
    }
}

contract POPSICLE001PatchTest {
    function test_POPSICLE_001_does_not_transfer_unsettled_rewards_to_new_shareholder() public {
        PopsicleTestToken token0 = new PopsicleTestToken();
        PopsicleTestToken token1 = new PopsicleTestToken();
        MockPool pool = new MockPool(address(token0), address(token1), 100 ether, 0);
        MockStrategy strategy = new MockStrategy();
        SorbettoFragola vault = new SorbettoFragola(address(pool), address(strategy));
        vault.init();

        token0.mint(address(this), 100 ether);
        token1.mint(address(this), 100 ether);
        token0.mint(address(pool), 100 ether);
        token0.approve(address(vault), uint256(-1));
        token1.approve(address(vault), uint256(-1));
        vault.deposit(1 ether, 1 ether);

        uint256 shares = vault.balanceOf(address(this));
        PopsicleFeeClaimant recipient = new PopsicleFeeClaimant();
        require(vault.transfer(address(recipient), shares), "share transfer failed");

        // The pool fees were earned before the transfer. The incoming holder
        // must not claim rewards that belong to the sender's pre-transfer stake.
        (bool claimed,) = address(recipient).call(
            abi.encodeWithSelector(recipient.claim.selector, address(vault), 99 ether)
        );
        require(!claimed, "new shareholder claimed fees earned before receiving shares");
    }
}
