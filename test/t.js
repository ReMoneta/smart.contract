var
    REMToken = artifacts.require("./test/REMTokenTest.sol"),
    REMCrowdSale = artifacts.require("./REMCrowdSale.sol"),
    REMStrategy = artifacts.require("./REMStrategy.sol"),
    REMAllocation = artifacts.require("./TokenAllocation.sol"),
    MintableTokenAllocator = artifacts.require("./allocator/MintableTokenAllocator.sol"),
    DistributedDirectContributionForwarder = artifacts.require("./contribution/DistributedDirectContributionForwarder.sol"),
    MintableMultipleCrowdsaleOnSuccessAgent = artifacts.require("./agent/MintableMultipleCrowdsaleOnSuccessAgent.sol"),

    Utils = require("./utils"),
    BigNumber = require('BigNumber.js'),

    precision = new BigNumber("1000000000000000000"),
    usdPrecision = new BigNumber("100000"),
    icoSince = parseInt(new Date().getTime() / 1000 - 3600),
    icoTill = parseInt(new Date().getTime() / 1000) + 3600,
    signAddress = web3.eth.accounts[0],
    bountyAddress = web3.eth.accounts[5],
    etherHolder = web3.eth.accounts[9]

var abi = require('ethereumjs-abi'),
    BN = require('bn.js');

