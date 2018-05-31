pragma solidity ^0.4.23;

import './allocator/MintableTokenAllocator.sol';
import './REMCrowdSale.sol';
import './REMStrategy.sol';
import './REMToken.sol';
import './Referral.sol';

/*
    Tests:
    - check that initVesting could be called only once
    - check that after creation all balances (owners, funds, team) are null
    - check that after creation & initVesting all balances (owners, funds, team) are null
    - check that after creation & initVesting, allocate - all balances are filled (owners, funds, team)
    - check that after creation & initVesting, allocate - subsequent calls of `allocate` should fail
    - check that created vesting has correctly inited variables (equal what was send to createVesting)
    - check that METHODS could be called only by owner
        - initVesting
        - createVesting
        - revokeVesting
*/


contract TokenAllocation is Ownable, Referral {
    //    using SafeERC20 for ERC20Basic;
    using SafeMath for uint256;

    address public team = 0x0;
    address public advisory = 0x0;
    address public treasury = 0x0;
    address public earlyInvestors = 0x0;
    address public bancor = 0x0;

    REMCrowdSale public crowdsale;
    REMStrategy public pricingStrategy;

    uint256 public vestingStartDate;

    mapping(address => bool) public tokenInited;

    event BountySent(address receiver, uint256 amount);
    event BonusSent(address receiver, uint256 amount);
    event ReferralSent(address receiver, uint256 amount);

    constructor(
        REMCrowdSale _crowdsale,
        address _allocator
    ) public
    Referral(0, _allocator, _crowdsale, false) {
        require(address(0) != address(_crowdsale));
        crowdsale = REMCrowdSale(_crowdsale);
        pricingStrategy = REMStrategy(address(crowdsale.pricingStrategy()));
        uint256[12] memory tiersData = pricingStrategy.getArrayOfTiers();
        vestingStartDate = tiersData[11].add(30 days);
    }

    function setCrowdsale(address _crowdsale) public onlyOwner {
        super.setCrowdsale(_crowdsale);
        pricingStrategy = REMStrategy(crowdsale.pricingStrategy());
        uint256[12] memory tiersData = pricingStrategy.getArrayOfTiers();
        vestingStartDate = tiersData[11].add(30 days);
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
        _bancor = _bancor;
    }

    function sendBancorTokens(MintableTokenAllocator _allocator) public onlyOwner {
        require(tokenInited[bancor] == false && bancor != address(0));
        tokenInited[bancor] = true;
        _allocator.allocate(bancor, uint256(20000000000).mul(uint256(10) ** uint256(18)));
    }

    function allocate(MintableTokenAllocator _allocator, uint256 _bonusAmount) public onlyOwner() {
        require(tokenInited[address(_allocator.token)] == false);

        tokenInited[address(_allocator.token)] = true;

        uint256 tokenPrecision = uint256(10) ** uint256(18);

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
            uint256(365 days).mul(2), //2 years
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
        _allocator.allocate(treasury, uint256(20000000000).mul(tokenPrecision));
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
        REMToken token = REMToken(address(_allocator.token()));
        token.setClaimState(_address, true);
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
        REMToken token = REMToken(address(_allocator.token()));
        token.allocationLog(_address, _amount, _startingAt, _lockPeriod, _initialUnlock, _releasePeriod);
        _allocator.allocate(_address, _amount);
        token.setClaimState(_address, true);
    }
}
