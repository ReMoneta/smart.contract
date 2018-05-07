pragma solidity 0.4.19;

import "./crowdsale/RefundableCrowdsale.sol";
import "./contribution/DistributedDirectContributionForwarder.sol";
import "./pricing/USDDateTiersPricingStrategy.sol";
import "./allocator/MintableTokenAllocator.sol";

//TestCases
/*
  - deploy contract & set allocator and pricing strategy, check if the params  are equal
    - check  if updateState updates start and end dates
    - check contribution
        - only multivest pro is allowed
        - zero weis  should fail
        - less than  min purchase  should fail (100$ and 10$)
        - outdated  should fail
        - before sale period  should fail
        - tokens less than for all tiers  should fail
        - tokens amount is calculated according to discount
        - success for each  tier (updates  total suply, tokens available, collectedEthers...)
    - withdrawing is impossible till the softcap collected;
    - hardCap can be changed by Owner Only
    -check lockup period

*/

contract REMCrowdSale is RefundableCrowdsale {

    USDDateTiersPricingStrategy public pricingStrategy;

    uint256 public constant PRE_ICO_TIER = 0;
    uint256 public constant ICO_TIER = 1;


    mapping(address => uint256) public contributorBonuses;

    function REMCrowdSale(
        MintableTokenAllocator _allocator,
        DistributedDirectContributionForwarder _contributionForwarder,
        USDDateTiersPricingStrategy _pricingStrategy,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _softCap,// (5000000/ 0.01)*100*10^18
        uint256 _hardCap // (5000000/ 0.01)*100*10^18
    ) public
        RefundableCrowdsale(
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
        )
    {
        pricingStrategy = USDDateTiersPricingStrategy(_pricingStrategy);
    }

    function updateState() public {
        (startDate, endDate) = pricingStrategy.getActualDates(tokensSold);

        super.updateState();
    }

    function internalContribution(address _contributor, uint256 _wei) internal {
        updateState();
        super.internalContribution(_contributor, _wei);
    }


}
