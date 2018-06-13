var
    REMToken = artifacts.require("./test/REMTokenTest.sol"),
    REMCrowdSale = artifacts.require("./test/REMCrowdSaleTest.sol"),
    REMStrategy = artifacts.require("./REMStrategy.sol"),
    MintableTokenAllocator = artifacts.require("./allocator/MintableTokenAllocator.sol"),
    DistributedDirectContributionForwarder = artifacts.require("./contribution/DistributedDirectContributionForwarder.sol"),
    REMAgent = artifacts.require("./REMAgent.sol"),

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
    const strategy = await REMStrategy.new([], [crowdsaleSince, crowdsaleTill], [crowdsaleTill, crowdsaleTill + 3600], 75045000);

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


    return {
        token,
        allocator,
        contributionForwarder,
        strategy,
        crowdsale,
        agent
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

contract('Token', function (accounts) {
    /*
    it('deploy contract & set allocator and pricing strategy, check if the params  are equal', async function () {
        const {
            token,
            allocator,
            contributionForwarder,
            strategy,
            crowdsale,
            agent
        } = await deploy();

        await Utils.checkState({crowdsale}, {
            crowdsale: {
                softCap: new BigNumber('5000000').mul(100).mul(100).mul(precision).valueOf(),
                contributorsWei: [
                    {[accounts[0]]: 0},
                    {[accounts[1]]: 0},
                ],

                hardCap: new BigNumber('5000000').mul(100).mul(100).mul(precision).valueOf(),
                currentState: 0,
                allocator: allocator.address,
                contributionForwarder: contributionForwarder.address,
                pricingStrategy: strategy.address,
                crowdsaleAgent: 0x0,
                finalized: false,
                startDate: crowdsaleSince,
                endDate: crowdsaleTill,
                allowWhitelisted: true,
                allowSigned: true,
                allowAnonymous: false,
                tokensSold: new BigNumber('0').mul(precision).valueOf(),
                whitelisted: [
                    {[accounts[0]]: false},
                    {[accounts[1]]: false},
                ],
                signers: [
                    {[accounts[0]]: false},
                    {[accounts[1]]: false},
                ],
                externalContributionAgents: [
                    {[accounts[0]]: false},
                    {[accounts[1]]: false},
                ],
                owner: accounts[0],
                newOwner: 0x0,
            }
        });

        await crowdsale.setCrowdsaleAgent(agent.address, {from: accounts[1]})
            .then(Utils.receiptShouldFailed)
            .catch(Utils.catchReceiptShouldFailed);
        await crowdsale.setCrowdsaleAgent(agent.address, {from: accounts[0]});
         await token.updateLockupAgent(agent.address, true);

        await Utils.checkState({crowdsale}, {
            crowdsale: {
                softCap: new BigNumber('5000000').mul(100).mul(100).mul(precision).valueOf(),
                contributorsWei: [
                    {[accounts[0]]: 0},
                    {[accounts[1]]: 0},
                ],
                hardCap: new BigNumber('5000000').mul(100).mul(100).mul(precision).valueOf(),
                currentState: 0,
                allocator: allocator.address,
                contributionForwarder: contributionForwarder.address,
                pricingStrategy: strategy.address,
                crowdsaleAgent: agent.address,
                finalized: false,
                startDate: crowdsaleSince,
                endDate: crowdsaleTill,
                allowWhitelisted: true,
                allowSigned: true,
                allowAnonymous: false,
                tokensSold: new BigNumber('0').mul(precision).valueOf(),
                whitelisted: [
                    {[accounts[0]]: false},
                    {[accounts[1]]: false},
                ],
                signers: [
                    {[accounts[0]]: false},
                    {[accounts[1]]: false},
                ],
                externalContributionAgents: [
                    {[accounts[0]]: false},
                    {[accounts[1]]: false},
                ],
                owner: accounts[0],
                newOwner: 0x0,
            }
        });
    })
    it('check  if updateState updates start and end dates', async function () {
        const {
            token,
            allocator,
            contributionForwarder,
            strategy,
            crowdsale,
            agent
        } = await deploy();
        await crowdsale.updateState()
            .then(Utils.receiptShouldSucceed)
        await Utils.checkState({crowdsale}, {
            crowdsale: {
                softCap: new BigNumber('5000000').mul(100).mul(100).mul(precision).valueOf(),
                contributorsWei: [
                    {[accounts[0]]: 0},
                    {[accounts[1]]: 0},
                ],

                hardCap: new BigNumber('5000000').mul(100).mul(100).mul(precision).valueOf(),
                currentState: 1,
                allocator: allocator.address,
                contributionForwarder: contributionForwarder.address,
                pricingStrategy: strategy.address,
                crowdsaleAgent: 0x0,
                finalized: false,
                startDate: crowdsaleSince,
                endDate: crowdsaleTill,
                allowWhitelisted: true,
                allowSigned: true,
                allowAnonymous: false,
                tokensSold: new BigNumber('0').mul(precision).valueOf(),
                whitelisted: [
                    {[accounts[0]]: false},
                    {[accounts[1]]: false},
                ],
                signers: [
                    {[accounts[0]]: false},
                    {[accounts[1]]: false},
                ],
                externalContributionAgents: [
                    {[accounts[0]]: false},
                    {[accounts[1]]: false},
                ],
                owner: accounts[0],
                newOwner: 0x0,
            }
        });
        await strategy.updateDates(0, crowdsaleSince-5, crowdsaleSince)
        await crowdsale.updateState()
            .then(Utils.receiptShouldSucceed)

        await Utils.checkState({crowdsale}, {
            crowdsale: {
                softCap: new BigNumber('5000000').mul(100).mul(100).mul(precision).valueOf(),
                contributorsWei: [
                    {[accounts[0]]: 0},
                    {[accounts[1]]: 0},
                ],

                hardCap: new BigNumber('5000000').mul(100).mul(100).mul(precision).valueOf(),
                currentState: 1,
                allocator: allocator.address,
                contributionForwarder: contributionForwarder.address,
                pricingStrategy: strategy.address,
                crowdsaleAgent: 0x0,
                finalized: false,
                // crowdsaleTill, crowdsaleTill + 3600
                startDate: crowdsaleTill,
                endDate: crowdsaleTill + 3600,
                allowWhitelisted: true,
                allowSigned: true,
                allowAnonymous: false,
                tokensSold: new BigNumber('0').mul(precision).valueOf(),
                whitelisted: [
                    {[accounts[0]]: false},
                    {[accounts[1]]: false},
                ],
                signers: [
                    {[accounts[0]]: false},
                    {[accounts[1]]: false},
                ],
                externalContributionAgents: [
                    {[accounts[0]]: false},
                    {[accounts[1]]: false},
                ],
                owner: accounts[0],
                newOwner: 0x0,
            }
        });
    })
    */
    describe('check contribution', async function () {
        let token,
            allocator,
            contributionForwarder,
            strategy,
            crowdsale,
            agent
        beforeEach(async function () {
            token = await REMToken.new(crowdsaleTill);
            allocator = await MintableTokenAllocator.new(token.address);
            contributionForwarder = await DistributedDirectContributionForwarder.new(100, [etherHolder], [100]);
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
            await crowdsale.setCrowdsaleAgent(agent.address, {from: accounts[0]});
            await crowdsale.addSigner(signAddress);
            await token.updateMintingAgent(allocator.address, true);
            await allocator.addCrowdsales(crowdsale.address);
            await token.updateBurnAgent(agent.address, true);
            await token.updateLockupAgent(agent.address, true);
        })
        it('only multivest pro is allowed', async function () {
            await makeTransactionKYC(crowdsale, signAddress, accounts[3], new BigNumber('1.5').mul(precision))
            // 1.5*750.45
                .then(Utils.receiptShouldSucceed)

            await Utils.checkState({token, crowdsale}, {
                token: {
                    // time: crowdsaleTill,
                    standard: 'ERC20 0.1',
                    maxSupply: new BigNumber('400000000000').mul(precision).valueOf(),
                    mintingAgents: [
                        {[accounts[0]]: true},
                        {[accounts[1]]: false},
                    ],
                    // disableMinting: false,
                    decimals: 18,
                    name: 'Remoneta ERC 20 Token',
                    symbol: 'RET',
                    balanceOf: [
                        {[accounts[0]]: new BigNumber('0').mul(precision).valueOf()},
                        {[accounts[1]]: new BigNumber('0').mul(precision).valueOf()},
                        {[accounts[3]]: new BigNumber('0').mul(precision).valueOf()},
                    ],
                    intermediateBalances: [
                        {[accounts[0]]: new BigNumber('0').mul(precision).valueOf()},
                        {[accounts[1]]: new BigNumber('0').mul(precision).valueOf()},
                        {[accounts[3]]: new BigNumber('11256750').mul(precision).valueOf()},
                    ],
                    totalSupply: new BigNumber('11256750').mul(precision).valueOf(),
                    owner: accounts[0]
                },
                crowdsale: {
                    softCap: new BigNumber('5000000').mul(100).mul(100).mul(precision).valueOf(),
                    contributorsWei: [
                        {[accounts[0]]: 0},
                        {[accounts[3]]: new BigNumber('1.5').mul(precision)},
                    ],
                    hardCap: new BigNumber('5000000').mul(100).mul(100).mul(precision).valueOf(),
                    currentState: 3,
                    allocator: allocator.address,
                    contributionForwarder: contributionForwarder.address,
                    pricingStrategy: strategy.address,
                    crowdsaleAgent: agent.address,
                    finalized: false,
                    startDate: crowdsaleSince,
                    endDate: crowdsaleTill,
                    allowWhitelisted: true,
                    allowSigned: true,
                    allowAnonymous: false,
                    tokensSold: new BigNumber('11256750').mul(precision).valueOf(),
                    whitelisted: [
                        {[accounts[0]]: false},
                        {[accounts[1]]: false},
                    ],
                    signers: [
                        {[accounts[0]]: true},
                        {[accounts[1]]: false},
                    ],
                    externalContributionAgents: [
                        {[accounts[0]]: false},
                        {[accounts[1]]: false},
                    ],
                    owner: accounts[0],
                    newOwner: 0x0,
                }
            });
            await makeTransactionKYC(crowdsale, wrongSigner, accounts[3], new BigNumber('5').mul(precision))
                .then(Utils.receiptShouldFailed)
                .catch(Utils.catchReceiptShouldFailed);
            await crowdsale.sendTransaction({value: new BigNumber('4').mul(precision), from: accounts[8]})
                .then(Utils.receiptShouldFailed)
                .catch(Utils.catchReceiptShouldFailed);
        })
        it('zero weis  should fail', async function () {
            await makeTransactionKYC(crowdsale, signAddress, accounts[7], new BigNumber('0').mul(precision))
                .then(Utils.receiptShouldFailed)
                .catch(Utils.catchReceiptShouldFailed);
        })
        it('less than  min purchase  should fail (100$ and 10$)', async function () {
            await makeTransactionKYC(crowdsale, signAddress, accounts[8], new BigNumber('0.12').mul(precision))
                .then(Utils.receiptShouldFailed)
                .catch(Utils.catchReceiptShouldFailed);
            await makeTransactionKYC(crowdsale, signAddress, accounts[8], new BigNumber('0.2').mul(precision))
                .then(Utils.receiptShouldSucceed)
            await strategy.updateDates(0, crowdsaleTill-5, crowdsaleTill)
            await strategy.updateDates(1, crowdsaleSince, crowdsaleTill)
            await makeTransactionKYC(crowdsale, signAddress, accounts[8], new BigNumber('0.012').mul(precision))
                .then(Utils.receiptShouldFailed)
                .catch(Utils.catchReceiptShouldFailed);
            await makeTransactionKYC(crowdsale, signAddress, accounts[8], new BigNumber('0.02').mul(precision))
                .then(Utils.receiptShouldSucceed)
        })
        it('outdated  should fail', async function () {
            await strategy.updateDates(0, crowdsaleTill-5, crowdsaleTill)
            await strategy.updateDates(1, crowdsaleTill-5, crowdsaleTill)

            await makeTransactionKYC(crowdsale, signAddress, accounts[8], new BigNumber('5').mul(precision))
                .then(Utils.receiptShouldFailed)
                .catch(Utils.catchReceiptShouldFailed);
        })
        it('before sale period  should fail', async function () {
            await strategy.updateDates(0, crowdsaleSince-5, crowdsaleSince)
            await strategy.updateDates(1, crowdsaleSince-5, crowdsaleSince)

            await makeTransactionKYC(crowdsale, signAddress, accounts[8], new BigNumber('5').mul(precision))
                .then(Utils.receiptShouldFailed)
                .catch(Utils.catchReceiptShouldFailed);
        })
        it('tokens less than for all tiers  should fail', async function () {
            await token.mint(accounts[6], new BigNumber('49999999000').mul(precision).valueOf())
                .then(Utils.receiptShouldSucceed)
            await crowdsale.updateSoldTokens(new BigNumber('49999999000').mul(precision).valueOf())

            await makeTransactionKYC(crowdsale, signAddress, accounts[8], new BigNumber('5').mul(precision))
                .then(Utils.receiptShouldFailed)
                .catch(Utils.catchReceiptShouldFailed);
        })

    })
    it('forwarder is not working till the softcap collected;', async function () {
        const {
            token,
            allocator,
            contributionForwarder,
            strategy,
            crowdsale,
            agent
        } = await deploy();
        await crowdsale.setCrowdsaleAgent(agent.address, {from: accounts[0]});
        await crowdsale.addSigner(signAddress);
        await token.updateMintingAgent(allocator.address, true);
        await allocator.addCrowdsales(crowdsale.address);
        await token.updateBurnAgent(agent.address, true);
        await token.updateLockupAgent(agent.address, true);

        let ethBalance  = await Utils.getEtherBalance(web3.eth.accounts[9])
        await Utils.checkEtherBalance(web3.eth.accounts[9], ethBalance)
        await makeTransactionKYC(crowdsale, signAddress, accounts[3], new BigNumber('1.5').mul(precision))
        // 1.5*750.45
            .then(Utils.receiptShouldSucceed)
        await Utils.checkEtherBalance(web3.eth.accounts[9], ethBalance)
        await Utils.checkState({token, crowdsale}, {
            token: {
                // time: crowdsaleTill,
                standard: 'ERC20 0.1',
                maxSupply: new BigNumber('400000000000').mul(precision).valueOf(),
                mintingAgents: [
                    {[accounts[0]]: true},
                    {[accounts[1]]: false},
                ],
                // disableMinting: false,
                decimals: 18,
                name: 'Remoneta ERC 20 Token',
                symbol: 'RET',
                balanceOf: [
                    {[accounts[0]]: new BigNumber('0').mul(precision).valueOf()},
                    {[accounts[1]]: new BigNumber('0').mul(precision).valueOf()},
                    {[accounts[3]]: new BigNumber('0').mul(precision).valueOf()},
                ],
                intermediateBalances: [
                    {[accounts[0]]: new BigNumber('0').mul(precision).valueOf()},
                    {[accounts[1]]: new BigNumber('0').mul(precision).valueOf()},
                    {[accounts[3]]: new BigNumber('11256750').mul(precision).valueOf()},
                ],
                totalSupply: new BigNumber('11256750').mul(precision).valueOf(),
                owner: accounts[0]
            },
            crowdsale: {
                softCap: new BigNumber('5000000').mul(100).mul(100).mul(precision).valueOf(),
                contributorsWei: [
                    {[accounts[0]]: 0},
                    {[accounts[3]]: new BigNumber('1.5').mul(precision)},
                ],
                hardCap: new BigNumber('5000000').mul(100).mul(100).mul(precision).valueOf(),
                currentState: 3,
                allocator: allocator.address,
                contributionForwarder: contributionForwarder.address,
                pricingStrategy: strategy.address,
                crowdsaleAgent: agent.address,
                finalized: false,
                startDate: crowdsaleSince,
                endDate: crowdsaleTill,
                allowWhitelisted: true,
                allowSigned: true,
                allowAnonymous: false,
                tokensSold: new BigNumber('11256750').mul(precision).valueOf(),
                whitelisted: [
                    {[accounts[0]]: false},
                    {[accounts[1]]: false},
                ],
                signers: [
                    {[accounts[0]]: true},
                    {[accounts[1]]: false},
                ],
                externalContributionAgents: [
                    {[accounts[0]]: false},
                    {[accounts[1]]: false},
                ],
                owner: accounts[0],
                newOwner: 0x0,
            }
        });
        await crowdsale.updateSoftCap(new BigNumber('21256750').mul(precision).valueOf())
        await makeTransactionKYC(crowdsale, signAddress, accounts[3], new BigNumber('1.5').mul(precision))
        // 1.5*750.45
            .then(Utils.receiptShouldSucceed)
        await Utils.checkEtherBalance(web3.eth.accounts[9], ethBalance.add(new BigNumber('3').mul(precision)))
    })
    it('hardCap can be changed by Owner Only', async function () {
        const {
            token,
            allocator,
            contributionForwarder,
            strategy,
            crowdsale,
            agent
        } = await deploy();
       await crowdsale.updateHardCap( new BigNumber('30000000000').mul(precision))
           .then(Utils.receiptShouldSucceed)
        await crowdsale.updateHardCap(new BigNumber('40000000000').mul(precision), {from: accounts[6]})
            .then(Utils.receiptShouldFailed)
            .catch(Utils.catchReceiptShouldFailed)
    })
    it('check lockup period', async function () {
        const {
            token,
            allocator,
            contributionForwarder,
            strategy,
            crowdsale,
            agent
        } = await deploy();
        await crowdsale.setCrowdsaleAgent(agent.address, {from: accounts[0]});
        await crowdsale.addSigner(signAddress);
        await token.updateMintingAgent(allocator.address, true);
        await allocator.addCrowdsales(crowdsale.address);
        await token.updateBurnAgent(agent.address, true);
        await token.updateLockupAgent(agent.address, true);

        let ethBalance  = await Utils.getEtherBalance(web3.eth.accounts[9])
        await Utils.checkEtherBalance(web3.eth.accounts[9], ethBalance)
        await makeTransactionKYC(crowdsale, signAddress, accounts[3], new BigNumber('1.5').mul(precision))
        // 1.5*750.45
            .then(Utils.receiptShouldSucceed)
        await Utils.checkState({token, crowdsale}, {
            token: {
                // time: crowdsaleTill,
                standard: 'ERC20 0.1',
                maxSupply: new BigNumber('400000000000').mul(precision).valueOf(),
                mintingAgents: [
                    {[accounts[0]]: true},
                    {[accounts[1]]: false},
                ],
                // disableMinting: false,
                decimals: 18,
                name: 'Remoneta ERC 20 Token',
                symbol: 'RET',
                balanceOf: [
                    {[accounts[0]]: new BigNumber('0').mul(precision).valueOf()},
                    {[accounts[1]]: new BigNumber('0').mul(precision).valueOf()},
                    {[accounts[3]]: new BigNumber('0').mul(precision).valueOf()},
                ],
                intermediateBalances: [
                    {[accounts[0]]: new BigNumber('0').mul(precision).valueOf()},
                    {[accounts[1]]: new BigNumber('0').mul(precision).valueOf()},
                    {[accounts[3]]: new BigNumber('11256750').mul(precision).valueOf()},
                ],
                totalSupply: new BigNumber('11256750').mul(precision).valueOf(),
                owner: accounts[0]
            },
            crowdsale: {
                softCap: new BigNumber('5000000').mul(100).mul(100).mul(precision).valueOf(),
                contributorsWei: [
                    {[accounts[0]]: 0},
                    {[accounts[3]]: new BigNumber('1.5').mul(precision)},
                ],
                hardCap: new BigNumber('5000000').mul(100).mul(100).mul(precision).valueOf(),
                currentState: 3,
                allocator: allocator.address,
                contributionForwarder: contributionForwarder.address,
                pricingStrategy: strategy.address,
                crowdsaleAgent: agent.address,
                finalized: false,
                startDate: crowdsaleSince,
                endDate: crowdsaleTill,
                allowWhitelisted: true,
                allowSigned: true,
                allowAnonymous: false,
                tokensSold: new BigNumber('11256750').mul(precision).valueOf(),
                whitelisted: [
                    {[accounts[0]]: false},
                    {[accounts[1]]: false},
                ],
                signers: [
                    {[accounts[0]]: true},
                    {[accounts[1]]: false},
                ],
                externalContributionAgents: [
                    {[accounts[0]]: false},
                    {[accounts[1]]: false},
                ],
                owner: accounts[0],
                newOwner: 0x0,
            }
        });


        let result = await token.lockedAmount.call(accounts[3],1)
        await assert.equal(new BigNumber(result).valueOf(), new BigNumber('11256750').mul(0.9).mul(precision).valueOf(), "lockedBalance is not equal")
    })
})