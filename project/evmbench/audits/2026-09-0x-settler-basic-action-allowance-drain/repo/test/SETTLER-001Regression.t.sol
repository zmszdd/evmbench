// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "../src/MainnetTakerSubmittedFlat.sol";
import "../src/MockERC20.sol";

interface VmSettlerRegression { function etch(address target, bytes calldata code) external; }

/// Verifies that BASIC cannot forward a token's own transferFrom call and spend
/// a victim's pre-existing allowance to Settler.
contract SETTLER_001Regression {
    struct AllowedSlippage { address recipient; IERC20 buyToken; uint256 minAmountOut; }
    VmSettlerRegression private constant vm =
        VmSettlerRegression(address(uint160(uint256(keccak256("hevm cheat code")))));
    address private constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address private constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    function test_settler_001_rejects_token_as_basic_pool() public {
        uint256 amount = 3_008_000_000;
        address recipient = address(0xBEEF);
        MockERC20 template = new MockERC20("Tether USD", "USDT", address(this), 0);
        vm.etch(USDC, address(template).code);
        vm.etch(DAI, address(template).code);
        MockERC20 token = MockERC20(USDC);
        token.mint(address(this), amount * 2);
        MainnetSettler settler = new MainnetSettler(bytes20(0));

        require(token.approve(address(settler), amount), "approval setup failed");
        require(token.transfer(address(settler), amount), "sell balance setup failed");

        bytes memory payload = abi.encodeWithSignature(
            "transferFrom(address,address,uint256)", address(this), recipient, amount
        );
        bytes[] memory actions = new bytes[](1);
        actions[0] = abi.encodeWithSignature(
            "BASIC(address,uint256,address,uint256,bytes)", address(token), 10_000, address(token), 68, payload
        );
        AllowedSlippage memory slippage = AllowedSlippage(address(0), IERC20(address(0)), 0);

        (bool success,) = address(settler).call(
            abi.encodeWithSignature(
                "execute((address,address,uint256),bytes[],bytes32)", slippage, actions, bytes32(0)
            )
        );
        require(!success, "BASIC spent the victim's existing token allowance");
        require(token.balanceOf(address(this)) == amount, "victim balance changed");
        require(token.balanceOf(recipient) == 0, "recipient received victim tokens");
        require(token.totalSupply() == amount * 2, "total supply changed");
    }
}
