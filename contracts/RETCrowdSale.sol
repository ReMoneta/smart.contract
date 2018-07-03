pragma solidity ^0.4.23;

import './crowdsale/RefundableCrowdsale.sol';
import './contribution/DistributedDirectContributionForwarder.sol';
import './pricing/USDDateTiersPricingStrategy.sol';
import './allocator/MintableTokenAllocator.sol';


contract RETCrowdSale is RefundableCrowdsale {

    USDDateTiersPricingStrategy public pricingStrategy;

    uint256 public constant PRE_ICO_TIER = 0;
    uint256 public constant ICO_TIER = 1;

    uint256 public  activeTier;

    constructor(
        MintableTokenAllocator _allocator,
        DistributedDirectContributionForwarder _contributionForwarder,
        USDDateTiersPricingStrategy _pricingStrategy,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _softCap, // (5000000/ 0.01)*100*10^18
        uint256 _hardCap // (5000000/ 0.01)*100*10^18
    ) public RefundableCrowdsale(
        _allocator,
        _contributionForwarder,
        _pricingStrategy,
        _startTime,
        _endTime,
        true,
        true,
        false,
        _softCap,
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
