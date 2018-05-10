pragma solidity 0.4.19;


import './token/erc20/TimeLockedToken.sol';
import './token/erc20/openzeppelin/OpenZeppelinERC20.sol';
import './token/erc20/MintableToken.sol';
import './token/erc20/BurnableToken.sol';
import './LockupContract.sol';


/*
    Tests:
    - deploy contract & check if the params  are equal
    - check setUnlockTime function:
        - updates time
        - only owner can call it
   - check  transfer

*/


contract REMToken is TimeLockedToken, LockupContract, OpenZeppelinERC20, BurnableToken, MintableToken {

    // _unlockTokensTime - 30 days after ICO
    function REMToken(uint256 _unlockTokensTime) public
    TimeLockedToken(_unlockTokensTime)
    LockupContract(uint256(1 years).div(2), 10, 1 days)
    OpenZeppelinERC20(0, 'Remoneta ERC 20 Token', 18, 'REM', false)
    MintableToken(uint256(400000000000).mul(10 ** 18), 0, true) {

    }

    function setUnlockTime(uint256 _unlockTokensTime) public onlyOwner {
        time = _unlockTokensTime;
    }

    function updateMaxSupply(uint256 _newMaxSupply) public onlyOwner {
        require(_newMaxSupply > 0);
        maxSupply = _newMaxSupply;
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
