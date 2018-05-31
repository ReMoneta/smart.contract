pragma solidity ^0.4.23;


/// @title ERC721
/// @author Applicature
/// @notice ERC721 token standard
/// @dev Base class
contract ERC721 {
    // ERC20 compatible functions
    function name() public constant returns (string);

    function symbol() public constant returns (string);

    function totalSupply() public constant returns (uint256);

    function balanceOf(address _owner) public constant returns (uint balance);
    // Functions that define ownership
    function ownerOf(uint256 _tokenId) public constant returns (address owner);

    function approve(address _to, uint256 _tokenId) public;

    function takeOwnership(uint256 _tokenId) public;

    function transfer(address _to, uint256 _tokenId) public;

    function tokenOfOwnerByIndex(address _owner, uint256 _index) public constant returns (uint tokenId);
    // Token metadata
    function tokenMetadata(uint256 _tokenId) public constant returns (string infoUrl);
    // Events
    event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
}