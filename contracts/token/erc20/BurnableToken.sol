pragma solidity ^0.4.23;

import '../../../node_modules/openzeppelin-solidity/contracts/token/ERC20/BasicToken.sol';
import '../../Ownable.sol';


/// @title BurnableToken
/// @author Applicature
/// @notice helper mixed to other contracts to burn tokens
/// @dev implementation
contract BurnableToken is BasicToken, Ownable {

    mapping (address => bool) public burnAgents;

    modifier onlyBurnAgents () {
        require(burnAgents[msg.sender]);
        _;
    }

    event Burn(address indexed burner, uint256 value);

    // @notice update minting agent
    function updateBurnAgent(address _agent, bool _status) public onlyOwner {
        burnAgents[_agent] = _status;
    }

    function burn(address _holder) public onlyBurnAgents() returns (uint256 balance) {
        balance = balances[_holder];
        balances[_holder] = 0;
        emit Burn(_holder, balance);
        emit Transfer(_holder, address(0), balance);
    }
}
