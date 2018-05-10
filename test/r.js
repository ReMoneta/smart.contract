var
    Referral = artifacts.require("./Referral.sol"),
    MintableTokenAllocator = artifacts.require("./allocator/MintableTokenAllocator.sol"),
    CrowdsaleImpl = artifacts.require("./allocator/CrowdsaleImpl.sol"),
    PricingStrategy = artifacts.require("./pricing/PricingStrategy.sol"),
    MintableToken = artifacts.require("./token/erc20/MintableToken.sol"),
    DistributedDirectContributionForwarder = artifacts.require("./contribution/DistributedDirectContributionForwarder.sol"),

    Utils = require("./utils"),
    BigNumber = require('BigNumber.js'),

precision = new BigNumber("1000000000000000000"),
    usdPrecision = new BigNumber("100000"),
    crowdsaleSince = parseInt(new Date().getTime() / 1000 - 3600),
    crowdsaleTill = parseInt(new Date().getTime() / 1000) + 3600,
    signAddress = web3.eth.accounts[0],
    wrongSigner = web3.eth.accounts[5],
    etherHolder = web3.eth.accounts[9];

var abi = require('ethereumjs-abi'),
    BN = require('bn.js');

async function makeTransaction(instance, sign, crowdsale, address, amount) {
    'use strict';
    var h = abi.soliditySHA3(['address', 'address'], [new BN(crowdsale.substr(2), 16), new BN(address.substr(2), 16)]),
        sig = web3.eth.sign(sign, h.toString('hex')).slice(2),
        r = `0x${sig.slice(0, 64)}`,
        s = `0x${sig.slice(64, 128)}`,
        v = web3.toDecimal(sig.slice(128, 130)) + 27;

    var data = abi.simpleEncode('multivestMint(address,uint256,uint8,bytes32,bytes32)', address, amount, v, r, s);

    return instance.sendTransaction({from: address, data: data.toString('hex')});
}

