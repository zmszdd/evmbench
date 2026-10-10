// EIP-1967 delegatecall harness preserving the historical proxy storage layout.
pragma solidity ^0.8.20;

contract TestProxy {
    bytes32 private constant IMPLEMENTATION_SLOT =
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    constructor(address implementation, bytes memory initData) {
        require(implementation != address(0), "implementation");
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly { sstore(slot, implementation) }
        if (initData.length != 0) {
            (bool ok, bytes memory ret) = implementation.delegatecall(initData);
            if (!ok) assembly { revert(add(ret, 32), mload(ret)) }
        }
    }

    fallback() external payable {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            let implementation := sload(slot)
            calldatacopy(0, 0, calldatasize())
            let ok := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch ok
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    receive() external payable {}
}
