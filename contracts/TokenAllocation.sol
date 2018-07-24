pragma solidity ^0.4.23;

import './allocator/MintableTokenAllocator.sol';
import './RETCrowdSale.sol';
import './RETStrategy.sol';
import './RETToken.sol';
import './Referral.sol';


contract TokenAllocation is Ownable, Referral {

    using SafeMath for uint256;

    uint256 public constant TREASURY_TOKENS = 20000000000e18;
    uint256 public constant BANCOR_TOKENS = 20000000000e18;

    address public team = 0x0;
    address public advisory = 0x0;
    address public treasury = 0x0;
    address public earlyInvestors = 0x0;
    address public bancor = 0x0;

    RETCrowdSale public crowdsale;
    RETStrategy public pricingStrategy;

    uint256 public vestingStartDate;

    mapping(address => bool) public tokenInited;

    event BountySent(address receiver, uint256 amount);
    event BonusSent(address receiver, uint256 amount);
    event ReferralSent(address receiver, uint256 amount);

    constructor(RETCrowdSale _crowdsale, address _allocator) public Referral(0, _allocator, _crowdsale, true) {
        require(address(0) != address(_crowdsale));
        crowdsale = RETCrowdSale(_crowdsale);
        pricingStrategy = RETStrategy(address(crowdsale.pricingStrategy()));
        uint256[6] memory tiersData = pricingStrategy.getArrayOfTiers();
        vestingStartDate = tiersData[5].add(30 days);
    }

    function setCrowdsale(address _crowdsale) public onlyOwner {
        super.setCrowdsale(_crowdsale);
        pricingStrategy = RETStrategy(crowdsale.pricingStrategy());
        uint256[6] memory tiersData = pricingStrategy.getArrayOfTiers();
        vestingStartDate = tiersData[5].add(30 days);
    }

    function setVestingStartDate(uint256 _vestingStartDate) public onlyOwner {
        vestingStartDate = _vestingStartDate;
    }

    function setAddresses(
        address _team,
        address _advisory,
        address _treasury,
        address _earlyInvestors,
        address _bancor
    ) public onlyOwner {
        require(
            _team != address(0) &&
            _advisory != address(0) &&
            _treasury != address(0) &&
            _earlyInvestors != address(0) &&
            _bancor != address(0)
        );
        team = _team;
        advisory = _advisory;
        treasury = _treasury;
        earlyInvestors = _earlyInvestors;
        bancor = _bancor;
    }

    function sendBancorTokens(MintableTokenAllocator _allocator) public onlyOwner {
        require(tokenInited[bancor] == false && bancor != address(0));
        tokenInited[bancor] = true;
        RETToken token = RETToken(address(_allocator.token()));
        _allocator.allocate(bancor, BANCOR_TOKENS);
    }

    function allocate(MintableTokenAllocator _allocator, uint256 _bonusAmount) public onlyOwner() {
        require(tokenInited[address(_allocator.token)] == false);
        require(vestingStartDate <= block.timestamp);

        tokenInited[address(_allocator.token)] = true;

        // sold  tokens  +  bonuses
        uint256 soldTokens = crowdsale.tokensSold().add(_bonusAmount);

        vestingMintInternal(
            team,
            _allocator,
            soldTokens.mul(2).div(100),
            vestingStartDate.add(uint256(365 days).div(2)),
            720 days,
            0,
            30 days
        );

        //50%  within two years
        vestingMintInternal(
            advisory,
            _allocator,
            soldTokens.mul(4).div(100),
            vestingStartDate,
            720 days,
            50,
            30 days
        );
        vestingMintInternal(
            earlyInvestors,
            _allocator,
            soldTokens.mul(3).div(100),
            vestingStartDate,
            90 days,
            50,
            30 days
        );
        _allocator.allocate(treasury, TREASURY_TOKENS);
    }

    function multivestMint(
        address _address,
        uint256[3] _amount,
        MintableTokenAllocator _allocator,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public {
        require(vestingStartDate <= block.timestamp);
        if (_amount[0] != 0 || _amount[1] != 0 || _amount[2] != 0) {
            uint256 amount = _amount[0].add(_amount[1]).add(_amount[2]);
            super.multivestMint(_address, amount, _v, _r, _s);
            emit BountySent(_address, _amount[0]);
            emit BonusSent(_address, _amount[1]);
            emit ReferralSent(_address, _amount[2]);
        }
        RETToken token = RETToken(address(_allocator.token()));
        token.setKYCState(_address, true);
    }

    function vestingMint(
        address _address,
        MintableTokenAllocator _allocator,
        uint256 _amount,
        uint256 _startingAt,
        uint256 _lockPeriod,
        uint256 _initialUnlock,
        uint256 _releasePeriod
    ) public onlyOwner {
        vestingMintInternal(
            _address,
            _allocator,
            _amount,
            _startingAt,
            _lockPeriod,
            _initialUnlock,
            _releasePeriod
        );
    }

    function vestingMintInternal(
        address _address,
        MintableTokenAllocator _allocator,
        uint256 _amount,
        uint256 _startingAt,
        uint256 _lockPeriod,
        uint256 _initialUnlock,
        uint256 _releasePeriod
    ) internal {
        require(_amount > 0);
        RETToken token = RETToken(address(_allocator.token()));
        token.allocationLog(_address, _amount, _startingAt, _lockPeriod, _initialUnlock, _releasePeriod);
        _allocator.allocate(_address, _amount);
        token.setKYCState(_address, true);
    }
}