pragma solidity ^0.4.18;


import './../../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol';
import './PricingStrategy.sol';


/// @title TokenTiersPricingStrategy
/// @author Applicature
/// @notice Contract is responsible for calculating tokens amount depending on different criterias
/// @dev implementation
contract TokenDateBonusTiersPricingStrategy is PricingStrategy {

    using SafeMath for uint256;

    struct Tier {
        uint256 tokenInWei;
        uint256 maxTokensCollected;
        uint256 bonusPercents;
        uint256 minInvestInWei;
        uint256 startDate;
        uint256 endDate;
    }

    Tier[] public tiers;
    uint256 public decimals;

    function TokenDateBonusTiersPricingStrategy(uint256[] _tiers, uint256 _decimals) public {
        decimals = _decimals;

        require(_tiers.length % 6 == 0);

        uint256 length = _tiers.length / 6;

        for (uint256 i = 0; i < length; i++) {
            tiers.push(
                Tier(
                    _tiers[i * 6],
                    _tiers[i * 6 + 1],
                    _tiers[i * 6 + 2],
                    _tiers[i * 6 + 3],
                    _tiers[i * 6 + 4],
                    _tiers[i * 6 + 5]
                )
            );
        }
    }

    /// @return tier index
    function getTierIndex(uint256 _tokensSold) public constant returns (uint256) {
        for (uint256 i = 0; i < tiers.length; i++) {
            if (
                block.timestamp >= tiers[i].startDate &&
                block.timestamp < tiers[i].endDate &&
                tiers[i].maxTokensCollected > _tokensSold
            ) {
                return i;
            }
        }

        return tiers.length;
    }

    /// @return actual dates
    function getActualDates(uint256 _tokensSold) public constant returns (uint256 startDate, uint256 endDate) {
        uint256 tierIndex = getTierIndex(_tokensSold);
        if (tierIndex < tiers.length) {
            startDate = tiers[tierIndex].startDate;
            endDate = tiers[tierIndex].endDate;
        } else {
            for (uint256 i = 0; i < tiers.length; i++) {
                if (
                    block.timestamp < tiers[i].startDate
                ) {
                    startDate = tiers[i].startDate;
                    endDate = tiers[i].endDate;
                    break;
                }
            }
        }

        if (startDate == 0) {
            startDate = tiers[tiers.length.sub(1)].startDate;
            endDate = tiers[tiers.length.sub(1)].endDate;
        }
    }

    /// @return tokens based on sold tokens and wei amount
    function getTokens(
        address _contributor,
        uint256 _tokensAvailable,
        uint256 _tokensSold,
        uint256 _weiAmount,
        uint256 _collectedWei
    ) public constant returns (uint256 tokens, uint256 tokensExcludingBonus, uint256 bonus) {
        // disable compilation warnings because of unused variables
        _contributor = _contributor;
        _tokensAvailable = _tokensAvailable;
        _collectedWei = _collectedWei;

        uint256 tierIndex = getTierIndex(_tokensSold);

        if (tierIndex < tiers.length && _weiAmount < tiers[tierIndex].minInvestInWei) {
            return (0, 0, 0);
        }

        uint256 remainingWei = _weiAmount;
        uint256 newTokensSold = _tokensSold;

        for (uint256 i = tierIndex; i < tiers.length; i++) {

            uint256 tierTokens = remainingWei.mul(uint256(10) ** decimals).div(tiers[i].tokenInWei);

            if (newTokensSold.add(tierTokens) > tiers[i].maxTokensCollected) {
                uint256 diff = tiers[i].maxTokensCollected.sub(newTokensSold);

                tokens = tokens.add(diff);
                bonus = bonus.add(diff.mul(tiers[i].bonusPercents).div(100));

                remainingWei = remainingWei.sub(diff.mul(tiers[i].tokenInWei));

                newTokensSold = newTokensSold.add(diff);
            } else {
                remainingWei = 0;

                tokens = tokens.add(tierTokens);
                bonus = bonus.add(tierTokens.mul(tiers[i].bonusPercents).div(100));

                newTokensSold = newTokensSold.add(tierTokens);
            }

            if (remainingWei == 0) {
                break;
            }
        }

        if (remainingWei > 0) {
            tokens = 0;
            bonus = 0;
        }

        tokensExcludingBonus = tokens;
        tokens = tokens.add(bonus);
    }

    /// @return weis based on sold and required tokens
    function getWeis(
        uint256 _collectedWei,
        uint256 _tokensSold,
        uint256 _tokens
    ) public constant returns (uint256 totalWeiAmount, uint256 tokensBonus) {
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

//    /// @notice updates tier start/end dates by id
//    function updateDates(uint8 _tierId, uint256 _start, uint256 _end) public onlyOwner {
//        if (_start != 0 && _start < _end && _tierId < tiers.length) {
//            Tier storage tier = tiers[_tierId];
//            tier.startDate = _start;
//            tier.endDate = _end;
//        }
//    }
}

