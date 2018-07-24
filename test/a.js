var
    RETToken = artifacts.require("./test/RETTokenTest.sol"),
    RETCrowdSale = artifacts.require("./RETCrowdSale.sol"),
    RETStrategy = artifacts.require("./RETStrategy.sol"),
    MintableTokenAllocator = artifacts.require("./allocator/MintableTokenAllocator.sol"),
    DistributedDirectContributionForwarder = artifacts.require("./contribution/DistributedDirectContributionForwarder.sol"),
    RETAgent = artifacts.require("./RETAgent.sol"),
    RETAllocation = artifacts.require("./TokenAllocation.sol"),
    // AllocationLockupContract = artifacts.require("./AllocationLockupContract.sol"),

    Utils = require("./utils"),
    BigNumber = require('bignumber.js'),

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
    // const allocationLock = await AllocationLockupContract.new();
    const token = await RETToken.new(icoTill);
    const allocator = await MintableTokenAllocator.new(token.address);
    const contributionForwarder = await DistributedDirectContributionForwarder.new(100, [etherHolder], [100]);
    const strategy = await RETStrategy.new([], [icoSince, icoSince+1], 75045000);

    const crowdsale = await RETCrowdSale.new(
        allocator.address,
        contributionForwarder.address,
        strategy.address,
        icoSince,
        icoTill,
        new BigNumber('52500000000').mul(precision)
    );

    const agent = await RETAgent.new(crowdsale.address, token.address);
    await crowdsale.setCrowdsaleAgent(agent.address);
    await allocator.addCrowdsales(crowdsale.address);
    await crowdsale.addSigner(signAddress);
    await token.updateMintingAgent(allocator.address, true);
    const allocation = await RETAllocation.new(crowdsale.address,allocator.address);
    await token.updateMintingAgent(allocation.address, true);

    return {
        token,
        allocator,
        contributionForwarder,
        strategy,
        crowdsale,
        agent,
        allocation,
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
        await token.updateLockupAgent(allocation.address,true);
        // await allocation.setVestingStartDate(icoTill)
        await allocation.setAddresses(accounts[6],accounts[7],accounts[8],accounts[9],accounts[5]);
        await allocation.allocate(allocator.address, new BigNumber(20).mul(precision))
            .then(Utils.receiptShouldFailed)
            .catch(Utils.catchReceiptShouldFailed);
        await allocation.setVestingStartDate(icoSince)
        await allocation.allocate(allocator.address, new BigNumber(20).mul(precision))
            .then(Utils.receiptShouldSucceed)
        await allocation.allocate(allocator.address, new BigNumber(20).mul(precision))
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


        await allocator.addCrowdsales(allocation.address);
        await token.updateLockupAgent(allocation.address,true);
        // await allocation.setVestingStartDate(icoTill)
        await allocation.setAddresses(accounts[6],accounts[7],accounts[8],accounts[9],accounts[5]);

        await  allocation.vestingMint(accounts[0],allocator.address, 1000, icoTill, 31556926,0, 3,{from: accounts[1]})
            .then(Utils.receiptShouldFailed)
            .catch(Utils.catchReceiptShouldFailed);
        await  allocation.vestingMint(accounts[0],allocator.address, 1000, icoTill, 31556926,0, 3,)
            .then(Utils.receiptShouldSucceed)
        let starting = parseInt(new Date().getTime() / 1000) - 1
        await  allocation.vestingMint(accounts[2],allocator.address, 100, starting, 60, 0, 3)
            .then(Utils.receiptShouldSucceed)
        let result = await token.isTransferAllowedAllocation.call(
            accounts[2],
            28,
            starting,
            100
        )
        await assert.equal((result).valueOf(), false, "isTransferAllowed is not equal")
         starting = parseInt(new Date().getTime() / 1000) - 1
        await  allocation.vestingMint(accounts[2],allocator.address, 100, starting, 60, 0, 30)
            .then(Utils.receiptShouldSucceed)
        console.log(await token.lockedAllocationAmount.call(accounts[2],4));
        console.log(await token.lockedAllocationAmount.call(accounts[2],5));
        console.log(await token.lockedAllocationAmount.call(accounts[2],6));
        console.log(await token.lockedAllocationAmount.call(accounts[2],7));

        await allocation.setVestingStartDate(icoSince)
        await allocation.allocate(allocator.address,new BigNumber(20).mul(precision))
            .then(Utils.receiptShouldSucceed)

        console.log('bal',new BigNumber(await token.allowedBalance.call(
            accounts[2],
            starting+33,
            200
        )).valueOf())
        result = await token.isTransferAllowedAllocation.call(
            accounts[2],
            28,
            starting+33,
            200
        )
        await assert.equal((result).valueOf(), true, "isTransferAllowed is not equal")


    });
    it("t", async function () {
        const {
            token,
            allocator,
            contributionForwarder,
            strategy,
            crowdsale,
            agent,
            allocation,
        } = await deploy();
        await token.updateMintingAgent(allocation.address, true);
        await token.updateMintingAgent(allocator.address, true);
        await allocator.addCrowdsales(allocation.address);
        await crowdsale.addSigner(signAddress);
        await allocation.setVestingStartDate(icoSince)
        await makeTransaction(allocation, signAddress, crowdsale.address, accounts[1], [new BigNumber('10').valueOf(),0,0], allocator.address)
            .then(Utils.receiptShouldSucceed);
        await assert.equal(new BigNumber(await allocation.totalSupply.call()).valueOf(),
            new BigNumber('0').mul(precision).valueOf(), 'claimedBalances is not equal');

    })
})