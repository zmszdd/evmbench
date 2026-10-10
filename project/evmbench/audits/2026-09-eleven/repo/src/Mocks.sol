// Deterministic peripheral fixtures for the verified Eleven vault source.
pragma solidity ^0.6.12;
interface IERC20Mini { function transfer(address,uint256) external returns(bool); function transferFrom(address,address,uint256) external returns(bool); function balanceOf(address) external view returns(uint256); }
contract ElevenMockLP {
    string public constant name = "Mock Ape LP"; string public constant symbol = "mAPE"; uint8 public constant decimals = 18;
    uint256 public totalSupply; mapping(address=>uint256) public balanceOf; mapping(address=>mapping(address=>uint256)) public allowance;
    function approve(address spender,uint256 amount) external returns(bool){ allowance[msg.sender][spender]=amount; return true; }
    function transfer(address to,uint256 amount) external returns(bool){ require(balanceOf[msg.sender]>=amount,"bal"); balanceOf[msg.sender]-=amount; balanceOf[to]+=amount; return true; }
    function transferFrom(address from,address to,uint256 amount) external returns(bool){ require(balanceOf[from]>=amount,"bal"); uint a=allowance[from][msg.sender]; require(a>=amount,"allow"); if(a != uint(-1)) allowance[from][msg.sender]=a-amount; balanceOf[from]-=amount; balanceOf[to]+=amount; return true; }
    function mint(address to,uint256 amount) external { balanceOf[to]+=amount; totalSupply+=amount; }
}
contract ElevenMockMastermind {
    address public constant token = 0x401479091d0F7b8AE437Ee8B054575cd33ea72Bd;
    address public vault; uint256 public pool;
    function setVault(address v) external { require(vault==address(0),"set"); vault=v; }
    function deposit(uint256,uint256 amount) external { require(msg.sender==vault,"vault"); require(IERC20Mini(token).transferFrom(msg.sender,address(this),amount)); }
    // The real farm can retain strategy liquidity beyond one user's shares. This fixture
    // keeps a reserve and permits the same vault to withdraw against it twice, exposing
    // the vault accounting bug while preventing arbitrary callers from withdrawing.
    function withdraw(uint256,uint256 amount) external { require(msg.sender==vault,"vault"); require(IERC20Mini(token).balanceOf(address(this))>=amount,"pool"); require(IERC20Mini(token).transfer(msg.sender,amount)); }
    function userInfo(uint256,address) external view returns(uint256,uint256){ return (IERC20Mini(token).balanceOf(address(this)),0); }
    function pendingNerve(uint256,address) external pure returns(uint256){ return 0; }
    function emergencyWithdraw(uint256) external {}
}
contract ElevenMockRewardChef {
    function deposit(uint256,uint256) external {}
    function pendingEleven(uint256,address) external pure returns(uint256){ return 0; }
    function userInfo(uint256,address) external pure returns(uint256,uint256){ return (0,0); }
    function emergencyWithdraw(uint256) external {}
}
contract ElevenMockNoop {
    function chargeFees(address,address) external {}
    function convert(address) external {}
}
