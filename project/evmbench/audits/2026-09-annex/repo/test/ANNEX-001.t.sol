// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "../src/Scenario.sol";
import "../src/Mocks.sol";

interface VmAnnex { function etch(address target, bytes calldata code) external; }
interface IERC20Annex { function balanceOf(address account) external view returns (uint256); }

contract ANNEX001PatchTest {
    VmAnnex private constant vm = VmAnnex(address(uint160(uint256(keccak256("hevm cheat code")))));
    address private constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address private constant FACTORY = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    address private constant COMPTROLLER = 0xb13026Db8aAfA2fd6d23355533dcCccbD4442f4c;

    function test_ANNEX_001_rejects_unselected_callback_pair() public {
        vm.etch(WBNB, type(MockWBNB).runtimeCode);
        vm.etch(FACTORY, type(MockFactory).runtimeCode);
        vm.etch(COMPTROLLER, type(MockComptroller).runtimeCode);
        MockAToken fakeAToken = new MockAToken();
        MockPair pair = new MockPair(WBNB, address(fakeAToken));
        MockFactory(FACTORY).setPair(WBNB, address(fakeAToken), address(pair));
        Scenario scenario = new Scenario(address(pair));

        uint256 beforeFunds = scenario.victimFundsHeld();
        uint256 borrowed = IERC20Annex(WBNB).balanceOf(scenario.annexLiquidator());
        bytes memory callbackData = abi.encode(address(this), address(fakeAToken), address(fakeAToken));
        (bool ok,) = address(pair).call(
            abi.encodeWithSignature("swap(uint256,uint256,address,bytes)", borrowed, 0, scenario.annexLiquidator(), callbackData)
        );

        require(!ok, "unselected factory pair invoked the privileged callback");
        require(scenario.victimFundsHeld() == beforeFunds, "liquidator funds changed");
    }
}
