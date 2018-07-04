const abi = require('ethereumjs-abi')
const utils = require('./utils')
const BlockLocked = artifacts.require('test/BlockLockedTest')

contract('BlockLocked', accounts => {


  it('should be locked', async () => {
      const block = 10000; // may depends on machine, I think

      const instance = await BlockLocked.new(block, { from: accounts[0]})
      await instance.shouldBeLocked({from: accounts[0]}).then(utils.receiptShouldSucceed)
      await instance.shouldBeUnLocked({from: accounts[0]}).catch(utils.catchReceiptShouldFailed)

  });


  it('should be un locked', async () => {
      const block = 0;
      const instance = await BlockLocked.new(block, { from: accounts[0]})

      await instance.shouldBeUnLocked({from: accounts[0]}).then(utils.receiptShouldSucceed)
      await instance.shouldBeLocked({from: accounts[0]}).catch(utils.catchReceiptShouldFailed)
  });

});
