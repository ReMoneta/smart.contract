pragma solidity ^0.4.18;

import './../../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol';
import './TokenAllocator.sol';
import '../token/erc223/ERC223Token.sol';


/// @title ERC223TokenAllocator
/// @author Applicature
/// @notice Contract responsible for defining distribution logic of tokens.
/// supports ERC223 standarts tokens
/// @dev implementation
contract ERC223TokenAllocator is TokenAllocator {

    ERC223Token public token;

    function ERC223TokenAllocator(ERC223Token _token) public {
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

    /// @notice update instance of ERC223Token
    function setToken(ERC223Token _token) public onlyOwner {
        token = _token;
    }

    function internalAllocate(address _holder, uint256 _tokens) internal {

        // transfer will check whether recipient is a user or contract
        // and choose internal implementation
//        bytes _data =  hex'00';
        token.transfer(_holder, _tokens, '0');
        // another possible option is with custom fallback
        // transfer(address _to, uint _value, bytes _data, string _custom_fallback)
    }
}
