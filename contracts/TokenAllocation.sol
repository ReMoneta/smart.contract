pragma solidity 0.4.19;

import './PeriodicTokenVesting.sol';
import {MintableTokenAllocator as Allocator} from './allocator/MintableTokenAllocator.sol';
import 'zeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import {REMCrowdSale as CrowdSale} from './REMCrowdSale.sol';

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


contract TokenAllocation is Ownable {
    using SafeERC20 for ERC20Basic;
    using SafeMath for uint256;

    address public team = 0x0;
    address public advisory = 0x0;
    address public treasury = 0x0;
    address public bonus = 0x0;
    address public bounty = 0x0;
    address public bancor = 0x0;

    CrowdSale public crowdsale;

    uint256 public vestingStartDate;

    address public vestingTeam;
    address public vestingAdvisory;

    mapping(address => bool) public tokenInited;
    address[] public vestings;

    event VestingCreated(
        address _vesting,
        address _beneficiary,
        uint256 _start,
        uint256 _cliff,
        uint256 _duration,
        uint256 _periods,
        bool _revocable
    );

    event VestingRevoked(address _vesting);

    function TokenAllocation(
        CrowdSale _crowdsale
    ) public {
        require(address(0) != address(_crowdsale));
        crowdsale = CrowdSale(_crowdsale);
    }

    function setVestingStartDate(uint256 _vestingStartDate) public onlyOwner {
        vestingStartDate = _vestingStartDate;
    }

    function initVesting() public onlyOwner() {
        require(vestingTeam == address(0) &&
        vestingAdvisory == address(0) &&
        vestingStartDate != 0
        );
        vestingTeam = createVesting(
            0x760864dcdC58FDA80dB6883ce442B6ce44921Cf9,
            vestingStartDate.add(uint256(1 years).div(2)), 0, 30 days, 24, true, owner
        );

        vestingAdvisory = createVesting(
            0x7f438d78a51886B24752941ba98Cc00aBA217495, vestingStartDate, 0, 30 days, 24, true, owner
        );

    }

    function setAddresses(
        address _team,
        address _advisory,
        address _treasury,
        address _bonus,
        address _bounty,
        address _bancor
    ) public onlyOwner {
        require(
            _team != address(0) &&
            _advisory != address(0) &&
            _treasury != address(0) &&
            _bonus != address(0) &&
            _bounty != address(0) &&
            _bancor != address(0)
        );
        team = _team;
        advisory = _advisory;
        treasury = _treasury;
        bonus = _bonus;
        bounty = _bounty;
        _bancor = _bancor;
    }

    function allocate(Allocator _allocator) public onlyOwner() {
        require(tokenInited[address(_allocator.token)] == false);

        tokenInited[address(_allocator.token)] = true;

        require(vestingTeam != address(0));
        require(vestingAdvisory != address(0));

        uint256 tokenPrecision = uint256(10) ** uint256(18);

        // sold  tokens  +  bonuses
        uint256 soldTokens = crowdsale.tokensSold().add(uint256(200000000000).mul(tokenPrecision));

        _allocator.allocate(vestingTeam, soldTokens.mul(2).div(100));

        uint256 advisoryTokens = soldTokens.mul(4).div(100);
        //50%  within two years
        _allocator.allocate(vestingAdvisory, advisoryTokens.div(2));
        //50%  directly
        _allocator.allocate(advisory, advisoryTokens.div(2));
        //@todo  adds Early envestors
        _allocator.allocate(treasury, uint256(20000000000).mul(tokenPrecision));
        _allocator.allocate(bonus, uint256(20000000000).mul(tokenPrecision));
        _allocator.allocate(bancor, uint256(20000000000).mul(tokenPrecision));
        _allocator.allocate(bounty, crowdsale.hardCap().mul(275).div(10000));

    }


    function vestingMint(PeriodicTokenVesting _vesting, Allocator _allocator, uint256 _amount) public onlyOwner {
        require(_amount > 0);
        _allocator.allocate(address(_vesting), _amount);
    }

    function createVesting(
        address _beneficiary,
        uint256 _start,
        uint256 _cliff,
        uint256 _duration,
        uint256 _periods,
        bool _revocable,
        address _unreleasedHolder
    ) public onlyOwner() returns (PeriodicTokenVesting) {
        PeriodicTokenVesting vesting = new PeriodicTokenVesting(
            _beneficiary, _start, _cliff, _duration, _periods, _revocable, _unreleasedHolder
        );

        vestings.push(vesting);

        VestingCreated(vesting, _beneficiary, _start, _cliff, _duration, _periods, _revocable);

        return vesting;
    }

    function revokeVesting(PeriodicTokenVesting _vesting, ERC20Basic token) public onlyOwner() {
        _vesting.revoke(token);

        VestingRevoked(_vesting);
    }
}
