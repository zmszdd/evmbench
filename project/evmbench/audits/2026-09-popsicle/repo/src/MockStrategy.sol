pragma solidity 0.7.6;
contract MockStrategy {
    function tickRangeMultiplier() external pure returns (int24) { return 10; }
    function maxTwapDeviation() external pure returns (int24) { return 100000; }
    function twapDuration() external pure returns (uint32) { return 1; }
    function protocolFee() external pure returns (uint24) { return 0; }
    function priceImpactPercentage() external pure returns (uint24) { return 0; }
}
