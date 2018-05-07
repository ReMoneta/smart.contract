pragma solidity ^0.4.18;


import './../../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol';
import './PricingStrategy.sol';


/// @title FlatPricingStrategy
/// @author Applicature
/// @notice Contract is responsible for calculating tokens amount depending on different criterias
/// @dev implementation
contract FlatPricingStrategy is PricingStrategy {


    using SafeMath for uint256;

    uint256 public tokenInWei;
    uint256 public decimals;

    function FlatPricingStrategy(uint256 _tokenInWei, uint256 _decimals) public {
        require(_tokenInWei > 0);
        tokenInWei = _tokenInWei;
        decimals = _decimals;
    }

    /// @return tokens based wei amount
    function getTokens(
        address _contributor,
        uint256 _tokensAvailable, uint256 _tokensSold,
        uint256 _weiAmount, uint256 _collectedWei
    )
    public constant
    returns (uint256 tokens, uint256 tokensExludingBonus, uint256 bonus)
    {
        // disable compilation warnings because of unused variables
        _contributor = _contributor;
        _tokensAvailable = _tokensAvailable;
        _tokensSold = _tokensSold;
        _collectedWei = _collectedWei;

        tokens = _weiAmount.mul(10 ** decimals).div(tokenInWei);
        return (tokens, tokens, 0);
    }

    /// @return weis based on required tokens
    function getWeis(uint256 _collectedWei, uint256 _collectedTokens, uint256 _tokens)
    public constant returns (uint256 weiAmount, uint256 tokensBonus)
    {
        // disable compilation warnings because of unused variables
        _collectedWei = _collectedWei;
        _collectedTokens = _collectedTokens;

        weiAmount = _tokens.mul(tokenInWei).div(10 ** decimals);

        return (weiAmount, 0);
    }

    /// @notice Check whether contract is initialised
    /// @return true if initialized
    function isInitialized() public constant returns (bool) {
        return true;
    }
}

