// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20Rare {
    function transfer(address to, uint256 amount) external returns (bool);
}

contract RareStakingV1 {
    IERC20Rare public immutable rewardToken;
    address private _owner;
    address public immutable authorized;
    bytes32 public currentClaimRoot;
    mapping(address => bool) public claimed;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event MerkleRootUpdated(bytes32 indexed root);
    event Claimed(address indexed account, uint256 amount);
    constructor(address token_, address authorized_) {
        rewardToken = IERC20Rare(token_); _owner = msg.sender; authorized = authorized_;
        emit OwnershipTransferred(address(0), msg.sender);
    }
    function owner() public view returns (address) { return _owner; }
    // Root cause fix: authorize either the owner or the designated updater.
    function updateMerkleRoot(bytes32 newRoot) external {
        require(msg.sender == owner() || msg.sender == authorized, "Not authorized to update merkle root");
        currentClaimRoot = newRoot; emit MerkleRootUpdated(newRoot);
    }
    function claim(uint256 amount, bytes32[] calldata proof) external {
        require(!claimed[msg.sender], "Already claimed");
        bytes32 node = keccak256(abi.encodePacked(msg.sender, amount));
        require(_verify(proof, currentClaimRoot, node), "Invalid proof");
        claimed[msg.sender] = true; require(rewardToken.transfer(msg.sender, amount), "transfer failed");
        emit Claimed(msg.sender, amount);
    }
    function _verify(bytes32[] calldata proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        bytes32 h = leaf;
        for (uint256 i; i < proof.length; ++i) { bytes32 p = proof[i]; h = h < p ? keccak256(abi.encodePacked(h,p)) : keccak256(abi.encodePacked(p,h)); }
        return h == root;
    }
}
