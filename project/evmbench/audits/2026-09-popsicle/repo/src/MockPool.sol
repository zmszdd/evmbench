// A finite-fee, constant-price Uniswap-V3-shaped harness. It has no privileged
// transfer or mint path and is used only to exercise the verified Fragola code.
pragma solidity 0.7.6;
interface IERC20Like { function transfer(address to, uint256 value) external returns (bool); }
interface IMintCallback { function uniswapV3MintCallback(uint256,uint256,bytes calldata) external; }
contract MockPool {
    address public token0;
    address public token1;
    int24 public tickSpacing = 60;
    uint256 public fee0;
    uint256 public fee1;
    mapping(bytes32 => uint128) public liquidity;
    constructor(address a, address b, uint256 f0, uint256 f1) { token0=a; token1=b; fee0=f0; fee1=f1; }
    function slot0() external pure returns (uint160,int24,uint16,uint16,uint16,uint8,bool) { return (79228162514264337593543950336,0,0,1,1,0,true); }
    function observe(uint32[] calldata secondsAgos) external pure returns (int56[] memory ticks, uint160[] memory liq) {
        ticks = new int56[](secondsAgos.length); liq = new uint160[](secondsAgos.length);
    }
    function _key(address owner, int24 lo, int24 hi) internal pure returns (bytes32) { return keccak256(abi.encodePacked(owner,lo,hi)); }
    function positions(bytes32 key) external view returns (uint128,uint256,uint256,uint128,uint128) { return (liquidity[key],0,0,0,0); }
    function mint(address recipient, int24 lo, int24 hi, uint128 amount, bytes calldata data) external returns (uint256 amount0, uint256 amount1) {
        amount0 = 1; amount1 = 1;
        IMintCallback(msg.sender).uniswapV3MintCallback(amount0, amount1, data);
        liquidity[_key(msg.sender,lo,hi)] += amount;
        recipient; // position owner is the calling Fragola, as in Uniswap V3
    }
    function burn(int24 lo, int24 hi, uint128 amount) external returns (uint256 amount0, uint256 amount1) {
        bytes32 k=_key(msg.sender,lo,hi); require(liquidity[k] >= amount, "L"); liquidity[k]-=amount;
        amount0=0; amount1=0;
    }
    function collect(address recipient, int24, int24, uint128 amount0Requested, uint128 amount1Requested) external returns (uint128 amount0, uint128 amount1) {
        amount0 = fee0 < uint256(amount0Requested) ? uint128(fee0) : amount0Requested;
        amount1 = fee1 < uint256(amount1Requested) ? uint128(fee1) : amount1Requested;
        fee0 -= amount0; fee1 -= amount1;
        if (amount0 > 0) require(IERC20Like(token0).transfer(recipient, amount0), "T0");
        if (amount1 > 0) require(IERC20Like(token1).transfer(recipient, amount1), "T1");
    }
    function swap(address,bool,int256,uint160,bytes calldata) external pure returns (int256,int256) { return (0,0); }
}
