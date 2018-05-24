pragma solidity 0.4.19;

import '../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol';
import './allocator/MintableTokenAllocator.sol';
import './crowdsale/CrowdsaleImpl.sol';
import './Ownable.sol';

// testcases
/*
- create & check  params
- setCrowdsale and setAllocator are changing state variables & only Owner can call it
- multivestMint
    - only  crowdsale signers  can run it
    - if  sentOnce is  true referral can claim tokens only once
    - if  sentOnce is  false referral can claim tokens many times
    - if  sentOnce is  false referral can claim tokens many times
    - tokens amount should be > 0
    -  tokens amount should be <= totalSupply
    -  should fail  if  allocator is not set up (set referral in allocator)
    -  updates claimedBalances
*/
contract Referral is Ownable {

    using SafeMath for uint256;

    MintableTokenAllocator public allocator;
    CrowdsaleImpl public crowdsale;

    uint256 public constant DECIMALS = 18;

    uint256 public totalSupply;
    bool public unLimited;
    bool public sentOnce;

    mapping(address => bool) public claimed;
    mapping(address => uint256) public claimedBalances;

    function Referral(
        uint256 _totalSupply,
        address _allocator,
        address _crowdsale,
        bool _sentOnce
    ) public {
        require(_allocator != address(0) && _crowdsale != address(0));
        totalSupply = _totalSupply;
        if (totalSupply == 0) {
            unLimited = true;
        }
        allocator = MintableTokenAllocator(_allocator);
        crowdsale = CrowdsaleImpl(_crowdsale);
        sentOnce = _sentOnce;
    }

    function setAllocator(address _allocator) public onlyOwner {
        if (_allocator != address(0)) {
            allocator = MintableTokenAllocator(_allocator);
        }
    }

    function setCrowdsale(address _crowdsale) public onlyOwner {
        require(_crowdsale != address(0));
        crowdsale = CrowdsaleImpl(_crowdsale);
    }

    function multivestMint(
        address _address,
        uint256 _amount,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public {
        address recoveredAddress = crowdsale.verify(msg.sender, _v, _r, _s);
        require(true == crowdsale.signers(recoveredAddress));
        if (true == sentOnce) {
            require(claimed[_address] == false);
            claimed[_address] = true;

        }
        _amount = _amount.mul(10 ** DECIMALS);
        require(
            _address == msg.sender &&
            _amount > 0 &&
            (true == unLimited || _amount <= totalSupply)
        );
        claimedBalances[_address] = claimedBalances[_address].add(_amount);
        if (false == unLimited) {
            totalSupply = totalSupply.sub(_amount);
        }
        allocator.allocate(_address, _amount);
    }
}
