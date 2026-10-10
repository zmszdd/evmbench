// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "../src/SurgeToken.sol";

interface Vm {
    function deal(address account, uint256 newBalance) external;
}

contract RebuyOnSellReceiver {
    SurgeToken public immutable surge;
    bool public callbackPurchaseSucceeded;

    constructor(SurgeToken token) { surge = token; }

    function buy() external payable {
        (bool ok,) = address(surge).call{value: msg.value}("");
        require(ok, "initial purchase failed");
    }

    function sellAll() external {
        surge.sell(surge.balanceOf(address(this)));
    }

    receive() external payable {
        if (msg.sender == address(surge)) {
            (callbackPurchaseSucceeded,) = address(surge).call{value: msg.value}("");
        }
    }
}

contract XSURGE001PatchTest {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    function test_XSURGE_001_blocks_sell_callback_reentry() public {
        vm.deal(address(this), 1 ether);
        SurgeToken surge = new SurgeToken();
        RebuyOnSellReceiver receiver = new RebuyOnSellReceiver(surge);

        receiver.buy{value: 1 ether}();
        receiver.sellAll();

        require(!receiver.callbackPurchaseSucceeded(), "sell callback re-entered purchase");
    }
}
