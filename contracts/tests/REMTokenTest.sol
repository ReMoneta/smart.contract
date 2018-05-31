pragma solidity ^0.4.23;

import '../REMToken.sol';

contract REMTokenTest is REMToken {

    constructor(uint256 _unlockTokensTime) public
    REMToken(_unlockTokensTime) {

    }

    function setUnlockTokensTimeTest(uint256 _unlockTokensTime) public onlyOwner {
        require(_unlockTokensTime > 0);
        time = _unlockTokensTime;
    }
}
