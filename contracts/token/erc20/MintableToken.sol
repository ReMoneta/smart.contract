pragma solidity ^0.4.18;


import './../../../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol';
import '../../../node_modules/zeppelin-solidity/contracts/token/ERC20/StandardToken.sol';
import '../../Ownable.sol';


/// @title MintableToken
/// @author Applicature
/// @notice allow to mint tokens
/// @dev Base class
contract MintableToken is StandardToken, Ownable {


    using SafeMath for uint256;

    uint256 public maxSupply;
    bool public allowedMinting;
    mapping(address => bool) public mintingAgents;
    mapping(address => bool) public stateChangeAgents;

    event Mint(address indexed holder, uint256 tokens);

    modifier onlyMintingAgents () {
        require(mintingAgents[msg.sender]);
        _;
    }

    modifier onlyStateChangeAgents () {
        require(stateChangeAgents[msg.sender]);
        _;
    }

    function MintableToken(uint256 _maxSupply, uint256 _mintedSupply, bool _allowedMinting) public {
        maxSupply = _maxSupply;
        totalSupply_ = totalSupply_.add(_mintedSupply);
        allowedMinting = _allowedMinting;
        mintingAgents[msg.sender] = true;
    }

    /// @notice allow to mint tokens
    function mint(address _holder, uint256 _tokens) public onlyMintingAgents() {
        require(allowedMinting == true && totalSupply_.add(_tokens) <= maxSupply);

        totalSupply_ = totalSupply_.add(_tokens);

        balances[_holder] = balanceOf(_holder).add(_tokens);

        if (totalSupply_ == maxSupply) {
            allowedMinting = false;
        }
        Mint(_holder, _tokens);
    }

    /// @notice update allowedMinting flat
    function disableMinting() public onlyStateChangeAgents() {
        allowedMinting = false;
    }

    /// @notice update minting agent
    function updateMintingAgent(address _agent, bool _status) public onlyOwner {
        mintingAgents[_agent] = _status;
    }

    /// @notice update state change agent
    function updateStateChangeAgent(address _agent, bool _status) public onlyOwner {
        stateChangeAgents[_agent] = _status;
    }

    /// @return available tokens
    function availableTokens() public view returns (uint256 tokens) {
        return maxSupply.sub(totalSupply_);
    }
}

