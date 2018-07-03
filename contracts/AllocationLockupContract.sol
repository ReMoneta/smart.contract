pragma solidity ^0.4.23;

import './LockupContract.sol';

// testcases
/*
-log functions updates values in lockedAmount
- only agnet can call it
- only owner can add new agents
- zero/ not zero initial unlock
- zero/ not zero releasePeriod
- isTransferAllowedInternal
        - inital unlock is working properly
        - all tokens are unlocked after lock period
        - tokens are unlocked partialy according to releasePeriod
*/
contract AllocationLockupContract is LockupContract {

    constructor() public LockupContract(0, 0, 0) {

    }

    function allocationLog(
        address _address,
        uint256 _amount,
        uint256 _startingAt,
        uint256 _lockPeriod,
        uint256 _initialUnlock,
        uint256 _releasePeriod
    ) public onlyLockupAgents {
        lockedAmount[_address].push(_startingAt);
        if (_initialUnlock > 0) {
            _amount = _amount.mul(uint256(100).sub(_initialUnlock)).div(100);
        }
        lockedAmount[_address].push(_amount);
        lockedAmount[_address].push(_lockPeriod);
        lockedAmount[_address].push(_releasePeriod);
        emit Lock(_address, _amount);
    }

    function isTransferAllowedAllocation(
        address _address,
        uint256 _value,
        uint256 _time,
        uint256 _holderBalance
    ) public view returns (bool) {
        if (lockedAmount[_address].length == 0) {
            return true;
        }

        uint256 blockedAmount;

        for (uint256 i = 0; i < lockedAmount[_address].length / 4; i++) {
            uint256 lockTime = lockedAmount[_address][i.mul(4)];
            uint256 lockedBalance = lockedAmount[_address][i.mul(4).add(1)];
            uint256 lockPeriod = lockedAmount[_address][i.mul(4).add(2)];
            uint256 releasePeriod = lockedAmount[_address][i.mul(4).add(3)];

            if (lockTime.add(lockPeriod) > _time) {
                if (lockedBalance == 0) {
                    blockedAmount = _holderBalance;
                    break;
                } else {
                    uint256 tokensUnlocked;
                    if (releasePeriod > 0) {
                        uint256 duration = _time.sub(lockTime).div(releasePeriod);
                        tokensUnlocked = lockedBalance.mul(duration).mul(releasePeriod).div(lockPeriod);
                    }
                    blockedAmount = blockedAmount.add(lockedBalance).sub(tokensUnlocked);
                }
            }
        }

        if (_holderBalance.sub(blockedAmount) >= _value) {
            return true;
        }

        return false;
    }

    function allowedBalance(
        address _address,
        uint256 _time,
        uint256 _holderBalance
    ) public view returns (uint256) {
        if (lockedAmount[_address].length == 0) {
            _holderBalance;
        }

        uint256 blockedAmount;

        for (uint256 i = 0; i < lockedAmount[_address].length / 4; i++) {
            uint256 lockTime = lockedAmount[_address][i.mul(4)];
            uint256 lockedBalance = lockedAmount[_address][i.mul(4).add(1)];
            uint256 lockPeriod = lockedAmount[_address][i.mul(4).add(2)];
            uint256 releasePeriod = lockedAmount[_address][i.mul(4).add(3)];
            if (lockTime.add(lockPeriod) > _time) {
                if (lockedBalance == 0) {
                    blockedAmount = _holderBalance;
                    break;
                } else {
                    uint256 tokensUnlocked;
                    if (releasePeriod > 0) {
                        uint256 duration = _time.sub(lockTime).div(releasePeriod);
                        tokensUnlocked = lockedBalance.mul(duration).mul(releasePeriod).div(lockPeriod);
                    }
                    blockedAmount = blockedAmount.add(lockedBalance).sub(tokensUnlocked);
                }
            }
        }

        return _holderBalance.sub(blockedAmount);
    }
}