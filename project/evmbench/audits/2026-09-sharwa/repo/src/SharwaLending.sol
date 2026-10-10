// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
interface IERC20L { function transfer(address,uint256) external returns(bool); }
interface IValuer { function getInputPositionValue(uint256) external returns(uint256); }
contract SharwaLending { address public immutable valuer; IERC20L public immutable debtToken; uint256 public immutable collateralUnit; mapping(address=>bool) public used;
 constructor(address v,address d,uint256 u){valuer=v;debtToken=IERC20L(d);collateralUnit=u;}
 function borrowAgainst() external { require(!used[msg.sender],"already used"); used[msg.sender]=true; uint256 amount=IValuer(valuer).getInputPositionValue(collateralUnit); require(debtToken.transfer(msg.sender,amount),"liquidity"); }
}
