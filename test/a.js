var
    REMToken = artifacts.require("./test/REMTokenTest.sol"),
    REMCrowdSale = artifacts.require("./REMCrowdSale.sol"),
    REMStrategy = artifacts.require("./REMStrategy.sol"),
    MintableTokenAllocator = artifacts.require("./allocator/MintableTokenAllocator.sol"),
    DistributedDirectContributionForwarder = artifacts.require("./contribution/DistributedDirectContributionForwarder.sol"),
    MintableMultipleCrowdsaleOnSuccessAgent = artifacts.require("./agent/MintableMultipleCrowdsaleOnSuccessAgent.sol"),
    REMAllocation = artifacts.require("./TokenAllocation.sol"),
    PeriodicTokenVesting = artifacts.require("./PeriodicTokenVesting.sol"),

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
    const allocation = await REMAllocation.new(crowdsale.address);


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

contract('Allocation', function (accounts) {

    it("deploy", async function () {
        const {
            token,
            allocator,
            contributionForwarder,
            strategy,
            crowdsale,
            agent,
            allocation,
        } = await deploy();

        await crowdsale.setCrowdsaleAgent(agent.address);
        await allocator.addCrowdsales(crowdsale.address);
        await crowdsale.addSigner(signAddress);
        await token.updateMintingAgent(allocator.address, true);
        await allocator.addCrowdsales(allocation.address);
        await allocation.setVestingStartDate(icoTill)
        await allocation.setAddresses(accounts[6],accounts[7],accounts[8],accounts[9],accounts[5],accounts[4]);
        await allocation.initVesting({from:accounts[2]})
            .then(Utils.receiptShouldFailed)
            .catch(Utils.catchReceiptShouldFailed);
        await allocation.initVesting({from:accounts[0]})
        await allocation.allocate(allocator.address)
            .then(Utils.receiptShouldSucceed)
        await allocation.allocate(allocator.address)
            .then(Utils.receiptShouldFailed)
            .catch(Utils.catchReceiptShouldFailed);

    })

    it("check that METHODS could be called only by owner", async function () {
        const {
            token,
            allocator,
            contributionForwarder,
            strategy,
            crowdsale,
            agent,
            allocation,
        } = await deploy();
        // await token.updateMintingAgent(allocator.address, true);
        // await token.setUnlockTime(icoSince)
        //  .then(Utils.receiptShouldSucceed)
        // assert.equal(await token.time.call().valueOf(), icoSince, 'locked time is not equal')
        // await allocator.addCrowdsales(allocation.address);
        await crowdsale.setCrowdsaleAgent(agent.address);
        await allocator.addCrowdsales(crowdsale.address);
        await crowdsale.addSigner(signAddress);
        await token.updateMintingAgent(allocator.address, true);
        await allocator.addCrowdsales(allocation.address);
        await allocation.setVestingStartDate(icoTill)
        await allocation.setAddresses(accounts[6],accounts[7],accounts[8],accounts[9],accounts[5],accounts[4]);
        await  allocation.createVesting(accounts[0], icoTill, 0, 31556926, 3, true, accounts[0],{from: accounts[1]})
            .then(Utils.receiptShouldFailed)
            .catch(Utils.catchReceiptShouldFailed);
        await  allocation.createVesting(accounts[0], icoTill, 0, 31556926, 3, true,accounts[0])
            .then(Utils.receiptShouldSucceed)
        console.log(await allocation.vestings.call(0));
        let vesting = await PeriodicTokenVesting.at(await allocation.vestings.call(0)) //Address of the contract, obtained from Etherscan
        assert.equal(await vesting.periods.call(), 3, 'periods is not equal');
        assert.equal(await vesting.beneficiary.call(), accounts[0], '_beneficiary is not equal');
        assert.equal(await vesting.start.call(), icoTill, 'start is not equal');
        assert.equal(await vesting.duration.call(), 31556926, 'duration is not equal');
        assert.equal(await vesting.revocable.call(), true, 'revocable is not equal');
        await allocation.vestingMint(vesting.address, allocator.address, 1000)
        assert.equal(new BigNumber(await vesting.vestedAmount(token.address)), 0, 'vestedAmount is not equal')

        await  allocation.createVesting(accounts[2], parseInt(new Date().getTime() / 1000) - 1, 0, 60, 2, true,accounts[0])
            .then(Utils.receiptShouldSucceed)
        vesting = await PeriodicTokenVesting.at(await allocation.vestings.call(1)) //Address of the contract, obtained from Etherscan
        await allocation.vestingMint(vesting.address, allocator.address, 100)
        assert.equal(new BigNumber(await vesting.vestedAmount(token.address)).valueOf(), 0, 'vestedAmount is not equal')

        await  allocation.createVesting(accounts[3], parseInt(new Date().getTime() / 1000) - 31, 0, 30, 2, true,accounts[0])
            .then(Utils.receiptShouldSucceed)
        await allocation.vestingMint(vesting.address, allocator.address, 100)
        vesting = await PeriodicTokenVesting.at(await allocation.vestings.call(2)) //Address of the contract, obtained from Etherscan
        await allocation.vestingMint(vesting.address, allocator.address, 100)
        assert.equal(new BigNumber(await vesting.vestedAmount(token.address)).valueOf(), 50, 'vestedAmount is not equal')

        await vesting.release(token.address)
            .then(Utils.receiptShouldFailed)
            .catch(Utils.catchReceiptShouldFailed);
        await token.updateExcludedAddress(vesting.address, true)
        assert.equal((await token.excludedAddresses.call(vesting.address)).valueOf(), true,'excludedAddresses is not equal')
        await vesting.release(token.address)
        Utils.balanceShouldEqualTo(token, accounts[3], 50)

        await  allocation.createVesting(accounts[4], parseInt(new Date().getTime() / 1000) - 31, 0, 30, 3, true,accounts[0])
            .then(Utils.receiptShouldSucceed)
        vesting = await PeriodicTokenVesting.at(await allocation.vestings.call(3)) //Address of the contract, obtained from Etherscan
        await allocation.vestingMint(vesting.address,allocator.address, 100)
        assert.equal(new BigNumber(await vesting.vestedAmount(token.address)).valueOf(), 33, 'vestedAmount is not equal')
        await token.updateExcludedAddress(vesting.address, true)
        await vesting.release(token.address);
        await vesting.release(token.address)
            .then(Utils.receiptShouldFailed)
            .catch(Utils.catchReceiptShouldFailed);
        Utils.balanceShouldEqualTo(token, accounts[4], 33)

        await  allocation.createVesting(accounts[5], parseInt(new Date().getTime() / 1000) - 20, 0, 30, 2, true,accounts[0])
            .then(Utils.receiptShouldSucceed)
        vesting = await PeriodicTokenVesting.at(await allocation.vestings.call(4)) //Address of the contract, obtained from Etherscan
        await allocation.vestingMint(vesting.address, allocator.address, 100)
        assert.equal(new BigNumber(await vesting.vestedAmount(token.address)).valueOf(), 0, 'vestedAmount is not equal')
        assert.equal(new BigNumber(await token.balanceOf.call(vesting.address)).valueOf(), 100, 'vesting balance is not equal')
        await token.updateExcludedAddress(vesting.address, true)
        await allocation.revokeVesting(vesting.address,token.address)
            .then(Utils.receiptShouldSucceed)
        assert.equal(new BigNumber(await token.balanceOf.call(vesting.address)).valueOf(), 0, 'vesting balance is not equal')


    });
})