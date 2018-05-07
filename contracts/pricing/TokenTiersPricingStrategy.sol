pragma solidity ^0.4.18;


import './../../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol';
import './PricingStrategy.sol';


/// @title TokenTiersPricingStrategy
/// @author Applicature
/// @notice Contract is responsible for calculating tokens amount depending on different criterias
/// @dev implementation
contract TokenTiersPricingStrategy is PricingStrategy {


    using SafeMath for uint256;

    struct Tier {
        uint256 tokenInWei;
        uint256 maxTokensCollected;
    }

    Tier[] public tiers;
    uint256 public decimals;

    function TokenTiersPricingStrategy(uint256[] _tiers, uint256 _decimals) public {
        decimals = _decimals;

        require(_tiers.length % 2 == 0);

        uint256 length = _tiers.length / 2;

        for (uint256 i = 0; i < length; i++) {
            tiers.push(Tier(_tiers[i * 2], _tiers[i * 2 + 1]));
        }
    }

    /// @return tier index
    function getTierIndex(uint256 _tokensSold) public constant returns (uint256) {
        for (uint256 i = 0; i < tiers.length; i++) {
            if (tiers[i].maxTokensCollected > _tokensSold) {
                return i;
            }
        }

        return tiers.length;
    }

    /// @return tokens based on sold tokens and wei amount
    function getTokens(
        address _contributor,
        uint256 _tokensAvailable, uint256 _tokensSold,
        uint256 _weiAmount, uint256 _collectedWei
    )
    public constant returns (uint256 tokens, uint256 tokensExludingBonus, uint256 bonus)
    {
        // disable compilation warnings because of unused variables
        _contributor = _contributor;
        _tokensAvailable = _tokensAvailable;
        _collectedWei = _collectedWei;

        uint256 tierIndex = getTierIndex(_tokensSold);

        uint256 remainingWei = _weiAmount;

        uint256 newTokensSold = _tokensSold;

        for (uint256 i = tierIndex; i < tiers.length; i++) {
            uint256 tierTokens = remainingWei.div(tiers[i].tokenInWei);

            if (newTokensSold.add(tierTokens) > tiers[i].maxTokensCollected) {
                uint256 diff = tiers[i].maxTokensCollected.sub(newTokensSold);

                tokens = tokens.add(diff);

                remainingWei = remainingWei.sub(diff.mul(tiers[i].tokenInWei));

                newTokensSold = newTokensSold.add(diff);
            } else {
                remainingWei = 0;

                tokens = tokens.add(tierTokens);

                newTokensSold = newTokensSold.add(tierTokens);
            }

            if (remainingWei == 0) {
                break;
            }
        }

        if (remainingWei > 0) {
            tokens = 0;
        }

        return (tokens, tokens, 0);
    }

    /// @return weis based on sold and required tokens
    function getWeis(uint256 _collectedWei, uint256 _tokensSold, uint256 _tokens)
    public constant returns (uint256 totalWeiAmount, uint256 tokensBonus)
    {
        // disable compilation warnings because of unused variables
        _collectedWei = _collectedWei;

        uint256 tierIndex = getTierIndex(_tokensSold);

        uint256 remainingTokens = _tokens;
        uint256 newTokensSold = _tokensSold;

        for (uint i = tierIndex; i < tiers.length; i++) {

            if (newTokensSold.add(remainingTokens) > tiers[i].maxTokensCollected) {
                uint256 diff = tiers[i].maxTokensCollected.sub(newTokensSold);

                remainingTokens = remainingTokens.sub(diff);

                totalWeiAmount = totalWeiAmount.add(diff.mul(tiers[i].tokenInWei));
            } else {
                totalWeiAmount = totalWeiAmount.add(remainingTokens.mul(tiers[i].tokenInWei));

                remainingTokens = 0;
            }

            if (remainingTokens == 0) {
                break;
            }
        }

        if (remainingTokens > 0) {
            totalWeiAmount = 0;
        }

        return (totalWeiAmount, 0);
    }

    /// @notice Check whether contract is initialised
    /// @return true if initialized
    function isInitialized() public constant returns (bool) {
        return true;
    }
}

