const RETToken = artifacts.require("./RETToken");
const MintableTokenAllocator = artifacts.require(".allocator/MintableTokenAllocator");
const DistributedDirectContributionForwarder = artifacts.require("./contribution/DistributedDirectContributionForwarder");
const RETStrategy = artifacts.require("./RETStrategy");
const RETCrowdSale = artifacts.require("./RETCrowdSale");
const RETAgent = artifacts.require("./RETAgent");
const TokenAllocation = artifacts.require("./TokenAllocation");
const RETStatsContract = artifacts.require("./RETStatsContract");

const SafeMath = artifacts.require("./../node_modules/zeppelin-solidity/contracts/math/SafeMath");

const BigNumber = require('bignumber.js');
module.exports = function (deployer, network, accounts) {
    let preicoSince = 1532426400, //07/24/2018 @ 10:00am (UTC)
        preicoTill = 1541030340, //10/31/2018 @ 11:59pm (UTC)
        icoSince = 1541030400, //11/01/2018 @ 12:00am (UTC)
        icoTill = 1546214400, //12/31/2018 @ 12:00am (UTC)
        thirtyDays = 2592000,

        precision = "1000000000000000000",
        usdPrecision = "100000",

        team = "0x627306090abab3a6e1400e9345bc60c78a8bef57".toLowerCase(),
        advisory = "0xf17f52151ebef6c7334fad080c5704d77216b732".toLowerCase(),
        treasury = "0xc5fdf4076b8f3a5357c5e395ab970b5b54098fef".toLowerCase(),
        earlyInvestors = "0x821aea9a577a9b44299b9c15c88cf3087f3b5544".toLowerCase(),
        bancor = "0x0f4f2ac550a1b4e2280d04c21cea7ebd822934b5".toLowerCase(),
        bonusHolder =treasury;
        etherHolder = "0x4dD93664e39FbB2A229E6A88eb1Da53f4ccc88Ac".toLowerCase(),
        signAddress = "0x0f84bdb7d3394bb903a5d53522479fa7076ff3d1".toLowerCase()

    deployer.deploy(SafeMath, {overwrite: false});

    deployer.link(SafeMath, [
    RETToken,
    RETCrowdSale,
    RETStrategy,
    TokenAllocation,
    MintableTokenAllocator,
    DistributedDirectContributionForwarder,
    RETAgent,
    RETStatsContract
    ]); // add other contracts here


    var  token,
    allocator,
    contributionForwarder,
    strategy,
    crowdsale,
    agent,
    allocation,
    stats;
    deployer.then(function () {
        return deployer.deploy(RETToken, icoTill + thirtyDays);
    }).then(function (instance) {
        token = instance;
        console.log('token', token.address);

        return deployer.deploy(MintableTokenAllocator, RETToken.address);
    }).then(function (instance) {
        allocator = instance;
        console.log('allocator', allocator.address);

        return deployer.deploy(DistributedDirectContributionForwarder, 100, [etherHolder], [100]);
    }).then(function (instance) {
        contributionForwarder = instance;
        console.log('contributionForwarder', contributionForwarder.address);

        return deployer.deploy(RETStrategy, [],[preicoSince,preicoTill],[icoSince,icoTill], 45045000);
    }).then(function (instance) {
        strategy = instance;
        console.log('strategy', strategy.address);
        return deployer.deploy(
            RETCrowdSale,
            MintableTokenAllocator.address,
            DistributedDirectContributionForwarder.address,
            RETStrategy.address,
            preicoSince,preicoTill,
            new BigNumber('50000000000').mul(precision), new BigNumber('50000000000').mul(precision)
        );
    }).then(function (instance) {
        crowdsale = instance;
        console.log('crowdsale', crowdsale.address);
        return deployer.deploy(RETAgent, RETCrowdSale.address, RETToken.address);
    }).then(function (instance) {
        agent = instance;
        console.log('agent', agent.address);
        return deployer.deploy(TokenAllocation, RETCrowdSale.address, MintableTokenAllocator.address);
    }).then(function (instance) {
        allocation = instance;
        console.log('allocation', allocation.address);
    }).then(async () => {

        tokenAllocation = await TokenAllocation.deployed();
        await token.updateMintingAgent(allocator.address, true);
        await token.updateBurnAgent(agent.address, true);
        await token.updateLockupAgent(agent.address, true);
        await token.updateLockupAgent(tokenAllocation.address,true);
        await token.updateMintingAgent(tokenAllocation.address, true);
        await token.updateExcludedAddress(bonusHolder, true)
        await crowdsale.setCrowdsaleAgent(agent.address);
        await crowdsale.addSigner(signAddress);
        await crowdsale.addExternalContributor(signAddress)
        await strategy.trustedAddresses(signAddress)
        await allocator.addCrowdsales(tokenAllocation.address);
        await allocator.addCrowdsales(crowdsale.address);

        await allocation.setVestingStartDate(icoTill+thirtyDays)
        await allocation.setAddresses(team,advisory ,treasury ,earlyInvestors , bancor);
        await allocation.allocate(allocator.address, new BigNumber('50000').mul(precision))

        return deployer.deploy(RETStatsContract, RETToken.address, RETCrowdSale.address);
    }).then(function (instance) {
        stats = instance;
        console.log('stats', RETStatsContract.address);
    }).then(() => {
        console.log("Finished");
    })
        .catch((err) => {
            console.error('ERROR', err)
        });

};