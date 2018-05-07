pragma solidity ^0.4.18;

import '../../../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol';
import './IErc20.sol';

/// @title KycBurnable
/// @author Applicature
/// @notice helper mixed to other contracts to burn tokens
/// @dev Base class
contract KycBurnable is IErc20 {
    using SafeMath for uint256;

    mapping(address => bool) public burnAgents;

    modifier onlyBurnAgents () {
        require(burnAgents[msg.sender]);
        _;
    }

    function KycBurnable() public {

    }

    function burn(address _holder) public onlyBurnAgents() {
        uint256 balance = balanceOf(_holder);

        uint256 totalSupplyBalance = totalSupply().sub(balance);

        setTotalSupply(totalSupplyBalance);

        setBalance(_holder, 0);
    }
}
