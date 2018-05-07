pragma solidity ^0.4.18;

import '../../../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol';
import './IErc20.sol';
import '../../BlockLocked.sol';

/// @title BlockLockedToken
/// @author Applicature
/// @notice helper mixed to other contracts to lock contract on a block
/// @dev Base class
contract BlockLockedToken is BlockLocked, IErc20 {
    using SafeMath for uint256;

    function transfer(address _to, uint256 _tokens) public isBlockLocked(false) returns (bool) {
        super.transfer(_to, _tokens);
    }

    function transferFrom(address _holder, address _to, uint256 _tokens) public isBlockLocked(false) returns (bool) {
        super.transferFrom(_holder, _to, _tokens);
    }
}
