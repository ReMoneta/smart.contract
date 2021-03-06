pragma solidity ^0.4.23;

import './crowdsale/HardCappedCrowdsale.sol';
import './contribution/DistributedDirectContributionForwarder.sol';
import './pricing/USDDateTiersPricingStrategy.sol';
import './allocator/MintableTokenAllocator.sol';


contract RETCrowdSale is HardCappedCrowdsale {

    USDDateTiersPricingStrategy public pricingStrategy;

    uint256 public constant PRE_ICO_TIER = 0;

    uint256 public  activeTier;

    constructor(
        MintableTokenAllocator _allocator,
        DistributedDirectContributionForwarder _contributionForwarder,
        USDDateTiersPricingStrategy _pricingStrategy,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _hardCap // 52 500 000 000*10^18
    ) public HardCappedCrowdsale(
        _allocator,
        _contributionForwarder,
        _pricingStrategy,
        _startTime,
        _endTime,
        true,
        true,
        false,
        _hardCap
    ) {
        pricingStrategy = USDDateTiersPricingStrategy(_pricingStrategy);
    }

    function updateState() public {
        (startDate, endDate) = pricingStrategy.getActualDates(tokensSold);

        super.updateState();
    }

    function updateHardCap(uint256 _newHardCap) public onlyOwner {
        hardCap = _newHardCap;
    }

    function internalContribution(address _contributor, uint256 _wei) internal {
        updateState();
        super.internalContribution(_contributor, _wei);
    }
}
