// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
  
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }
  
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }
  
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract LiaoToken is IERC20 {
    // TODO: you might need to declare several state variable here
    using SafeMath for uint256;
    
    uint256 public constant RATE = 3000; // Number of tokens per Ether
    uint256 public constant CAP = 5350; // Cap in Ether
    uint256 public constant START = 1519862400; // Mar 26, 2018 @ 12:00 EST
    uint256 public constant DAYS = 45; // 45 Day
    
    uint256 public constant initialTokens = 6000000 * 10**18; // Initial number of tokens available
    bool public initialized = false;
    uint256 public raisedAmount = 0;
        
    mapping(address => mapping (address => uint256)) allowed;
    mapping(address account => uint256) private _balances;
    mapping(address account => bool) isClaim;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    event Claim(address indexed user, uint256 indexed amount);

    constructor(string memory name_, string memory symbol_) payable {
        _name = name_;
        _symbol = symbol_;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function claim() external returns (bool) {
        if (isClaim[msg.sender]) revert();
        _balances[msg.sender] += 1 ether;
        _totalSupply += 1 ether;
        emit Claim(msg.sender, 1 ether);
        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        // TODO: please add your implementaiton here
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        _balances[to] = _balances[to].add(amount);
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        // TODO: please add your implementaiton here
        uint256 _allowance = allowed[from][msg.sender];
        _balances[from] = _balances[from].sub(value);
        allowed[from][msg.sender] = _allowance.sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        // TODO: please add your implementaiton here
        // assert((amount == 0) || (allowed[msg.sender][spender] == 0));

        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        // TODO: please add your implementaiton here
        return allowed[owner][spender];
    }
}
