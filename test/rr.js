var
    REMToken = artifacts.require("./test/REMTokenTest.sol"),
    REMCrowdSale = artifacts.require("./test/REMCrowdSaleTest.sol"),
    REMStrategy = artifacts.require("./REMStrategy.sol"),
    MintableTokenAllocator = artifacts.require("./allocator/MintableTokenAllocator.sol"),
    DistributedDirectContributionForwarder = artifacts.require("./contribution/DistributedDirectContributionForwarder.sol"),
    REMAgent = artifacts.require("./REMAgent.sol"),
    Referral = artifacts.require("./REMReferral.sol"),

    Utils = require("./utils"),
    BigNumber = require('BigNumber.js'),

    precision = new BigNumber("1000000000000000000"),
    usdPrecision = new BigNumber("100000"),
    crowdsaleSince = parseInt(new Date().getTime() / 1000 - 3600),
    crowdsaleTill = parseInt(new Date().getTime() / 1000) + 3600,
    signAddress = web3.eth.accounts[0],
    wrongSigner = web3.eth.accounts[5],
    etherHolder = web3.eth.accounts[9]

var abi = require('ethereumjs-abi'),
    BN = require('bn.js');

async function deploy() {
    const token = await REMToken.new(crowdsaleTill);
    const allocator = await MintableTokenAllocator.new(token.address);
    const contributionForwarder = await DistributedDirectContributionForwarder.new(100, [etherHolder], [100]);
    const strategy = await REMStrategy.new([], [crowdsaleSince - 6000, crowdsaleSince - 4000], [crowdsaleSince - 3600, crowdsaleSince], 75045000);

    const crowdsale = await REMCrowdSale.new(
        allocator.address,
        contributionForwarder.address,
        strategy.address,
        crowdsaleSince,
        crowdsaleTill,
        new BigNumber('50000000000').mul(precision),
        new BigNumber('50000000000').mul(precision)
    );

    const agent = await REMAgent.new([crowdsale.address], token.address);

    const referral = await Referral.new(
        new BigNumber('1000').mul(precision).valueOf(),
        allocator.address,
        crowdsale.address,
    )
    await token.updateMintingAgent(referral.address, true);
    await token.updateMintingAgent(allocator.address, true);
    await allocator.addCrowdsales(referral.address);
    await crowdsale.addSigner(signAddress);

    return {
        token,
        allocator,
        contributionForwarder,
        strategy,
        crowdsale,
        agent,
        referral
    };
}


function makeTransactionKYC(instance, sign, address, value) {
    'use strict';
    var h = abi.soliditySHA3(['address', 'address'], [new BN(instance.address.substr(2), 16), new BN(address.substr(2), 16)]),
        sig = web3.eth.sign(sign, h.toString('hex')).slice(2),
        r = `0x${sig.slice(0, 64)}`,
        s = `0x${sig.slice(64, 128)}`,
        v = web3.toDecimal(sig.slice(128, 130)) + 27;

    var data = abi.simpleEncode('contribute(uint8,bytes32,bytes32)', v, r, s);

    return instance.sendTransaction({value: value, from: address, data: data.toString('hex')});
}
async function makeTransaction(instance, sign, csale, address, amount) {
    'use strict';
    var h = abi.soliditySHA3(['address', 'address'], [new BN(csale.substr(2), 16), new BN(address.substr(2), 16)]),
        sig = web3.eth.sign(sign, h.toString('hex')).slice(2),
        r = `0x${sig.slice(0, 64)}`,
        s = `0x${sig.slice(64, 128)}`,
        v = web3.toDecimal(sig.slice(128, 130)) + 27;

    var data = abi.simpleEncode('multivestMint(address,uint256,uint8,bytes32,bytes32)', address, amount, v, r, s);

    return instance.sendTransaction({from: address, data: data.toString('hex')});
}

contract('Token', function (accounts) {
    it("t", async function () {
        const {
            token,
            allocator,
            contributionForwarder,
            strategy,
            crowdsale,
            agent,
            referral
        } = await deploy();
        await makeTransaction(referral, signAddress, crowdsale.address, accounts[1], new BigNumber('10').valueOf())
            .then(Utils.receiptShouldSucceed);
        await referral.burnUnusedTokens()
        await assert.equal(new BigNumber(await referral.totalSupply.call()).valueOf(),
            new BigNumber('0').mul(precision).valueOf(), 'claimedBalances is not equal');

    })
    it("t2", async function () {
        let {
            token,
            allocator,
            contributionForwarder,
            strategy,
            crowdsale,
            agent,
            referral
        } = await deploy();

         strategy = await REMStrategy.new([], [crowdsaleSince, crowdsaleTill], [crowdsaleTill, crowdsaleTill + 3600], 75045000);
         crowdsale = await REMCrowdSale.new(
            allocator.address,
            contributionForwarder.address,
            strategy.address,
            crowdsaleSince,
            crowdsaleTill,
            new BigNumber('50000000000').mul(precision),
            new BigNumber('50000000000').mul(precision)
        );

         agent = await REMAgent.new([crowdsale.address], token.address);

         referral = await Referral.new(
            new BigNumber('1000').mul(precision).valueOf(),
            allocator.address,
            crowdsale.address,
        )
        await token.updateMintingAgent(referral.address, true);
        await token.updateMintingAgent(allocator.address, true);
        await allocator.addCrowdsales(referral.address);
        await crowdsale.addSigner(signAddress);
        await makeTransaction(referral, signAddress, crowdsale.address, accounts[1], new BigNumber('10').valueOf())
            .then(Utils.receiptShouldFailed)
            .catch(Utils.catchReceiptShouldFailed);
    })
})