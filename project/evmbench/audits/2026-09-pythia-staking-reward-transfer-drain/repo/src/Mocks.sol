pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
contract MockToken is ERC20 { constructor(string memory n,string memory s,uint256 supply) ERC20(n,s) {_mint(msg.sender,supply);} function mint(address to,uint256 a) external {_mint(to,a);} }
contract Distributor { uint256 public amount; constructor(uint256 a){amount=a;} function distributor(uint256) external view returns(uint256){return amount;} }
contract Escrow { function vestingLock(address,uint256) external pure returns(uint256){return 0;} }
