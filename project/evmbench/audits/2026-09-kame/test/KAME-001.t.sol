// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "../src/Scenario.sol";
import "../src/interfaces/IAggregationRouter.sol";
import "../src/vendor/lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

interface IKameRouter {
    function swap(IAggregationRouter.SwapParams calldata params) external payable returns (uint256);
}

contract KamePatchTest {
 function test_KAME_001_rejects_untrusted_executor() public {
  Scenario scenario = new Scenario();
  address token = address(scenario.usdc());
  uint256 beforeBalance = scenario.usdc().balanceOf(address(scenario));
  IAggregationRouter.SwapParams memory p = IAggregationRouter.SwapParams(
    IERC20(token), IERC20(token), 0, payable(token),
    abi.encodeWithSignature("transferFrom(address,address,uint256)", address(scenario), address(this), beforeBalance),
    hex"01"
  );
  (bool ok,) = address(scenario.router()).call(abi.encodeCall(IKameRouter.swap, (p)));
  require(!ok, "untrusted token executor drained approved funds");
  require(scenario.usdc().balanceOf(address(scenario)) == beforeBalance, "victim balance changed");
 }
}
