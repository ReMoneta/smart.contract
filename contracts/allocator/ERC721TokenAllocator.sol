pragma solidity ^0.4.18;

import './../../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol';
import './TokenAllocator.sol';
import '../token/erc721/ERC721Token.sol';


/// @title ERC721TokenAllocator
/// @author Applicature
/// @notice Contract responsible for defining distribution logic of tokens.
/// supports ERC721 standarts tokens
/// @dev implementation
contract ERC721TokenAllocator is TokenAllocator {

    ERC721Token public token;

    function erc223TokenAllocator(ERC721Token _token) public {
        require(address(0) != address(_token));
        token = _token;
    }

    /// @notice Check whether contract is initialised
    /// @return true if initialized
    function isInitialized() public constant returns (bool) {
        return true;
    }

    /// @notice transfer tokens on holder account
    function allocate(address _holder, uint256 _tokens) public onlyCrowdsale() {
        internalAllocate(_holder, _tokens);
    }

    /// @return available tokens
    function tokensAvailable() public constant returns (uint256) {
        return token.balanceOf(this);
    }

    /// @notice update instance of ERC721Token
    function setToken(ERC721Token _token) public onlyOwner {
        token = _token;
    }

    function internalAllocate(address _holder, uint256 _tokenId) internal {
        token.approve(_holder, _tokenId);
        token.transfer(_holder, _tokenId);
    }
}

