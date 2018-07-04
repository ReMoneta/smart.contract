import '../crowdsale/RefundableCrowdsale.sol';


contract RCrowdsaleTest is RefundableCrowdsale {


    constructor(
    TokenAllocator _allocator,
    ContributionForwarder _contributionForwarder,
    PricingStrategy _pricingStrategy,
    uint256 _startDate,
    uint256 _endDate,
    bool _allowWhitelisted,
    bool _allowSigned,
    bool _allowAnonymous,
    uint256 _softCap,
    uint256 _hardCap

    )
    public
    RefundableCrowdsale(
    _allocator, _contributionForwarder, _pricingStrategy,
    _startDate, _endDate,
    _allowWhitelisted, _allowSigned, _allowAnonymous, _softCap, _hardCap
    )
    {

    }

    uint256 public endDate;

    function updateEndDate(uint256 _endDate) public onlyOwner {
        endDate = _endDate;
    }
}

