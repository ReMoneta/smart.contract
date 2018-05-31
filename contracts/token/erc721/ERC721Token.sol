pragma solidity ^0.4.23;

import './ERC721.sol';


/// @title ERC721
/// @author Applicature
/// @notice ERC721 token standard
/// @dev Base class
contract ERC721Token is ERC721 {

    string public name;
    string public symbol;
    uint256 public _totalSupply;
    uint256 public decimals;
    mapping(address => uint256) public balances;
    mapping(uint256 => address) private tokenOwners;
    mapping(address => uint256[]) private ownerTokens;
    mapping(uint256 => bool) private tokenExists;
    mapping(address => mapping(address => uint256)) public allowed;
    mapping(uint256 => string) public tokenLinks;


    // Events
    event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);

    constructor (string _name, string _symbol, uint8 _decimals, uint256 total) public {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        _totalSupply = total;
    }

    /// @return name of token
    function name() public view returns (string) {
        return name;
    }

    /// @return symbol of token
    function symbol() public view returns (string) {
        return symbol;
    }

    /// @return decimals of token
    function decimals() public view returns (uint256) {
        return decimals;
    }

    /// @return total supply of token
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /// @return current balance of address
    function balanceOf(address _owner) public view returns (uint) {
        return balances[_owner];
    }

    // Functions that define ownership
    function ownerOf(uint256 _tokenId) public constant returns (address owner) {
        require(tokenExists[_tokenId]);
        return tokenOwners[_tokenId];
    }

    /// @notice approve a new ownership
    function approve(address _to, uint256 _tokenId) public {
        require(msg.sender == ownerOf(_tokenId));
        require(msg.sender != _to);
        allowed[msg.sender][_to] = _tokenId;
        emit Approval(msg.sender, _to, _tokenId);
    }

    /// @notice first call approve on a new ownership
    function takeOwnership(uint256 _tokenId) public {
        require(tokenExists[_tokenId]);
        address oldOwner = ownerOf(_tokenId);
        address newOwner = msg.sender;
        require(newOwner != oldOwner);
        require(allowed[oldOwner][newOwner] == _tokenId);
        balances[oldOwner] -= 1;
        tokenOwners[_tokenId] = newOwner;
        balances[newOwner] += 1;
        emit Transfer(oldOwner, newOwner, _tokenId);
    }

    /// @notice transfer token from prev to new owner
    function transfer(address _to, uint256 _tokenId) public {
        address currentOwner = msg.sender;
        address newOwner = _to;
        require(tokenExists[_tokenId]);
        require(currentOwner == ownerOf(_tokenId));
        require(currentOwner != newOwner);
        require(newOwner != address(0));
        removeFromTokenList(currentOwner, _tokenId);
        balances[currentOwner] -= 1;
        tokenOwners[_tokenId] = newOwner;
        balances[newOwner] += 1;
        emit Transfer(currentOwner, newOwner, _tokenId);
    }

    /// @notice Each non-fungible token owner can own more than one token at one time.
    /// @return token index
    function tokenOfOwnerByIndex(address _owner, uint256 _index) public constant returns (uint tokenId) {
        return ownerTokens[_owner][_index];
    }

    /// @return meta data of token
    function tokenMetadata(uint256 _tokenId) public constant returns (string infoUrl) {
        return tokenLinks[_tokenId];
    }

    function removeFromTokenList(address owner, uint256 _tokenId) private {
        for (uint256 i = 0; ownerTokens[owner][i] != _tokenId; i++) {
            ownerTokens[owner][i] = 0;
        }
    }
}

