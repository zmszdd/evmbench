// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import "../src/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../src/contracts/vVISR.sol";
import "../src/contracts/RewardsHypervisor.sol";

contract NoOpVisorWallet {
    function owner() external view returns (address) { return address(this); }
    function delegatedTransferERC20(address, address, uint256) external { }
    function attack(address hypervisor, uint256 amount) external {
        RewardsHypervisor(hypervisor).deposit(amount, address(uint160(address(this))), address(this));
    }
}

contract VISOR001PatchTest {
 function test_VISOR_001_pulls_deposit_tokens() public {
  ERC20 visr = new ERC20("VISOR", "VISR");
  vVISR shares = new vVISR("vVISR", "vVISR", 18);
  RewardsHypervisor hypervisor = new RewardsHypervisor(address(visr), address(shares));
  shares.transferOwnership(address(hypervisor));
  NoOpVisorWallet wallet = new NoOpVisorWallet();
  (bool ok,) = address(wallet).call(abi.encodeWithSignature(
   "attack(address,uint256)", address(hypervisor), 1 ether
  ));
  require(!ok, "deposit minted shares without transferring VISR");
  require(visr.balanceOf(address(hypervisor)) == 0, "VISR was unexpectedly transferred");
  require(shares.balanceOf(address(wallet)) == 0, "unbacked shares were minted");
 }
}