contract('Referral', function (accounts) {
    let allocator,
        referral,
        crowdsale,
        strategy,
        token,
        contributionForwarder;

    beforeEach(async function () {
        token = await MintableToken.new( new BigNumber('100000').mul(precision).valueOf(), 0, true)
        allocator = await MintableTokenAllocator.new(token.address)
        contributionForwarder = await DistributedDirectContributionForwarder.new(100, [etherHolder], [100]);
        // strategy = await PricingStrategy.new();
        crowdsale = await  CrowdsaleImpl.new(
            allocator.address,
            contributionForwarder.address,
            '0x0',
            0,
            1,
            true,
            true,
            true
        )
        referral = await Referral.new(
            new BigNumber('1000').mul(precision).valueOf(),
            allocator.address,
            crowdsale.address,
           false
        )
        await token.updateMintingAgent(referral.address, true);
        await token.updateMintingAgent(allocator.address, true);
        await allocator.addCrowdsales(referral.address);
        await crowdsale.addSigner(signAddress);
    });
    it("create & check  params", async function () {
        await Utils.checkState({token, crowdsale, referral}, {
            token: {
                totalSupply: new BigNumber('0').mul(precision).valueOf(),
                owner: accounts[0]
            },
            crowdsale: {
                allocator: allocator.address,
                contributionForwarder: contributionForwarder.address,
                pricingStrategy: 0x0,
                startDate: 0,
                endDate: 1,
                allowWhitelisted: true,
                allowSigned: true,
                allowAnonymous: true,
                tokensSold: new BigNumber('0').mul(precision).valueOf(),
                owner: accounts[0],
                newOwner: 0x0,
            },
            referral: {
                totalSupply: new BigNumber('1000').mul(precision).valueOf(),
        sentOnce:false,
                claimed: [
                    {[accounts[0]]: false},
                    {[accounts[3]]: false},
                ],
                claimedBalances: [
                    {[accounts[0]]: 0},
                    {[accounts[3]]: 0},
                ],
            }
        });
    })
    it("setCrowdsale and setAllocator are changing state variables & only Owner can call it", async function () {
        await referral.setCrowdsale(crowdsale.address)
            .then(Utils.receiptShouldSucceed)
        await referral.setAllocator(allocator.address)
            .then(Utils.receiptShouldSucceed)

        await referral.setCrowdsale(crowdsale.address,{from:accounts[2]})
            .then(Utils.receiptShouldFailed)
            .catch(Utils.catchReceiptShouldFailed);
        await referral.setAllocator(allocator.address,{from:accounts[2]})
            .then(Utils.receiptShouldFailed)
            .catch(Utils.catchReceiptShouldFailed);
    })
    it("multivestMint", async function () {

        // await makeTransaction(referral, wrongSigner, accounts[1], new BigNumber('100').valueOf())
        //     .then(Utils.receiptShouldFailed)
        //     .catch(Utils.catchReceiptShouldFailed);
console.log(signAddress);
console.log(accounts[1]);
        await makeTransaction(referral, signAddress,  crowdsale.address, accounts[1], new BigNumber('1000').valueOf())
            .then(Utils.receiptShouldSucceed);
       Utils.balanceShouldEqualTo(token.address, accounts[1],new BigNumber('1000').mul(precision).valueOf())

    })
    it("only  crowdsale signers  can run it", async function () {
        await makeTransaction(referral, signAddress,  crowdsale.address, accounts[1], new BigNumber('1000').valueOf())
            .then(Utils.receiptShouldSucceed);
        await makeTransaction(referral, accounts[4],  crowdsale.address, accounts[1], new BigNumber('1000').valueOf())
            .then(Utils.receiptShouldFailed)
            .catch(Utils.catchReceiptShouldFailed)
    })
    it("if  sentOnce is  true referral can claim tokens only once", async function () {
        referral = await Referral.new(
            new BigNumber('1000').mul(precision).valueOf(),
            allocator.address,
            crowdsale.address,
            true
        )
        await token.updateMintingAgent(referral.address, true);
        await token.updateMintingAgent(allocator.address, true);
        await allocator.addCrowdsales(referral.address);
        await crowdsale.addSigner(signAddress);
        await makeTransaction(referral, signAddress,  crowdsale.address, accounts[1], new BigNumber('1000').valueOf())
            .then(Utils.receiptShouldSucceed);
        await makeTransaction(referral, signAddress,  crowdsale.address, accounts[1], new BigNumber('1000').valueOf())
            .then(Utils.receiptShouldFailed)
            .catch(Utils.catchReceiptShouldFailed)

    })
    it("if  sentOnce is  false referral can claim tokens many times", async function () {
        await makeTransaction(referral, signAddress,  crowdsale.address, accounts[1], new BigNumber('100').valueOf())
            .then(Utils.receiptShouldSucceed);
        await makeTransaction(referral, signAddress,  crowdsale.address, accounts[1], new BigNumber('100').valueOf())
            .then(Utils.receiptShouldSucceed);
    })

    it("tokens amount should be > 0", async function () {
    })
    it("tokens amount should be <= totalSupply", async function () {
        await makeTransaction(referral, signAddress,  crowdsale.address, accounts[1], new BigNumber('1001').valueOf())
            .then(Utils.receiptShouldFailed)
            .catch(Utils.catchReceiptShouldFailed)
    })
    it("should fail  if  allocator is not set up (set referral in allocator)", async function () {
    })
    it("updates claimedBalances", async function () {
        await makeTransaction(referral, signAddress,  crowdsale.address, accounts[1], new BigNumber('1000').valueOf())
            .then(Utils.receiptShouldSucceed);
        await assert.equal(new BigNumber(await referral.claimedBalances.call(accounts[1])).valueOf(),
            new BigNumber('1000').mul(precision).valueOf(), 'claimedBalances is not equal');
    })
});