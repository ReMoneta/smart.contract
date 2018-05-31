pragma solidity ^0.4.23;

import './../../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol';
import './TokenAllocator.sol';
import '../token/erc827/ERC827Token.sol';


/// @title ERC827TokenAllocator
/// @author Applicature
/// @notice Contract responsible for defining distribution logic of tokens.
/// supports ERC827 standarts tokens
/// @dev implementation
contract ERC827TokenAllocator is TokenAllocator {

    ERC827Token public token;

    constructor(ERC827Token _token) public {
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

    /// @notice update instance of ERC827Token
    function setToken(ERC827Token _token) public onlyOwner {
        token = _token;
    }

    function internalAllocate(address _holder, uint256 _tokens) internal {

        // Execute a function on _to with the _data parameter,
        // if the function ends successfully execute the transfer of _value amount of tokens to address _to,
        // and fire the emit Transfer event.
        // the third param is data which can be used if necessary
        token.transfer(_holder, _tokens, '0');

    }
}

