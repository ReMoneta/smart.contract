pragma solidity ^0.4.18;


import './../../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol';
import './PricingStrategy.sol';


/// @title EtherTiersPricingStrategy
/// @author Applicature
/// @notice Contract is responsible for calculating tokens amount depending on different criterias
/// @dev implementation
contract EtherTiersPricingStrategy is PricingStrategy {


    using SafeMath for uint256;

    struct Tier {
        uint256 tokenInWei;
        uint256 maxWeiCollected;
    }

    Tier[] public tiers;
    uint256 public decimals;

    function EtherTiersPricingStrategy(uint256[] _tiers, uint256 _decimals) public {
        decimals = _decimals;
        require(_tiers.length % 2 == 0);

        uint256 length = _tiers.length / 2;

        for (uint256 i = 0; i < length; i++) {
            tiers.push(Tier(_tiers[i * 2], _tiers[i * 2 + 1]));
        }

        require(tiers.length > 0);
    }

    /// @notice Check whether contract is initialised
    /// @return true if initialized
    function isInitialized() public constant returns (bool) {
        return true;
    }

    /// @return return tier index
    function getTierIndex(uint256 _collectedWei) public constant returns (uint256) {
        for (uint256 i = 0; i < tiers.length; i++) {
            if (tiers[i].maxWeiCollected > _collectedWei) {
                return i;
            }
        }

        return tiers.length;
    }

    /// @return tokens based wei amount and collected wei
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
        _tokensSold = _tokensSold;

        uint256 newCollectedWei = _collectedWei;

        uint256 tierIndex = getTierIndex(_collectedWei);

        uint256 remainingWei = _weiAmount;

        for (uint256 i = tierIndex; i < tiers.length; i++) {
            if (newCollectedWei + remainingWei > tiers[i].maxWeiCollected) {
                uint256 tierWeiAmount = tiers[i].maxWeiCollected.sub(newCollectedWei);

                remainingWei = remainingWei.sub(tierWeiAmount);
                newCollectedWei = newCollectedWei.add(tierWeiAmount);

                tokens = tokens.add(tierWeiAmount.mul(10 ** decimals).div(tiers[i].tokenInWei));
            } else {
                tokens = tokens.add(remainingWei.mul(10 ** decimals).div(tiers[i].tokenInWei));

                remainingWei = 0;
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

    /// @return weis based on sold tokens and required tokens
    function getWeis(uint256 _collectedWei, uint256 _tokensSold, uint256 _tokens)
    public constant returns (uint256 totalWeiAmount, uint256 tokensBonus)
    {
        // disable compilation warnings because of unused variables
        _collectedWei = _collectedWei;

        uint256 leftTokens = _tokens;

        uint256 prevTierWeiCollected;
        uint256 overallTokens;

        for (uint256 i = 0; i < tiers.length; i++) {
            uint256 tierTokens = (tiers[i].maxWeiCollected.sub(prevTierWeiCollected))
                .mul(10 ** decimals).div(tiers[0].tokenInWei);

            if (_tokensSold > overallTokens.add(tierTokens)) {
                prevTierWeiCollected = tiers[i].maxWeiCollected;
                overallTokens = overallTokens.add(tierTokens);

                continue;
            }

            uint256 weiAmount;

            if (_tokensSold.add(leftTokens) > overallTokens.add(tierTokens)) {
                uint256 tokensForTier = overallTokens.add(tierTokens).sub(_tokensSold);

                leftTokens = leftTokens.sub(tokensForTier);

                weiAmount = tokensForTier.mul(tiers[i].tokenInWei).div(decimals);

                totalWeiAmount = totalWeiAmount.add(weiAmount);
            } else {
                weiAmount = leftTokens.mul(tiers[i].tokenInWei).div(decimals);

                leftTokens = 0;

                totalWeiAmount = totalWeiAmount.add(weiAmount);
            }
        }

        if (leftTokens > 0) {
            weiAmount = 0;
        }

        return (weiAmount, 0);
    }
}

