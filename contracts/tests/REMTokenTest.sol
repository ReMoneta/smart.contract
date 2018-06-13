pragma solidity ^0.4.23;

import '../RETToken.sol';

contract RETTokenTest is RETToken {

    constructor(uint256 _unlockTokensTime) public
    RETToken(_unlockTokensTime) {

    }

    function setUnlockTokensTimeTest(uint256 _unlockTokensTime) public onlyOwner {
        require(_unlockTokensTime > 0);
        time = _unlockTokensTime;
    }
}
