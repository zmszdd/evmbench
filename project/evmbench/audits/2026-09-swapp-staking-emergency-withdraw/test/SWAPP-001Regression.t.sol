// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "../src/Staking.sol";

interface VmSwapp {
    function warp(uint256 timestamp) external;
    function mockCall(address callee, bytes calldata data, bytes calldata returnData) external;
}

contract SWAPP_001Regression {
    VmSwapp private constant vm = VmSwapp(address(uint160(uint256(keccak256("hevm cheat code")))));
    address private constant CUSDC = 0x39AA39c021dfbaE8faC545936693aC917d5E7563;
    uint256 private constant AMOUNT = 100e6;

    function test_swapp_001_regression() public {
        Staking staking = new Staking();
        vm.warp(0);

        vm.mockCall(
            CUSDC,
            abi.encodeWithSelector(bytes4(keccak256("allowance(address,address)")), address(this), address(staking)),
            abi.encode(AMOUNT)
        );
        vm.mockCall(
            CUSDC,
            abi.encodeWithSelector(bytes4(keccak256("transferFrom(address,address,uint256)")), address(this), address(staking), AMOUNT),
            abi.encode(true)
        );
        vm.mockCall(
            CUSDC,
            abi.encodeWithSelector(bytes4(keccak256("balanceOf(address)")), address(staking)),
            abi.encode(AMOUNT)
        );
        vm.mockCall(
            CUSDC,
            abi.encodeWithSelector(bytes4(keccak256("transfer(address,uint256)")), address(this), AMOUNT),
            abi.encode(true)
        );

        staking.deposit(CUSDC, AMOUNT, address(0));
        require(staking.balanceOf(address(this), CUSDC) == AMOUNT, "fixture deposit failed");

        // Epoch 10 satisfies the emergency-withdraw delay for this fresh position.
        vm.warp(1624230000 + 9 * 2419200);
        bool rejected;
        try staking.emergencyWithdraw(CUSDC) {
            rejected = false;
        } catch {
            rejected = true;
        }
        require(rejected, "Compound receipt token was emergency-withdrawn");
    }
}
