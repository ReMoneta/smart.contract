pragma solidity ^0.4.23;

import '../Ownable.sol';
import './../../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol';

/*
    Tests:
    - check that setEtherInUSD can be called only by trustedAddress
    - check that setEtherInUSD changes (etherPriceInUSD and priceUpdateAt)
    - check that setEtherInUSD accept sting  with 5 sumbols after .
    - check that METHODS could be called only by owner
        - setTrustedAddress
*/

contract USDExchange is Ownable {

    using SafeMath for uint256;

    uint256 public etherPriceInUSD;
    uint256 public priceUpdateAt;
    mapping(address => bool) public trustedAddresses;

    event NewPriceTicker(string _price);

    modifier onlyTursted() {
        require(trustedAddresses[msg.sender] == true);
        _;
    }

    constructor(uint256 _etherPriceInUSD) public {
        etherPriceInUSD = _etherPriceInUSD;
        priceUpdateAt = block.timestamp;
        trustedAddresses[msg.sender] = true;
    }

    function setTrustedAddress(address _address, bool _status) public onlyOwner {
        trustedAddresses[_address] = _status;
    }

    // set ether price in USD with 5 digits after the decimal point
    //ex. 308.75000
    //for updating the price through  multivest
    function setEtherInUSD(string _price) public onlyTursted {
        bytes memory bytePrice = bytes(_price);
        uint256 dot = bytePrice.length.sub(uint256(6));

        // check if dot is in 6 position  from  the last
        require(0x2e == uint(bytePrice[dot]));

        uint256 newPrice = uint256(10 ** 23).div(parseInt(_price, 5));

        require(newPrice > 0);

        etherPriceInUSD = parseInt(_price, 5);

        priceUpdateAt = block.timestamp;

        emit NewPriceTicker(_price);
    }

    function parseInt(string _a, uint _b) internal pure returns (uint) {
        bytes memory bresult = bytes(_a);
        uint res = 0;
        bool decimals = false;
        for (uint i = 0; i < bresult.length; i++) {
            if ((bresult[i] >= 48) && (bresult[i] <= 57)) {
                if (decimals) {
                    if (_b == 0) break;
                    else _b--;
                }
                res *= 10;
                res += uint(bresult[i]) - 48;
            } else if (bresult[i] == 46) decimals = true;
        }
        if (_b > 0) res *= 10 ** _b;
        return res;
    }
}
