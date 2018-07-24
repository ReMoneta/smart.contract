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
    let preicoSince = 1532415600, //07/24/2018 @ 7:00am (UTC)
        preicoTill = 1541030340, //10/31/2018 @ 11:59pm (UTC)
        thirtyDays = 2592000,

        precision = "1000000000000000000",
        usdPrecision = "100000",

        team = "0xb5F1ebd41b4f029c5Cd1c4156C5728Db445649F2".toLowerCase(),
        advisory = "0x49A54Ff6466764A91dF9B8a90Da04A39908ACE0e".toLowerCase(),
        treasury = "0xb4536A3db4fcb582477c8F2feD443353510A85De".toLowerCase(),
        earlyInvestors = "0x0325cA441651043a870D78c09c0C77fEc0221619".toLowerCase(),
        bancor = "0xb4536A3db4fcb582477c8F2feD443353510A85De".toLowerCase(),

        owner = "0xf6d74C08ec51acbfCBD7e96E9c5bF334e1390dA2".toLowerCase(),
        etherHolder = "0x4052B89894aD5b10DcB7aA3E570aEc193c3ef6B9".toLowerCase(),
        signAddress = "0x4758b9aaf8ce6479e38ea3da5bfdefcfa798fac2".toLowerCase()

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
        return deployer.deploy(RETToken, preicoTill + thirtyDays);
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

        return deployer.deploy(RETStrategy, [],[preicoSince,preicoTill], 45045000);
    }).then(function (instance) {
        strategy = instance;
        console.log('strategy', strategy.address);
        return deployer.deploy(
            RETCrowdSale,
            MintableTokenAllocator.address,
            DistributedDirectContributionForwarder.address,
            RETStrategy.address,
            preicoSince,preicoTill,
            new BigNumber('52500000000').mul(precision)
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
        // await token.updateExcludedAddress(bonusHolder, true) //if it is needed
        await crowdsale.setCrowdsaleAgent(agent.address);
        await crowdsale.addSigner(signAddress);
        await crowdsale.addExternalContributor(signAddress)
        await strategy.trustedAddresses(signAddress)
        await allocator.addCrowdsales(tokenAllocation.address);
        await allocator.addCrowdsales(crowdsale.address);

        await allocation.setVestingStartDate(preicoTill+thirtyDays)
        await allocation.setAddresses(team,advisory ,treasury ,earlyInvestors , bancor);
        // await allocation.allocate(allocator.address) //
        // needs to be run maulaly after all referrals allocated to include bonuses

        await allocation.transferOwnership(owner)
        await token.transferOwnership(owner)
        await allocator.transferOwnership(owner)
        await strategy.transferOwnership(owner)
        await crowdsale.transferOwnership(owner)

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
