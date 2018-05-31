pragma solidity ^0.4.23;

import '../../../../node_modules/minimetoken/contracts/MiniMeToken.sol';
import '../../../../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol';
import '../IErc20.sol';

/// @title MiniMeERC20
/// @author Applicature
/// @notice Minime implementation of standart ERC20
/// @dev Base class
contract MiniMeERC20 is IErc20, MiniMeToken {
    using SafeMath for uint256;

    string public standard;

    constructor(
        address _tokenFactory,
        address _parentToken,
        uint _parentSnapShotBlock,
        uint256 _totalSupply,
        string _tokenName,
        uint8 _decimals,
        string _tokenSymbol,
        bool _transferAllSupplyToOwner
    )
    public
    MiniMeToken(
        _tokenFactory,
        _parentToken,
        _parentSnapShotBlock,
        _tokenName,
        _decimals,
        _tokenSymbol,
        true
    )
    {
        standard = 'ERC20 0.1';

        if (_transferAllSupplyToOwner) {
            setBalance(msg.sender, _totalSupply);
        } else {
            setBalance(this, _totalSupply);
        }

        name = _tokenName;
        // Set the name for display purposes
        symbol = _tokenSymbol;
        // Set the symbol for display purposes
        decimals = _decimals;
    }

    // disable receiving ethers
    function() public payable {
        require(false);
    }

    function claimTokens(address _token) public {
        _token = _token;

        require(false);
    }

    function setTotalSupply(uint256 _totalSupply) internal {
        updateValueAtNow(totalSupplyHistory, _totalSupply);
    }

    function setBalance(address _holder, uint256 _tokens) internal {
        require(parentSnapShotBlock < block.number);

        updateValueAtNow(balances[_holder], _tokens);
    }
}
