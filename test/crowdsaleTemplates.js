const abi = require('ethereumjs-abi')
const utils = require('./utils')
const BigNumber = require('bignumber.js')

const Crowdsale = artifacts.require('crowdsale/CrowdsaleImpl')
const MintableTokenAllocator = artifacts.require('allocator/MintableTokenAllocator')
const USDDateTiersPricingStrategy = artifacts.require('pricing/USDDateTiersPricingStrategy')
const DistributedDirectContributionForwarder = artifacts.require('contribution/DistributedDirectContributionForwarder')
const MintableCrowdsaleOnSuccessAgent = artifacts.require('test/MintableCrowdsaleOnSuccessAgentTest')
const MintableToken = artifacts.require('MintableToken')


contract('Crowdsale', accounts => {

  const owner = accounts[0];
  const notOwner = accounts[1];
  const externalContributor = accounts[2];
  const notExternalContributor = accounts[3];
  const contributor = accounts[4];
  const totalSupply = 100
  const startDate = 1519862400 // 03/01/2018
  const endDate = 1546214400 // 12/31/2018
  let erc20 = null
  let allocator = null
  let contributionForwarder = null
  let pricingStrategy = null
  let crowdsale = null
    let precision = new BigNumber(1000000000000000000).valueOf(),
        usdPrecision = new BigNumber(100000).valueOf(),
        icoSince = parseInt(new Date().getTime() / 1000 - 3600),
        icoTill = parseInt(new Date().getTime() / 1000) + 3600;

  beforeEach(async () => {
    // create instance and deploy
    erc20 = await MintableToken.new(totalSupply, 0, true, { from: owner})
    allocator = await MintableTokenAllocator.new(erc20.address, { from: owner})
    contributionForwarder = await DistributedDirectContributionForwarder.new(100, [owner], [100]);
    pricingStrategy = await  USDDateTiersPricingStrategy.new(
        [///privateSale
            precision.valueOf(), //     uint256 tokenInUSD;
            0,// uint256 maxTokensCollected;
            50,// uint256 discountPercents;
            5000000000,// uint256 minInvestInUSD;
            icoSince,// uint256 startDate;
            icoTill,// uint256 endDate;
            ///preSale
            precision.valueOf(),
            500,// uint256 maxTokensCollected;
            30,// uint256 discountPercents;
            500000000,// uint256 minInvestInUSD;
            icoTill + 3600,// uint256 startDate;
            icoTill + 3600 * 2,// uint256 endDate;
            ///ICO Tier1
            precision.valueOf(), //     uint256 tokenInUSD;
            0,// uint256 maxTokensCollected;
            25,// uint256 discountPercents;
            100000000,// uint256 minInvestInUSD;
            icoTill + 3600,// uint256 startDate;
            icoTill + 3600 * 2,// uint256 endDate;
            ///ICO Tier2
            precision.valueOf(), //     uint256 tokenInUSD;
            0,// uint256 maxTokensCollected;
            20,// uint256 discountPercents;
            100000000,// uint256 minInvestInUSD;
            icoTill + 3600,// uint256 startDate;
            icoTill + 3600 * 2,// uint256 endDate;
            ///ICO Tier3
            precision.valueOf(), //     uint256 tokenInUSD;
            0,// uint256 maxTokensCollected;
            10,// uint256 discountPercents;
            100000000,// uint256 minInvestInUSD;
            icoTill + 3600,// uint256 startDate;
            icoTill + 3600 * 2,// uint256 endDate;
            ///ICO Tier4
            precision.valueOf(), //     uint256 tokenInUSD;
            0,// uint256 maxTokensCollected;
            0,// uint256 discountPercents;
            100000000,// uint256 minInvestInUSD;
            icoTill + 3600,// uint256 startDate;
            icoTill + 3600 * 2// uint256 endDate;
        ], 18, 75045000
    )
    //  "0xbbf289d846208c16edc8474705c748aff07732db", "0x0dcd2f752394c41875e259e00bb44fd505297caf", "0x5e72914535f202659083db3a02c984188fa26e9f", 1519862400, 1546214400, true, true, true
    crowdsale = await Crowdsale.new(
                  allocator.address,
                  contributionForwarder.address,
                  pricingStrategy.address, startDate, endDate, true, true, true, { from: owner})
      await erc20.updateMintingAgent(allocator.address, true)
  })

    describe('Crowdsale', () => {

      it('should allow to set crowdsale agent', async () => {
        const mintableCA = await MintableCrowdsaleOnSuccessAgent.new(crowdsale.address, erc20.address)
        await crowdsale.setCrowdsaleAgent(mintableCA.address, { from: owner}).then(utils.receiptShouldSucceed)
      })

      it('should not allow to set crowdsale agent', async () => {
        const mintableCA = await MintableCrowdsaleOnSuccessAgent.new(crowdsale.address, erc20.address)
        await crowdsale.setCrowdsaleAgent(mintableCA.address, { from: notOwner}).catch(utils.catchReceiptShouldFailed)
      })

      it('should get current state', async () => {
        // get current state
        // check state dependencies
        await erc20.updateMintingAgent(allocator.address, true)
        const currentState1 = await allocator.isInitialized()
        assert.equal(currentState1, true, "state doesn't match");

        const currentState2 = await contributionForwarder.isInitialized()
        assert.equal(currentState2, true, "state doesn't match");

        const currentState3 = await pricingStrategy.isInitialized()
        assert.equal(currentState3, true, "state doesn't match");


        // check state the crowdsale
        // 3 == InCrowdsale
        const currentState = await crowdsale.getState()
        assert.equal(currentState, 3, "state doesn't match");

        // try to call update state
        await crowdsale.updateState()
        const updatedState = await crowdsale.getState()

        // it shouldn't be changed because nothing changed
        assert.equal(updatedState, 3, "state doesn't match");
      });

      it('should allow to add external contributor crowdsale agent', async () => {
          await crowdsale.addExternalContributor(externalContributor, { from: owner}).then(utils.receiptShouldSucceed)
      });

      it('should not allow to add external contributor crowdsale agent', async () => {
        await crowdsale.addExternalContributor(externalContributor, { from: notOwner}).catch(utils.catchReceiptShouldFailed)
      });

      it('should allow to make external contribution', async () => {
        await crowdsale.addExternalContributor(externalContributor, { from: owner}).then(utils.receiptShouldSucceed)
        await allocator.addCrowdsales(crowdsale.address, { from: owner}).then(utils.receiptShouldSucceed)
        await crowdsale.externalContribution(contributor, 1000, { from: externalContributor, value: web3.toWei('0.000000000001', 'ether')}).then(utils.receiptShouldSucceed)
      });

      it('should not allow to make external contribution', async () => {
        await crowdsale.externalContribution(contributor, 1000, { from: externalContributor}).catch(utils.catchReceiptShouldFailed)
      });

      it('should allow to remove external contributor crowdsale agent', async () => {
        await crowdsale.removeExternalContributor(externalContributor, { from: owner}).then(utils.receiptShouldSucceed)
      });

      it('should not allow to remove external contributor crowdsale agent', async () => {
        await crowdsale.removeExternalContributor(externalContributor, { from: notOwner}).catch(utils.catchReceiptShouldFailed)
      });

      it('should allow to add signer', async () => {
          await crowdsale.addSigner(owner, { from: owner}).then(utils.receiptShouldSucceed)
      });

      it('should not allow to add signer', async () => {
          await crowdsale.addSigner(owner, { from: notOwner}).catch(utils.catchReceiptShouldFailed)
      });

      it('should allow to remove signer', async () => {
          await crowdsale.removeSigner(owner, { from: owner}).then(utils.receiptShouldSucceed)
      });

      it('should not allow to remove signer', async () => {
          await crowdsale.removeSigner(owner, { from: notOwner}).catch(utils.catchReceiptShouldFailed)
      });

      it('should allow to make contribution', async () => {
        await crowdsale.addExternalContributor(externalContributor, { from: owner}).then(utils.receiptShouldSucceed)
        await allocator.addCrowdsales(crowdsale.address, { from: owner}).then(utils.receiptShouldSucceed)
        const signer = accounts[4];
        await crowdsale.addSigner(signer, { from: owner}).then(utils.receiptShouldSucceed)

        const contribution = 1000
        const hash = abi.soliditySHA3(['address', 'address'],[crowdsale.address, contributor])
        const sig = web3.eth.sign(signer, hash.toString('hex')).slice(2)
        const r = `0x${sig.slice(0, 64)}`
        const s = `0x${sig.slice(64, 128)}`
        const v = web3.toDecimal(sig.slice(128, 130)) + 27
        const transactionData = abi.simpleEncode('contribute(uint8,bytes32,bytes32)',v,r,s)
        await crowdsale.sendTransaction(
                {
                  value: web3.toWei('0.000000000001', 'ether'),
                  from: contributor,
                  data: transactionData.toString('hex')
                }).then(utils.receiptShouldSucceed)
      });

      it('should not allow to make contribution because signed by not a signer', async () => {
        await crowdsale.addExternalContributor(externalContributor, { from: owner}).then(utils.receiptShouldSucceed)
        await allocator.addCrowdsales(crowdsale.address, { from: owner}).then(utils.receiptShouldSucceed)

        // not a signer any more
        const signer = accounts[4];
        await crowdsale.removeSigner(signer, { from: owner}).then(utils.receiptShouldSucceed)

        const contribution = 1000
        const hash = abi.soliditySHA3(['address', 'address'],[crowdsale.address, contributor])
        const sig = web3.eth.sign(signer, hash.toString('hex')).slice(2)
        const r = `0x${sig.slice(0, 64)}`
        const s = `0x${sig.slice(64, 128)}`
        const v = web3.toDecimal(sig.slice(128, 130)) + 27
        const transactionData = abi.simpleEncode('contribute(uint8,bytes32,bytes32)',v,r,s)
        await crowdsale.sendTransaction(
                {
                  value: web3.toWei('0.000000000001', 'ether'),
                  from: contributor,
                  data: transactionData.toString('hex')
                }).catch(utils.catchReceiptShouldFailed)
      });

      it('should not allow to make contribution because of broken hash', async () => {
        await crowdsale.addExternalContributor(externalContributor, { from: owner}).then(utils.receiptShouldSucceed)
        await allocator.addCrowdsales(crowdsale.address, { from: owner}).then(utils.receiptShouldSucceed)
        const signer = accounts[4];
        await crowdsale.addSigner(signer, { from: owner}).then(utils.receiptShouldSucceed)

        const contribution = 1000
        const hash = abi.soliditySHA3(['address', 'uint256'],[crowdsale.address, 1000])
        const sig = web3.eth.sign(signer, hash.toString('hex')).slice(2)
        const r = `0x${sig.slice(0, 64)}`
        const s = `0x${sig.slice(64, 128)}`
        const v = web3.toDecimal(sig.slice(128, 130)) + 27
        const transactionData = abi.simpleEncode('contribute(uint8,bytes32,bytes32)',v,r,s)
        await crowdsale.sendTransaction(
                {
                  value: web3.toWei('0.000000000001', 'ether'),
                  from: contributor,
                  data: transactionData.toString('hex')
                }).catch(utils.catchReceiptShouldFailed)
      });

    })
});


