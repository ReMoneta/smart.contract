pragma solidity ^0.4.23;


import './../../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol';
import './TokenAllocator.sol';
import '../token/erc20/IErc20.sol';


/// @title HolderTokenAllocator
/// @author Applicature
/// @notice Contract responsible for defining distribution logic of tokens.
/// @dev implementation
contract HolderTokenAllocator is TokenAllocator {
    using SafeMath for uint256;

    IErc20 public token;

    constructor(IErc20 _token) public {
        require(address(0) != address(_token));
        token = _token;
    }

    /// @notice transfer tokens on holder account
    function allocate(address _holder, uint256 _tokens) public onlyCrowdsale() {
        internalAllocate(_holder, _tokens);
    }

    /// @return available tokens
    function tokensAvailable() public constant returns (uint256) {
        return token.balanceOf(this);
    }

    /// @notice Check whether contract is initialised
    /// @return true if initialized
    function isInitialized() public constant returns (bool) {
        return true;
    }

    /// @notice update instance of MintableToken
    function setToken(IErc20 _token) public onlyOwner {
        token = _token;
    }

    function internalAllocate(address _holder, uint256 _tokens) internal {
        token.transfer(_holder, _tokens);
    }

}

