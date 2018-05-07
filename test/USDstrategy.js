var
    USDDateTiersPricingStrategy = artifacts.require("./pricing/USDDateTiersPricingStrategy.sol"),
    Utils = require("./utils"),
    BigNumber = require('BigNumber.js'),
    precision = new BigNumber("1000000000000000000"),
    usdPrecision = new BigNumber("100000"),
    icoSince = parseInt(new Date().getTime() / 1000 - 3600),
    icoTill = parseInt(new Date().getTime() / 1000) + 3600;

contract('USDDateTiersPricingStrategy', function (accounts) {
    let strategy;

    beforeEach(async function () {
        strategy = await  USDDateTiersPricingStrategy.new(
            [///privateSale
                new BigNumber('1').mul(precision).valueOf(), //     uint256 tokenInUSD;
                0,// uint256 maxTokensCollected;
                50,// uint256 discountPercents;
                5000000000,// uint256 minInvestInUSD;
                icoSince,// uint256 startDate;
                icoTill,// uint256 endDate;
                ///preSale
                new BigNumber('1').mul(precision).valueOf(), //     uint256 tokenInUSD;
                500,// uint256 maxTokensCollected;
                30,// uint256 discountPercents;
                500000000,// uint256 minInvestInUSD;
                icoTill + 3600,// uint256 startDate;
                icoTill + 3600 * 2,// uint256 endDate;
                ///ICO Tier1
                new BigNumber('1').mul(precision).valueOf(), //     uint256 tokenInUSD;
                0,// uint256 maxTokensCollected;
                25,// uint256 discountPercents;
                100000000,// uint256 minInvestInUSD;
                icoTill + 3600,// uint256 startDate;
                icoTill + 3600 * 2,// uint256 endDate;
                ///ICO Tier2
                new BigNumber('1').mul(precision).valueOf(), //     uint256 tokenInUSD;
                0,// uint256 maxTokensCollected;
                20,// uint256 discountPercents;
                100000000,// uint256 minInvestInUSD;
                icoTill + 3600,// uint256 startDate;
                icoTill + 3600 * 2,// uint256 endDate;
                ///ICO Tier3
                new BigNumber('1').mul(precision).valueOf(), //     uint256 tokenInUSD;
                0,// uint256 maxTokensCollected;
                10,// uint256 discountPercents;
                100000000,// uint256 minInvestInUSD;
                icoTill + 3600,// uint256 startDate;
                icoTill + 3600 * 2,// uint256 endDate;
                ///ICO Tier4
                new BigNumber('1').mul(precision).valueOf(), //     uint256 tokenInUSD;
                0,// uint256 maxTokensCollected;
                0,// uint256 discountPercents;
                100000000,// uint256 minInvestInUSD;
                icoTill + 3600,// uint256 startDate;
                icoTill + 3600 * 2// uint256 endDate;
            ], 18, 75045000
        )
    });
    it('check getTierIndex returns  properly index', async function () {
        let id = await strategy.getTierIndex.call(0);
        await assert.equal(new BigNumber(id).valueOf(), 0, "getTierIndex is not equal")
        await strategy.updateDates(0, icoSince-5, icoSince)
        await strategy.updateDates(1, icoSince, icoTill)
         id = await strategy.getTierIndex.call(0);
        await assert.equal(new BigNumber(id).valueOf(), 1, "getTierIndex is not equal")
         id = await strategy.getTierIndex.call(499);
        await assert.equal(new BigNumber(id).valueOf(), 1, "getTierIndex is not equal")
        id = await strategy.getTierIndex.call(400);
        await assert.equal(new BigNumber(id).valueOf(), 1, "getTierIndex is not equal")
        id = await strategy.getTierIndex.call(501);
        await assert.equal(new BigNumber(id).valueOf(), 6, "getTierIndex is not equal")
    });
    it('check getActualDates', async function () {
        let dates =  await strategy.getActualDates(0)
        await assert.equal(new BigNumber(dates[0]).valueOf(), icoSince, "strat is not equal")
        await assert.equal(new BigNumber(dates[1]).valueOf(), icoTill, "end is not equal")
        await strategy.updateDates(0, icoSince-5, icoSince)
        await strategy.updateDates(1, icoSince, icoTill)
       let id = await strategy.getTierIndex.call(500);
        await assert.equal(new BigNumber(id).valueOf(), 6, "getTierIndex is not equal")
        dates =  await strategy.getActualDates(500)
        await assert.equal(new BigNumber(dates[0]).valueOf(), icoTill + 3600, "strat is not equal")
        await assert.equal(new BigNumber(dates[1]).valueOf(), icoTill + 3600 * 2, "end is not equal")
        await strategy.updateDates(0, icoSince-5, icoSince)
        await strategy.updateDates(1, icoSince-5, icoSince)
        await strategy.updateDates(2, icoSince-5, icoSince)
        await strategy.updateDates(3, icoSince-5, icoSince)
        await strategy.updateDates(4, icoSince-5, icoSince)
        await strategy.updateDates(5, icoSince-5, icoSince)
        dates =  await strategy.getActualDates(0)
        await assert.equal(new BigNumber(dates[0]).valueOf(), icoSince-5, "strat is not equal")
        await assert.equal(new BigNumber(dates[1]).valueOf(), icoSince, "end is not equal")
    });
    describe('check getTokens', async function () {
        it('zero weis  should return zero tokens', async function () {
            let tokens = await strategy.getTokens(accounts[0], 5000000, 0, 0, 0)
            await assert.equal(new BigNumber(tokens[0]).valueOf(), 0, "tokens is not equal")
            await assert.equal(new BigNumber(tokens[1]).valueOf(), 0, "tokensExcludingBonus is not equal")
            await assert.equal(new BigNumber(tokens[2]).valueOf(), 0, "bonus is not equal")

        });
        it('less than  min purchase', async function () {
            let tokens = await strategy.getTokens(
                accounts[0],
                new BigNumber(5000000).mul(precision),
                0,
                new BigNumber('1').mul(precision).valueOf(),
                0
            )
            await assert.equal(new BigNumber(tokens[0]).valueOf(), 0, "tokens is not equal")
            await assert.equal(new BigNumber(tokens[1]).valueOf(), 0, "tokensExcludingBonus is not equal")
            await assert.equal(new BigNumber(tokens[2]).valueOf(), 0, "bonus is not equal")
            tokens = await strategy.getTokens(
                accounts[0],
                new BigNumber(1125675000000000000000).mul(precision),
                0,
                new BigNumber('67').mul(precision).valueOf(),
                0
            )
            await assert.equal(new BigNumber(tokens[0]).valueOf(),
                new BigNumber('75420.225').mul(precision).valueOf(), "tokens is not equal")
            await assert.equal(new BigNumber(tokens[1]).valueOf(),
                new BigNumber('75420.225').mul(precision).valueOf(), "tokensExcludingBonus is not equal")
            await assert.equal(new BigNumber(tokens[2]).valueOf(), 0, "bonus is not equal")
        });
        it('before sale period ', async function () {
            await strategy.updateDates(0, icoSince-5, icoSince)
            await strategy.updateDates(1, icoSince-5, icoSince)
            await strategy.updateDates(2, icoSince-5, icoSince)
            await strategy.updateDates(3, icoSince-5, icoSince)
            await strategy.updateDates(4, icoSince-5, icoSince)
            await strategy.updateDates(5, icoSince-5, icoSince)
            let tokens = await strategy.getTokens(
                accounts[0],
                new BigNumber(1125675000000000000000).mul(precision),
                0,
                new BigNumber('67').mul(precision).valueOf(),
                0
            )
            await assert.equal(new BigNumber(tokens[0]).valueOf(), 0, "tokens is not equal")
            await assert.equal(new BigNumber(tokens[1]).valueOf(), 0, "tokensExcludingBonus is not equal")
            await assert.equal(new BigNumber(tokens[2]).valueOf(), 0, "bonus is not equal")
        });
        it('outdated', async function () {
            await strategy.updateDates(0, icoTill-5, icoTill)
            await strategy.updateDates(1, icoTill-5, icoTill)
            await strategy.updateDates(2, icoTill-5, icoTill)
            await strategy.updateDates(3, icoTill-5, icoTill)
            await strategy.updateDates(4, icoTill-5, icoTill)
            await strategy.updateDates(5, icoTill-5, icoTill)
            let tokens = await strategy.getTokens(
                accounts[0],
                new BigNumber(1125675000000000000000).mul(precision),
                0,
                new BigNumber('67').mul(precision).valueOf(),
                0
            )
            await assert.equal(new BigNumber(tokens[0]).valueOf(), 0, "tokens is not equal")
            await assert.equal(new BigNumber(tokens[1]).valueOf(), 0, "tokensExcludingBonus is not equal")
            await assert.equal(new BigNumber(tokens[2]).valueOf(), 0, "bonus is not equal")
        });
        it('tokens less than available', async function () {
           let tokens = await strategy.getTokens(
                accounts[0],
                new BigNumber('75420.225').mul(precision),
                0,
                new BigNumber('67').mul(precision).valueOf(),
                0
            )
            await assert.equal(new BigNumber(tokens[0]).valueOf(),
                new BigNumber('75420.225').mul(precision).valueOf(), "tokens is not equal")
            await assert.equal(new BigNumber(tokens[1]).valueOf(),
                new BigNumber('75420.225').mul(precision).valueOf(), "tokensExcludingBonus is not equal")
            await assert.equal(new BigNumber(tokens[2]).valueOf(), 0, "bonus is not equal")

            tokens = await strategy.getTokens(
                accounts[0],
                new BigNumber('75420.225').mul(precision),
                0,
                new BigNumber('68').mul(precision).valueOf(),
                0
            )
            await assert.equal(new BigNumber(tokens[0]).valueOf(),0, "tokens is not equal")
            await assert.equal(new BigNumber(tokens[1]).valueOf(),0, "tokensExcludingBonus is not equal")
            await assert.equal(new BigNumber(tokens[2]).valueOf(), 0, "bonus is not equal")
        });
        it('success for each  tier', async function () {
            let tokens = await strategy.getTokens(
                accounts[0],
                new BigNumber('75420.225').mul(precision),
                0,
                new BigNumber('67').mul(precision).valueOf(),
                0
            )
            await assert.equal(new BigNumber(tokens[0]).valueOf(),
                new BigNumber('75420.225').mul(precision).valueOf(), "tokens is not equal")
            await assert.equal(new BigNumber(tokens[1]).valueOf(),
                new BigNumber('75420.225').mul(precision).valueOf(), "tokensExcludingBonus is not equal")
            await assert.equal(new BigNumber(tokens[2]).valueOf(), 0, "bonus is not equal")

            await strategy.updateDates(0, icoSince-5, icoSince)
            await strategy.updateDates(1, icoSince-5, icoSince)
            await strategy.updateDates(2, icoSince, icoTill)
            tokens = await strategy.getTokens(
                accounts[0],
                new BigNumber('75420.225').mul(precision),
                0,
                new BigNumber('1.5').mul(precision).valueOf(),
                0
            )
          //  ((1.5*75045000)*1*1.25)/10^5
            await assert.equal(new BigNumber(tokens[0]).valueOf(),
                new BigNumber('1407.09375').mul(precision).valueOf(), "tokens is not equal")
            await assert.equal(new BigNumber(tokens[1]).valueOf(),
                new BigNumber('1407.09375').mul(precision).valueOf(), "tokensExcludingBonus is not equal")
            await assert.equal(new BigNumber(tokens[2]).valueOf(), 0, "bonus is not equal")
        });
    });
    describe('check getWeis', async function () {
        it('zero tokens should return zero weis', async function () {
            let tokens = await strategy.getWeis(0, 0, 0)
            await assert.equal(new BigNumber(tokens[0]).valueOf(), 0, "totalWeiAmount is not equal")
            await assert.equal(new BigNumber(tokens[1]).valueOf(), 0, "tokensBonus is not equal")

        });
        it('less than  min purchase', async function () {
            let tokens = await strategy.getWeis(0, 0,  new BigNumber('75420.225').mul(precision).valueOf())
            await assert.equal(new BigNumber(tokens[0]).valueOf(),  new BigNumber('100.5').mul(precision).valueOf(), "totalWeiAmount is not equal")
            await assert.equal(new BigNumber(tokens[1]).valueOf(),  new BigNumber('37710.1125').mul(precision).valueOf(), "tokensBonus is not equal")
            tokens = await strategy.getWeis(0, 0,  new BigNumber('754.225').mul(precision).valueOf())
            await assert.equal(new BigNumber(tokens[0]).valueOf(),  new BigNumber('0').mul(precision).valueOf(), "totalWeiAmount is not equal")
            await assert.equal(new BigNumber(tokens[1]).valueOf(),  new BigNumber('0').mul(precision).valueOf(), "tokensBonus is not equal")
        });
        it('outdated', async function () {
            await strategy.updateDates(0, icoTill-5, icoTill)
            await strategy.updateDates(1, icoTill-5, icoTill)
            await strategy.updateDates(2, icoTill-5, icoTill)
            await strategy.updateDates(3, icoTill-5, icoTill)
            await strategy.updateDates(4, icoTill-5, icoTill)
            await strategy.updateDates(5, icoTill-5, icoTill)
            let tokens = await strategy.getWeis(0, 0,  new BigNumber('75420.225').mul(precision).valueOf())
            await assert.equal(new BigNumber(tokens[0]).valueOf(),  new BigNumber('0').mul(precision).valueOf(), "totalWeiAmount is not equal")
            await assert.equal(new BigNumber(tokens[1]).valueOf(),  new BigNumber('0').mul(precision).valueOf(), "tokensBonus is not equal")
        });
        it('before sale period', async function () {
            await strategy.updateDates(0, icoSince-5, icoSince)
            await strategy.updateDates(1, icoSince-5, icoSince)
            await strategy.updateDates(2, icoSince-5, icoSince)
            await strategy.updateDates(3, icoSince-5, icoSince)
            await strategy.updateDates(4, icoSince-5, icoSince)
            await strategy.updateDates(5, icoSince-5, icoSince)
            let tokens = await strategy.getWeis(0, 0,  new BigNumber('75420.225').mul(precision).valueOf())
            await assert.equal(new BigNumber(tokens[0]).valueOf(),  new BigNumber('0').mul(precision).valueOf(), "totalWeiAmount is not equal")
            await assert.equal(new BigNumber(tokens[1]).valueOf(),  new BigNumber('0').mul(precision).valueOf(), "tokensBonus is not equal")
        });
        it('tokens less than available', async function () {
            await strategy.updateDates(0, icoSince-5, icoSince)
            await strategy.updateDates(1, icoSince, icoTill)
            let id = await strategy.getTierIndex.call(500);
            await assert.equal(new BigNumber(id).valueOf(), 6, "getTierIndex is not equal")
           //@todo
        });
        it('success for each  tier', async function () {
            //todo
        });
    });
    it('updateDates - changes the start and end dates', async function () {
            //done in prev tests
    });
    describe('check that METHODS could be called only by owner', async function () {
        it('updateDates', async function () {
            await strategy.updateDates(0, icoSince - 5, icoSince)
                .then(Utils.receiptShouldSucceed)
            await strategy.updateDates(0, icoSince - 5, icoSince, {from: accounts[2]})
                .then(Utils.receiptShouldFailed)
                .catch(Utils.catchReceiptShouldFailed);
        });
    });
});