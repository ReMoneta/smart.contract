pragma solidity ^0.4.23;


import './../../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol';
import './PricingStrategy.sol';
import './USDExchange.sol';

/*
    Tests:
    - check getTierIndex returns  properly index
    - check getActualDates
    - check getTokens
        - zero weis  should return zero tokens
        - less than  min purchase
        - outdated
        - before sale period
        - tokens less than available
        - success for each  tier
    - check getWeis
        - zero tokens should return zero weis
        - less than  min purchase
        - outdated
        - before sale period
        - tokens less than available
        - success for each  tier
    - updateDates - changes the start and end dates
    - check that METHODS could be called only by owner
        - updateDates
*/


/// @title USDDateTiersPricingStrategy
/// @author Applicature
/// @notice Contract is responsible for calculating tokens amount depending on price in USD
/// @dev implementation
contract USDDateTiersPricingStrategy is PricingStrategy, USDExchange {

    using SafeMath for uint256;

    struct Tier {
        uint256 tokenInUSD;
        uint256 maxTokensCollected;
        uint256 discountPercents;
        uint256 minInvestInUSD;
        uint256 startDate;
        uint256 endDate;
    }

    Tier[] public tiers;
    uint256 public decimals;

    constructor(uint256[] _tiers, uint256 _decimals, uint256 _etherPriceInUSD) public
    USDExchange(_etherPriceInUSD) {
        decimals = _decimals;
        trustedAddresses[msg.sender] = true;
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
                (tiers[i].maxTokensCollected == 0 || tiers[i].maxTokensCollected > _tokensSold)
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
        _collectedWei = _collectedWei;

        if (_weiAmount == 0) {
            return (0, 0, 0);
        }

        uint256 tierIndex = getTierIndex(_tokensSold);
        uint256 usdAmount = _weiAmount.mul(etherPriceInUSD).div(uint256(10) ** 18);
        if (tierIndex < tiers.length && usdAmount < tiers[tierIndex].minInvestInUSD) {
            return (0, 0, 0);
        }
        if (tierIndex == tiers.length) {
            return (0, 0, 0);
        }
        tokens = usdAmount.mul(getTokensInUSD(tierIndex).mul(uint256(100)
            .add(getDiscount(tierIndex))).div(100)).div(10 ** 5);
        tokensExcludingBonus = tokens;
        if (tokens > _tokensAvailable) {
            return (0, 0, 0);
        }
    }

    /// @return weis based on sold and required tokens
    function getWeis(
        uint256 _collectedWei,
        uint256 _tokensSold,
        uint256 _tokens
    ) public constant returns (uint256 totalWeiAmount, uint256 tokensBonus) {
        // disable compilation warnings because of unused variables
        _collectedWei = _collectedWei;
        if (_tokens == 0) {
            return (0, 0);
        }

        uint256 tierIndex = getTierIndex(_tokensSold);
        if (tierIndex == tiers.length) {
            return (0, 0);
        }
        uint256 usdAmount = _tokens.mul(10 ** 5).div(getTokensInUSD(tierIndex));
        totalWeiAmount = usdAmount.mul(uint256(10) ** 18).div(etherPriceInUSD);

        if (totalWeiAmount < uint256(1 ether).mul(tiers[tierIndex].minInvestInUSD).div(etherPriceInUSD)) {
            return (0, 0);
        }
        uint256 tokensWithBonus = usdAmount.mul(getTokensInUSD(tierIndex).mul(uint256(100)
            .add(getDiscount(tierIndex))).div(100)).div(10 ** 5);
        return (totalWeiAmount, tokensWithBonus.sub(_tokens));
    }

    function getTokensInUSD(uint256 _tierIndex) public constant returns (uint256) {
        if (_tierIndex < uint256(tiers.length)) {
            return tiers[_tierIndex].tokenInUSD;
        }
    }

    function getDiscount(uint256 _tierIndex) public constant returns (uint256) {
        if (_tierIndex < uint256(tiers.length)) {
            return tiers[_tierIndex].discountPercents;
        }
    }

    function getUSDAmout(uint256 _weiAmount) public constant returns (uint256) {
        return _weiAmount.mul(etherPriceInUSD).div(uint256(10) ** 18);
    }

    /// @notice Check whether contract is initialised
    /// @return true if initialized
    function isInitialized() public constant returns (bool) {
        return true;
    }

    /// @notice updates tier start/end dates by id
    function updateDates(uint8 _tierId, uint256 _start, uint256 _end) public onlyOwner() {
        if (_start != 0 && _start < _end && _tierId < tiers.length) {
            Tier storage tier = tiers[_tierId];
            tier.startDate = _start;
            tier.endDate = _end;
        }
    }
}

