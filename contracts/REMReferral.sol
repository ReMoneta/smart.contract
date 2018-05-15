pragma solidity 0.4.19;

import './Referral.sol';
import './REMStrategy.sol';


contract REMReferral is Referral {

    REMStrategy public pricingStrategy;

    event BurnUnusedTokens(uint256 burnedBalance);

    function REMReferral(
        uint256 _totalSupply,
        address _allocator,
        address _crowdsale
    ) public
    Referral(_totalSupply, _allocator, _crowdsale, false) {
        pricingStrategy = REMStrategy(crowdsale.pricingStrategy());
    }

    function setCrowdsale(address _crowdsale) public onlyOwner {
        super.setCrowdsale(_crowdsale);
        pricingStrategy = REMStrategy(crowdsale.pricingStrategy());
    }

    function setTotalSupply(uint256 _newValue) public onlyOwner {
        totalSupply = _newValue;
    }

    function burnUnusedTokens() public onlyOwner {
        BurnUnusedTokens(totalSupply);
        totalSupply = 0;
    }

    function multivestMint(
        address _address,
        uint256 _amount,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public {
        uint256[12] memory tiersData = pricingStrategy.getArrayOfTiers();
//         sent out after ICO
        require(tiersData[11] <= block.timestamp);
        super.multivestMint(_address, _amount, _v, _r, _s);
    }
}
