pragma solidity ^0.4.0;


import '../TimeLocked.sol';


contract TimeLockedTest is TimeLocked {


    function TimeLockedTest(uint256 _time) public TimeLocked(_time) {

    }

    function shouldBeLocked() public isTimeLocked(msg.sender, true) returns (bool) {
        return true;
    }

    function shouldBeUnLocked() public isTimeLocked(msg.sender, false) returns (bool) {
        return true;
    }
    function updateExcludedAddress(address _address, bool _status) public {
    _address= _address;
    _status= _status;
    }

}

