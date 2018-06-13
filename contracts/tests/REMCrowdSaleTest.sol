pragma solidity ^0.4.23;

import '../RETCrowdSale.sol';


contract RETCrowdSaleTest is RETCrowdSale {


    constructor(
        MintableTokenAllocator _allocator,
        DistributedDirectContributionForwarder _contributionForwarder,
        USDDateTiersPricingStrategy _pricingStrategy,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _softCap,// (5000000/ 0.01)*100*10^18
        uint256 _hardCap // (5000000/ 0.01)*100*10^18
    ) public
    RETCrowdSale(
            _allocator,
            _contributionForwarder,
            _pricingStrategy,
            _startTime,
            _endTime,
            _softCap,
            _hardCap
        )
    {
    }

    function updateSoldTokens(uint256 _tokensSold) public {
        tokensSold = _tokensSold;
    }

    function updateSoftCap(uint256 _softCap) public {
        softCap = _softCap;
    }
}
