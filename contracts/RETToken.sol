pragma solidity ^0.4.23;

import './token/erc20/TimeLockedToken.sol';
import './token/erc20/openzeppelin/OpenZeppelinERC20.sol';
import './token/erc20/MintableToken.sol';
import './token/erc20/BurnableToken.sol';
import './LockupContract.sol';
import './AllocationLockupContract.sol';


contract RETToken is TimeLockedToken, LockupContract, AllocationLockupContract, OpenZeppelinERC20, BurnableToken, MintableToken {

    mapping(address => uint256) public intermediateBalances;
    mapping(address => bool) public kycVerified;

    modifier isTimeLocked(address _holder, bool _timeLocked) {
        bool locked = (block.timestamp < time);
        require(excludedAddresses[_holder] == true || locked == _timeLocked);
        _;
    }

    // _unlockTokensTime - 30 days after ICO
    constructor(uint256 _unlockTokensTime) public TimeLockedToken(_unlockTokensTime)
    AllocationLockupContract()
    LockupContract(uint256(365 days).div(2), 10, 1 days)
    OpenZeppelinERC20(0, 'Remoneta ERC 20 Token', 18, 'RET', false)
    MintableToken(uint256(400000000000).mul(10 ** 18), 0, true) {

    }

    function setUnlockTime(uint256 _unlockTokensTime) public onlyOwner {
        time = _unlockTokensTime;
    }

    function updateMaxSupply(uint256 _newMaxSupply) public onlyOwner {
        require(_newMaxSupply > 0);
        maxSupply = _newMaxSupply;
    }

    function setKYCState(address _holder, bool _state) public onlyMintingAgents {
        kycVerified[_holder] = _state;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(balanceOf(msg.sender) >= _value);
        require(true == isTransferAllowed(msg.sender, _value));
        intermediateBalances[msg.sender] = intermediateBalances[msg.sender].sub(_value);
        intermediateBalances[_to] = intermediateBalances[_to].add(_value);
        require(true == super.transfer(_to, _value));
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(balanceOf(_from) >= _value);
        require(true == isTransferAllowed(_from, _value));
        intermediateBalances[_from] = intermediateBalances[_from].sub(_value);
        intermediateBalances[_to] = intermediateBalances[_to].add(_value);
        require(true == super.transferFrom(_from, _to, _value));
        return true;
    }

    function isTransferAllowed(address _address, uint256 _value) public view returns (bool) {
        return isTransferAllowedAllocation(_address, _value, block.timestamp, balanceOf(_address))
        && isTransferAllowedInternal(_address, _value, block.timestamp, balanceOf(_address));
    }

    function updateExcludedAddress(address _address, bool _status) public onlyOwner {
        excludedAddresses[_address] = _status;
    }

    function burn(address _holder) public onlyBurnAgents() returns (uint256 balance) {
        intermediateBalances[_holder] = 0;
        return super.burn(_holder);
    }

    function mint(address _holder, uint256 _tokens) public onlyMintingAgents() {
        super.mint(_holder, _tokens);
        intermediateBalances[_holder] = intermediateBalances[_holder].add(_tokens);
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        if (excludedAddresses[_owner] == true || (kycVerified[_owner] == true)) {
            return super.balanceOf(_owner);
        }
        return 0;
    }

}
