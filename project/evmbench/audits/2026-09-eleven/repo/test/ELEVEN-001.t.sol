// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "../src/ElevenNeverSellVault.sol";
import "../src/Mocks.sol";

interface VmEleven { function etch(address target, bytes calldata code) external; }

contract ELEVEN001PatchTest {
    VmEleven private constant vm = VmEleven(address(uint160(uint256(keccak256("hevm cheat code")))));
    address private constant LP = 0x401479091d0F7b8AE437Ee8B054575cd33ea72Bd;
    address private constant MASTER_MIND = 0x2EBe8CDbCB5fB8564bC45999DAb8DA264E31f24E;

    function test_ELEVEN_001_emergency_burn_consumes_shares() public {
        vm.etch(LP, type(ElevenMockLP).runtimeCode);
        vm.etch(MASTER_MIND, type(ElevenMockMastermind).runtimeCode);
        ElevenMockLP token = ElevenMockLP(LP);
        ElevenNeverSellVault vault = new ElevenNeverSellVault();
        ElevenMockMastermind(MASTER_MIND).setVault(address(vault));

        uint256 amount = 100 ether;
        token.mint(MASTER_MIND, 1_000 ether);
        token.mint(address(this), amount);
        token.approve(address(vault), amount);
        vault.deposit(amount);
        require(vault.balanceOf(address(this)) == amount, "fixture deposit did not mint shares");

        vault.emergencyBurn();
        require(vault.balanceOf(address(this)) == 0, "emergency payout left redeemable shares");
    }
}
