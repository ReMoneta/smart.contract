pragma solidity ^0.4.19;

import '../REMToken.sol';

contract REMTokenTest is REMToken {

    function REMTokenTest(uint256 _unlockTokensTime) public
    REMToken(_unlockTokensTime) {

    }

    function setUnlockTokensTimeTest(uint256 _unlockTokensTime) public onlyOwner {
        require(_unlockTokensTime > 0);
        time = _unlockTokensTime;
    }
}
