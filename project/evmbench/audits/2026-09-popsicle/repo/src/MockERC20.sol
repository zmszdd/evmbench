// Deterministic ERC-20 funding token used only as a normal surrounding fixture.
pragma solidity 0.7.6;
import "../token/ERC20.sol";
contract MockERC20 is ERC20 {
    constructor(string memory n, string memory s, uint256 supply) ERC20(n, s) { _mint(msg.sender, supply); }
    function mint(address to, uint256 amount) external { _mint(to, amount); }
}
