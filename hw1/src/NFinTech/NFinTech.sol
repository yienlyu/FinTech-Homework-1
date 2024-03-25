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

interface IERC721 {
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    // function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool approved) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
}

interface IERC721TokenReceiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        external
        returns (bytes4);
}

contract NFinTech is IERC721 {
    // Note: I have declared all variables you need to complete this challenge
    string private _name;
    string private _symbol;

    uint256 private _tokenId;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    using SafeMath for uint256;

    mapping(uint256 => address) private _owner;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApproval;
    mapping(address => bool) private isClaim;
    mapping(address => mapping(address => bool)) _operatorApproval;

    error ZeroAddress();

    constructor(string memory name_, string memory symbol_) payable {
        _name = name_;
        _symbol = symbol_;
    }

    function claim() public {
        if (isClaim[msg.sender] == false) {
            uint256 id = _tokenId;
            _owner[id] = msg.sender;

            _balances[msg.sender] += 1;
            isClaim[msg.sender] = true;

            _tokenId += 1;
        }
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function balanceOf(address owner) public view returns (uint256) {
        if (owner == address(0)) revert ZeroAddress();
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _owner[tokenId];
        if (owner == address(0)) revert ZeroAddress();
        return owner;
    }

    function setApprovalForAll(address operator, bool approved) external {
        // TODO: please add your implementaiton here
        require(operator != address(0));
        require(operator != msg.sender);
        _operatorApproval[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        // TODO: please add your implementaiton here
        return _operatorApproval[owner][operator];
    }

    function approve(address to, uint256 tokenId) external {
        // TODO: please add your implementaiton here
        address owner = ownerOf(tokenId);
        require(to != owner);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

        _tokenApproval[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address operator) {
        // TODO: please add your implementaiton here
        require(_exists(tokenId));
        return _tokenApproval[tokenId];
    }

    function transferFrom(address from, address to, uint256 tokenId) public {
        // TODO: please add your implementaiton here
        require(_isApprovedOrOwner(msg.sender, tokenId));
        require(to != address(0));

        _clearApproval(from, tokenId);
        _removeTokenFrom(from, tokenId);
        _addTokenTo(to, tokenId);

        emit Transfer(from, to, tokenId);
    }

    // function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) public {
    //     // TODO: please add your implementaiton here
    //     transferFrom(from, to, tokenId);
    //     require(_checkOnERC721Received(from, to, tokenId, data));
    // }

    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        // TODO: please add your implementaiton here
        transferFrom(from, to, tokenId);
        require(IERC721TokenReceiver(address(to)).onERC721Received(from, to, tokenId, "") == IERC721TokenReceiver.onERC721Received.selector, "Wrong selector");
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        address owner = _owner[tokenId];
        return owner != address(0);
    }

    function _isApprovedOrOwner(
        address spender,
        uint256 tokenId
    )
        internal
        view
        returns (bool)
    {
        address owner = ownerOf(tokenId);
        
        return (
        spender == owner ||
        getApproved(tokenId) == spender ||
        isApprovedForAll(owner, spender)
        );
    }

    function _addTokenTo(address to, uint256 tokenId) internal {
        require(_owner[tokenId] == address(0));
        _owner[tokenId] = to;
        _balances[to] = _balances[to].add(1);
    }


    function _removeTokenFrom(address from, uint256 tokenId) internal {
        require(ownerOf(tokenId) == from);
        _balances[from] = _balances[from].sub(1);
        _owner[tokenId] = address(0);
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function _clearApproval(address owner, uint256 tokenId) private {
        require(ownerOf(tokenId) == owner);
        if (_tokenApproval[tokenId] != address(0)) {
            _tokenApproval[tokenId] = address(0);
        }
    }
}
