pragma solidity ^0.4.23;

import './RETCrowdSale.sol';
import './token/erc20/MintableToken.sol';
import './RETStrategy.sol';
import '../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol';


contract RETStatsContract {
    using SafeMath for uint256;

    MintableToken public token;
    RETCrowdSale public crowdsale;
    RETStrategy public strategy;

    constructor(
        MintableToken _token,
        RETCrowdSale _crowdsale
    ) public {
        token = _token;
        crowdsale = _crowdsale;
        strategy = RETStrategy(crowdsale.pricingStrategy());
    }

    function getTokens(
        uint256 _weiAmount
    ) public view returns (uint256 tokens, uint256 tokensExcludingBonus, uint256 bonus) {
        return strategy.getTokens(
            address(0),
            uint256(crowdsale.hardCap()).sub(crowdsale.tokensSold()),
            crowdsale.tokensSold(),
            _weiAmount,
            0
        );
    }

    function getStats(uint256 _ethPerBtc) public view returns (
        uint256 start,
        uint256 end,
        uint256 sold,
        uint256 hardCap,
        uint256 activeTier,
        uint256 tokensPerUSD,
        uint256[3] ethContr, //tokensPerEth, shares,
        uint256[3] bthContr, // tokensPerBtc, shares,
        uint256[12] tiersData
    ) {
        activeTier = strategy.getTierIndex(0);
        tiersData = strategy.getArrayOfTiers();
        if (activeTier.mul(6).add(3) >= 12) {
            tokensPerUSD = 0;
        } else {
            tokensPerUSD = tiersData[activeTier.mul(6)];
        }
        start = crowdsale.startDate();
        end = crowdsale.endDate();
        sold = crowdsale.tokensSold();
        hardCap = crowdsale.hardCap();
        (ethContr[0], ethContr[1], ethContr[2]) = strategy.getTokens(0x0, hardCap.sub(sold), sold, 1 ether, 0);
        (bthContr[0], bthContr[1], bthContr[2]) = strategy.getTokens(0x0, hardCap.sub(sold), sold, _ethPerBtc, 0);

    }

}
