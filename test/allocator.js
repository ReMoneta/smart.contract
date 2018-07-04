const abi = require('ethereumjs-abi')
const utils = require('./utils')
const MintableTokenAllocator = artifacts.require('allocator/MintableTokenAllocator')
const MintableToken = artifacts.require('token/MintableToken')


contract('Allocator', accounts => {

  describe('Base methods on the example of one of the heirs', () => {

    it('should allow to add crowdsale', async () => {
        const owner = accounts[0]
        const token = accounts[1]
        const crowdsale = accounts[2]
        const allocator = await MintableTokenAllocator.new(token, { from: owner})
        await allocator.addCrowdsales(crowdsale, { from: owner}).then(utils.receiptShouldSucceed)
    });

    it('should not allow to add crowdsale', async () => {
        const owner = accounts[0]
        const notOwner = accounts[3]
        const token = accounts[1]
        const crowdsale = accounts[2]
        const allocator = await MintableTokenAllocator.new(token, { from: owner})
        await allocator.addCrowdsales(crowdsale, { from: notOwner}).catch(utils.catchReceiptShouldFailed)
    });

    it('should allow to remove crowdsale', async () => {
        const owner = accounts[0]
        const token = accounts[1]
        const crowdsale = accounts[2]
        const allocator = await MintableTokenAllocator.new(token, { from: owner})
        await allocator.removeCrowdsales(crowdsale, { from: owner}).then(utils.receiptShouldSucceed)
    });

    it('should not allow to remove crowdsale', async () => {
        const owner = accounts[0]
        const notOwner = accounts[3]
        const token = accounts[1]
        const crowdsale = accounts[2]
        const allocator = await MintableTokenAllocator.new(token, { from: owner})
        await allocator.removeCrowdsales(crowdsale, { from: notOwner}).catch(utils.catchReceiptShouldFailed)
    });

    it('should not allow to create instance ', async () => {
        const owner = accounts[0]
        const token = accounts[1]
        const crowdsale = accounts[2]
        const allocator = await MintableTokenAllocator.new(token, { from: owner}).catch(utils.catchReceiptShouldFailed)
    });

  });

  describe('MintableTokenAllocator', () => {

    it('tokens available should return 900', async () => {
        const owner = accounts[0]
        const mintableToken = await MintableToken.new(1000, 100, true, { from: owner})
        const allocator = await MintableTokenAllocator.new(mintableToken.address, { from: owner})
        const res = await allocator.tokensAvailable.call()
        assert.equal(res.valueOf(), 900, "tokens doesn't match");
    });

    it('tokens available should return 0', async () => {
        const owner = accounts[0]
        const mintableToken = await MintableToken.new(100, 100, true, { from: owner})
        const allocator = await MintableTokenAllocator.new(mintableToken.address, { from: owner})
        const res = await allocator.tokensAvailable.call()
        assert.equal(res, 0, "tokens doesn't match");
    });

    it('should allow to allocate', async () => {
        const owner = accounts[0]
        const holder = accounts[1]
        const crowdsale = accounts[2]

        const mintableToken = await MintableToken.new(1000000, 100, true, { from: owner})
        const allocator = await MintableTokenAllocator.new(mintableToken.address, { from: owner})
        await allocator.addCrowdsales(crowdsale, { from: owner}).then(utils.receiptShouldSucceed)
        await mintableToken.updateMintingAgent(allocator.address, true)
        const res = await allocator.allocate(holder, 100, { from: crowdsale}).then(utils.receiptShouldSucceed)
    });

    it('should not allow to allocate because from not crowdsale', async () => {
        const owner = accounts[0]
        const holder = accounts[1]
        const crowdsale = accounts[2]

        const mintableToken = await MintableToken.new(1000000, 100, true, { from: owner})
        const allocator = await MintableTokenAllocator.new(mintableToken.address, { from: owner})
        await mintableToken.updateMintingAgent(crowdsale, true)
        await allocator.addCrowdsales(crowdsale, { from: owner}).then(utils.receiptShouldSucceed)
        const res = await allocator.allocate(holder, 100, { from: owner})
            .then(utils.receiptShouldFailed)
            .catch(utils.catchReceiptShouldFailed)
    });

  });

});