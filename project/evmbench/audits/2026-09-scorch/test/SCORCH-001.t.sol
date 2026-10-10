// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "../src/Scorch.sol";
import "../src/LocalDex.sol";

interface Vm {
    function deal(address account, uint256 newBalance) external;
    function etch(address target, bytes calldata code) external;
}

contract SCORCH001PatchTest {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));
    address private constant ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    receive() external payable {}

    function test_SCORCH_001_rejects_spot_quote_burn_payout() public {
        vm.deal(address(this), 20 ether);
        WETH9Local weth = new WETH9Local();
        FactoryLocal factory = new FactoryLocal(address(this));
        RouterLocal router = new RouterLocal(address(factory), address(weth));
        vm.etch(ROUTER, address(router).code);

        Scorch scorch = new Scorch();
        address pair = scorch.uniswapPair();
        scorch.setSwapAndLiquifyEnabled(false);

        require(scorch.transfer(pair, 1_000_000 ether), "seed token reserve");
        weth.deposit{value: 20 ether}();
        weth.transfer(pair, 20 ether);
        PairLocal(pair).sync();
        vm.deal(address(scorch), 3 ether);

        // A 1,000 OTC spot quote is below the contract's per-call cap, so the
        // vulnerable path pays it directly from its native-asset reserve.
        (bool paid,) = address(scorch).call(
            abi.encodeWithSelector(scorch.scorch.selector, 1_000 ether)
        );
        require(!paid, "burn paid an AMM spot quote from the victim reserve");
    }
}
