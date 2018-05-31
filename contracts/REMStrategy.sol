pragma solidity ^0.4.0;

import './pricing/USDDateTiersPricingStrategy.sol';


contract REMStrategy is USDDateTiersPricingStrategy {

    constructor(
        uint256[] emptyArray,
        uint256[2] _preIcoPeriods,
        uint256[2] _icoPeriods,
        uint256 _etherPriceInUSD
    ) public
    USDDateTiersPricingStrategy(emptyArray, 18, _etherPriceInUSD) {
        tiers.push(Tier(uint256(10000).mul(10**18), 0, 0, 10000000, _preIcoPeriods[0], _preIcoPeriods[1]));
        tiers.push(Tier(uint256(10000).mul(10**18), 0, 0, 1000000, _icoPeriods[0], _icoPeriods[1]));
    }

    function getArrayOfTiers() public view returns (uint256[12] tiersData) {
        uint256 j = 0;
        for (uint256 i = 0; i < tiers.length; i++) {
            tiersData[j++] = uint256(tiers[i].tokenInUSD);
            tiersData[j++] = uint256(tiers[i].maxTokensCollected);
            tiersData[j++] = uint256(tiers[i].discountPercents);
            tiersData[j++] = uint256(tiers[i].minInvestInUSD);
            tiersData[j++] = uint256(tiers[i].startDate);
            tiersData[j++] = uint256(tiers[i].endDate);
        }
    }
}
