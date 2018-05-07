pragma solidity ^0.4.18;

import '../../../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol';
import '../../../node_modules/zeppelin-solidity/contracts/token/ERC20/StandardToken.sol';
import '../PausableToken.sol';


/// @title Erc20PausableToken
/// @author Applicature
/// @notice helper mixed to other contracts to pause/ un pause contract
/// @dev Base class
contract Erc20PausableToken is StandardToken, PausableToken {

    function Erc20PausableToken(bool _paused) public PausableToken(_paused) {}

    function transfer(address _to, uint256 _tokens) public isPaused(false) returns (bool) {
        return super.transfer(_to, _tokens);
    }

    function transferFrom(address _holder, address _to, uint256 _tokens) public isPaused(false) returns (bool) {
        return super.transferFrom(_holder, _to, _tokens);
    }
}
