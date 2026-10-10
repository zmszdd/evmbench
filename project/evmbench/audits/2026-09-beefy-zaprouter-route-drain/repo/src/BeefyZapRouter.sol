// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

interface IERC20Like { function transfer(address,uint256) external returns(bool); function transferFrom(address,address,uint256) external returns(bool); function balanceOf(address) external view returns(uint256); }

contract BeefyZapRouter {
    struct Input { address token; uint256 amount; }
    struct Output { address token; uint256 minOutputAmount; }
    struct Relay { address target; uint256 value; bytes data; }
    struct StepToken { address token; int32 index; }
    struct Step { address target; uint256 value; bytes data; StepToken[] tokens; }
    struct Order { Input[] inputs; Output[] outputs; Relay relay; address user; address recipient; }

    function executeOrder(Order calldata order, Step[] calldata route) external payable {
        require(msg.sender == order.user, "InvalidCaller");
        for (uint256 i; i < route.length; ++i) {
            Step calldata step = route[i];
            (bool ok, bytes memory ret) = step.target.call{value: step.value}(step.data);
            if (!ok) assembly { revert(add(ret, 32), mload(ret)) }
        }
        for (uint256 i; i < order.outputs.length; ++i) {
            Output calldata out = order.outputs[i];
            uint256 amount = IERC20Like(out.token).balanceOf(address(this));
            require(amount >= out.minOutputAmount, "Slippage");
            require(IERC20Like(out.token).transfer(order.recipient, amount), "return");
        }
        if (order.relay.target != address(0)) {
            (bool ok,) = order.relay.target.call{value: order.relay.value}(order.relay.data); require(ok, "relay");
        }
    }
}