async function deploy() {
    const token = await REMToken.new(icoTill);
    const allocator = await MintableTokenAllocator.new(token.address);
    const contributionForwarder = await DistributedDirectContributionForwarder.new(100, [etherHolder], [100]);
    const strategy = await REMStrategy.new([], [icoSince, icoTill],[icoTill, icoTill+3600], 75045000);

    const crowdsale = await REMCrowdSale.new(
        allocator.address,
        contributionForwarder.address,
        strategy.address,
        icoSince,
        icoTill,
        new BigNumber('50000000000').mul(precision),
        new BigNumber('50000000000').mul(precision)
        );

    const agent = await MintableMultipleCrowdsaleOnSuccessAgent.new([crowdsale.address], token.address);
    const allocation = await REMAllocation.new(crowdsale.address,allocator.address);
    await allocator.addCrowdsales(allocation.address);
    await token.updateLockupAgent(allocation.address,true);


    return {
        token,
        allocator,
        contributionForwarder,
        strategy,
        crowdsale,
        agent,
        allocation
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
async function makeTransaction(instance, sign, csale, address, amount, _allocator) {
    'use strict';
    var h = abi.soliditySHA3(['address', 'address'], [new BN(csale.substr(2), 16), new BN(address.substr(2), 16)]),
        sig = web3.eth.sign(sign, h.toString('hex')).slice(2),
        r = `0x${sig.slice(0, 64)}`,
        s = `0x${sig.slice(64, 128)}`,
        v = web3.toDecimal(sig.slice(128, 130)) + 27;
    var data = abi.simpleEncode('multivestMint(address,uint256[3],address,uint8,bytes32,bytes32)', address, amount, _allocator, v, r, s);

    return instance.sendTransaction({from: address, data: data.toString('hex')});
}
contract('Token', function (accounts) {

    it("deploy", async function () {
        const {
            token,
            allocator,
            contributionForwarder,
            strategy,
            crowdsale,
            agent
        } = await deploy();

        let currentState = await crowdsale.getState()//Initializing
        assert.equal(currentState, 1, "state doesn't match");

        await token.updateMintingAgent(allocator.address, true);
        await crowdsale.setCrowdsaleAgent(agent.address);
        await allocator.addCrowdsales(crowdsale.address);

        currentState = await crowdsale.getState()//InCrowdsale
        assert.equal(new BigNumber(currentState).valueOf(), 3, "state doesn't match");

        await makeTransactionKYC(crowdsale, bountyAddress, accounts[2], new BigNumber('2').mul(precision))
            .then(Utils.receiptShouldFailed)
            .catch(Utils.catchReceiptShouldFailed);

        await crowdsale.addSigner(signAddress);

       let tokens = await strategy.getTokens.call(
            accounts[0],
            new BigNumber('9005009000').mul(precision),
            0,
            new BigNumber('2').mul(precision).valueOf(),
            0
        )
        await assert.equal(new BigNumber(tokens[0]).valueOf(),
            new BigNumber('15009000').mul(precision).valueOf(), "tokens is not equal")
        await assert.equal(new BigNumber(tokens[1]).valueOf(),
            new BigNumber('15009000').mul(precision).valueOf(), "tokensExcludingBonus is not equal")
        await assert.equal(new BigNumber(tokens[2]).valueOf(), 0, "bonus is not equal")

        await makeTransactionKYC(crowdsale, signAddress, accounts[2], new BigNumber('2').mul(precision))
            .then(Utils.receiptShouldSucceed)
        assert.equal(new BigNumber(await token.totalSupply.call()).valueOf(), new BigNumber('15009000').mul(precision).valueOf(), "state doesn't match");

        await strategy.updateDates(0, icoSince - 3600 * 2, icoSince - 3600);
        await crowdsale.updateState();

        currentState = await crowdsale.getState()//BeforeCrowdsale
        assert.equal(currentState, 2, "state doesn't match");

        await strategy.updateDates(1, icoSince, icoTill);
        await crowdsale.updateState();

        currentState = await crowdsale.getState()//InCrowdsale
        assert.equal(currentState, 3, "state doesn't match");
    });
    it("check  transfer", async function () {
        const {
            token,
            allocator,
            contributionForwarder,
            strategy,
            crowdsale,
            agent,
            allocation
        } = await deploy();

        let currentState = await crowdsale.getState()//Initializing
        assert.equal(currentState, 1, "state doesn't match");

        await token.updateMintingAgent(allocator.address, true);
        await token.updateMintingAgent(allocation.address, true);
        await crowdsale.setCrowdsaleAgent(agent.address);
        await allocator.addCrowdsales(crowdsale.address);
        await crowdsale.addSigner(signAddress);


        await makeTransactionKYC(crowdsale, signAddress, accounts[4], new BigNumber('2').mul(precision))
            .then(Utils.receiptShouldSucceed)
        assert.equal(new BigNumber(await token.totalSupply.call()).valueOf(), new BigNumber('15009000').mul(precision).valueOf(), "state doesn't match");

        await strategy.updateDates(0, icoSince - 3600*2, icoSince - 3600);
        await crowdsale.updateState();
        await token.mint(accounts[3], 10000)
            .then(Utils.receiptShouldSucceed)
        await token.mint(accounts[4], 1000)
            .then(Utils.receiptShouldSucceed)
        await token.transfer(accounts[2], 100, {from:accounts[4]})
            .then(Utils.receiptShouldFailed)
            .catch(Utils.catchReceiptShouldFailed);
        await token.updateExcludedAddress(accounts[4], true)
            .then(Utils.receiptShouldSucceed)
        assert.equal((await token.excludedAddresses.call(accounts[4])).valueOf(), true,'excludedAddresses is not equal')
        await token.transfer(accounts[2], 100, {from:accounts[4]})
            .then(Utils.receiptShouldSucceed)
        await Utils.balanceShouldEqualTo(token, accounts[2], 0)
        assert.equal(new BigNumber(await token.intermediateBalances.call(accounts[2])).valueOf(), 100, 'intermediateBalances is not equal')
        await token.transfer(accounts[2], 100, {from:accounts[3]})
            .then(Utils.receiptShouldFailed)
            .catch(Utils.catchReceiptShouldFailed)
        await token.setUnlockTokensTimeTest(icoSince - 3600)
        await Utils.balanceShouldEqualTo(token, accounts[3], 0)
        assert.equal(new BigNumber(await token.intermediateBalances.call(accounts[3])).valueOf(), 10000, 'intermediateBalances is not equal')
        await token.updateMintingAgent(allocation.address, true);
        await token.updateMintingAgent(allocator.address, true);
        await allocator.addCrowdsales(allocation.address);
        await crowdsale.addSigner(signAddress);
        await allocation.setVestingStartDate(icoSince)
        await makeTransaction(allocation, signAddress, crowdsale.address, accounts[3], [new BigNumber('10').valueOf(),0,0], allocator.address)
            .then(Utils.receiptShouldSucceed);
        await token.transfer(accounts[2], 100, {from:accounts[3]})
            .then(Utils.receiptShouldSucceed)
        await Utils.balanceShouldEqualTo(token, accounts[2], 0)
        assert.equal(new BigNumber(await token.intermediateBalances.call(accounts[2])).valueOf(), 200, 'intermediateBalances is not equal')
    });
});