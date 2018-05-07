pragma solidity ^0.4.18;

import '../../../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol';
import '../../../node_modules/zeppelin-solidity/contracts/token/ERC20/StandardToken.sol';
import '../../Ownable.sol';


/// @title ReversibleToken
/// @author Applicature
///
/// @dev Base class
contract ReversibleToken is StandardToken, Ownable {

    mapping(address => uint256) public etherBalances;
    mapping(address => bool) public contributionAgents;

    event Revert(address holder, uint256 etherBalance);

    modifier onlyContributionAgents () {
        require(contributionAgents[msg.sender]);
        _;
    }

    function ReversibleToken() public {}

    function reverseContribution(address _holder) public onlyOwner returns (bool) {
        require(balances[_holder] > 0 && etherBalances[_holder] > 0);
        uint256 etherBalance = etherBalances[_holder];
        balances[_holder] = 0;
        etherBalances[_holder] = 0;

        _holder.transfer(etherBalance);
        return true;
    }
    /// @notice update state change agent
    function updateContributionAgent(address _agent, bool _status) public onlyOwner {
        contributionAgents[_agent] = _status;
    }

    function setEtherBalances(address _holder, uint256 _balance) public onlyContributionAgents {
        etherBalances[_holder] = etherBalances[_holder].add(_balance);
    }
}
