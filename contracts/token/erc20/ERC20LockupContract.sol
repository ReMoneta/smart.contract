pragma solidity ^0.4.23;

import '../../../node_modules/zeppelin-solidity/contracts/token/ERC20/StandardToken.sol';
import '../../Ownable.sol';
import '../../LockupContract.sol';


contract ERC20LockupContract is LockupContract, StandardToken {

    constructor(uint256 _lockPeriod, uint256 _initialUnlock, uint256 _releasePeriod) public
        LockupContract(_lockPeriod, _initialUnlock, _releasePeriod) {
    }

    function transfer(address _to, uint256 _tokens) public returns (bool) {
        require(true == isTransferAllowed(msg.sender, _tokens));
        return super.transfer(_to, _tokens);
    }

    function transferFrom(address _holder, address _to, uint256 _tokens) public returns (bool) {
        require(true == isTransferAllowed(_holder, _tokens));
        return super.transferFrom(_holder, _to, _tokens);
    }

    function isTransferAllowed(address _address, uint256 _value) public view returns (bool) {
        return isTransferAllowedInternal(_address, _value, block.timestamp, balanceOf(_address));
    }
}