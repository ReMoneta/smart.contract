pragma solidity 0.4.19;


import 'zeppelin-solidity/contracts/token/ERC20/TokenVesting.sol';


contract PeriodicTokenVesting is TokenVesting {

    address public unreleasedHolder;
    uint256 public periods;

    function PeriodicTokenVesting(
        address _beneficiary,
        uint256 _start,
        uint256 _cliff,
        uint256 _duration,
        uint256 _periods,
        bool _revocable,
        address _unreleasedHolder
    )
    public TokenVesting(_beneficiary, _start, _cliff, _duration, _revocable)
    {
        require(_unreleasedHolder != address(0));
        periods = _periods;
        unreleasedHolder = _unreleasedHolder;
    }
    /**
    * @dev Calculates the amount that has already vested.
    * @param token ERC20 token which is being vested
    */
    function vestedAmount(ERC20Basic token) public view returns (uint256) {
        uint256 currentBalance = token.balanceOf(this);
        uint256 totalBalance = currentBalance.add(released[token]);

        if (now < cliff) {
            return 0;
        } else if (now >= start.add(duration * periods) || revoked[token]) {
            return totalBalance;
        } else {

            uint256 periodTokens = totalBalance.div(periods);

            uint256 periodsOver = now.sub(start).div(duration);

            if (periodsOver >= periods) {
                return totalBalance;
            }

            return periodTokens.mul(periodsOver);
        }
    }

    /**
    * @notice Allows the owner to revoke the vesting. Tokens already vested
    * remain in the contract, the rest are returned to the owner.
    * @param token ERC20 token which is being vested
    */
    function revoke(ERC20Basic token) public onlyOwner {
        require(revocable);
        require(!revoked[token]);

        uint256 balance = token.balanceOf(this);

        uint256 unreleased = releasableAmount(token);
        uint256 refund = balance.sub(unreleased);

        revoked[token] = true;

        token.safeTransfer(unreleasedHolder, refund);

        Revoked();
    }
}
