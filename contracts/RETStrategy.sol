pragma solidity 0.4.24;

import './pricing/USDDateTiersPricingStrategy.sol';


contract RETStrategy is USDDateTiersPricingStrategy {

    constructor(uint256[] emptyArray, uint256[2] _periods, uint256 _etherPriceInUSD)
    public USDDateTiersPricingStrategy(emptyArray, 18, _etherPriceInUSD) {
        tiers.push(Tier(uint256(10000).mul(10 ** 18), 0, 0, 10000000, _periods[0], _periods[1]));
    }

    function getArrayOfTiers() public view returns (uint256[6] tiersData) {
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

    function setMinUSDInvest(uint256 _newValue) public onlyOwner {
        Tier storage tier = tiers[0];
        tier.minInvestInUSD = _newValue;
    }
}
