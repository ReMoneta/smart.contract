pragma solidity 0.4.19;

import '../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol';
import "./REMToken.sol";
import "./REMCrowdSale.sol";
import "./Ownable.sol";


contract Referral is Ownable {

    using SafeMath for uint256;

    MintableTokenAllocator allocator;
    REMCrowdSale public crowdsale;

    uint256 public constant DECIMALS = 18;

    uint256 public totalSupply = 35000000 * 10 ** DECIMALS;

    mapping (address => bool) public claimed;

    function Referral(
        address _allocator,
        address _crowdsale
    ) public {
        require(_allocator != address(0) && crowdsale != address(0));
        allocator = MintableTokenAllocator(_allocator);
        crowdsale = REMCrowdSale(_crowdsale);
    }

    function setAllocator(address _allocator) public onlyOwner {
        if (_allocator != address(0)) {
            allocator = MintableTokenAllocator(_allocator);
        }
    }

    function setREMCrowdSale(address _crowdsale) public onlyOwner {
        require(_crowdsale != address(0));
        crowdsale = REMCrowdSale(_crowdsale);
    }

    function multivestMint(
        address _address,
        uint256 _amount,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public {
        address recoveredAddress = crowdsale.verify(_v, _r, _s);
        require(crowdsale.signers(recoveredAddress));

        _amount = _amount.mul(10 ** DECIMALS);
        require(
            claimed[_address] == false &&
            _address == msg.sender &&
            _amount > 0 &&
            _amount <= totalSupply
        );
        allocator.allocate(_address, _amount);
        totalSupply = totalSupply.sub(_amount);
        claimed[_address] = true;
    }
}
