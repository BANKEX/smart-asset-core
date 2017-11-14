var IotSimulation = artifacts.require("./IotSimulation.sol");
var SmartAsset = artifacts.require("./SmartAsset.sol");
var BuySmartAsset = artifacts.require("./BuySmartAsset.sol");

var BigInt = require('big-integer');

contract('BuySmartAsset', (accounts) => {

    it("Should sell asset", async () => {
        var deliveryCity = "Lublin";

        var extra = 1000; //
        var gasPrice = 100000000000;


        const smartAsset = await SmartAsset.deployed();
        const iotSimulation = await IotSimulation.deployed();
        const buySmartAsset = await BuySmartAsset.deployed()

        const result = await smartAsset.createAsset(Date.now(), 200, "docUrl", 1, "email@email1.com", "Audi A8", "VIN02", "black", "2500", "car");
        const smartAssetGeneratedId = result.logs[0].args.id.c[0];

        await iotSimulation.generateIotOutput(smartAssetGeneratedId, 0);
        await iotSimulation.generateIotAvailability(smartAssetGeneratedId, true);
        await smartAsset.calculateAssetPrice(smartAssetGeneratedId);

        const assetObjPrice = await smartAsset.getSmartAssetPrice(smartAssetGeneratedId);
        assert.isAbove(parseInt(assetObjPrice), 0, 'price should be bigger than 0');

        await smartAsset.makeOnSale(smartAssetGeneratedId);

        var assetObj = await smartAsset.getAssetById.call(smartAssetGeneratedId);
        assert.equal(assetObj[9], 3, 'state should be OnSale = position 3 in State enum list');

        await smartAsset.makeOffSale(smartAssetGeneratedId);
        assetObj = await smartAsset.getAssetById.call(smartAssetGeneratedId);
        assert.equal(assetObj[9], 2, 'state should be PriceCalculated = position 2 in State enum list');

        await smartAsset.makeOnSale(smartAssetGeneratedId);

        const calculatedTotalPrice = await buySmartAsset.getTotalPrice.call(smartAssetGeneratedId, '112', '223');
        await buySmartAsset.buyAsset(smartAssetGeneratedId, '112', '223', { from: accounts[1], value: BigInt(calculatedTotalPrice.toString()).add(BigInt(extra)) });

        assetObj = await smartAsset.getAssetById.call(smartAssetGeneratedId);
        assert.equal(assetObj[9], 0, 'state should be ManualDataAreEntered = position 0 in State enum list');
        assert.equal(assetObj[10], accounts[1]);

        const balanceBeforeWithdrawal = await web3.eth.getBalance(accounts[1]);
        const gas = await buySmartAsset.withdrawPayments.estimateGas({ from: accounts[1] });
        await buySmartAsset.withdrawPayments({ from: accounts[1], gasPrice: gasPrice });

        const balanceAfterWithdrawal = await web3.eth.getBalance(accounts[1]);

        var totalGas = gas * gasPrice;

        assert.isOk((BigInt(balanceAfterWithdrawal.toString()).add(BigInt(totalGas))).eq(BigInt(balanceBeforeWithdrawal.toString()).add(BigInt(extra))));
    })
})
