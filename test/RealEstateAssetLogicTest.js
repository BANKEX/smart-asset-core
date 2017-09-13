var SmartAsset = artifacts.require("./SmartAsset.sol");
var RealEstateAssetLogic = artifacts.require("./RealEstateAssetLogic.sol");
var SmartAssetMetadata = artifacts.require("./SmartAssetMetadata.sol");
var BuySmartAsset = artifacts.require("./BuySmartAsset.sol");


contract('RealEstateAssetLogic', function (accounts) {

    it('Should pass flow', async () => {
        const smartAsset = await SmartAsset.deployed();
        const smartAssetMetadata = await SmartAssetMetadata.deployed();
        const realEstateAssetLogic = await RealEstateAssetLogic.deployed();
        const buySmartAsset = await BuySmartAsset.deployed();

        await smartAssetMetadata.addSmartAssetType("real estate", RealEstateAssetLogic.address);
        const result = await smartAsset.createAsset(Date.now(), 200, "docUrl", 3, "email@email1.com", "GOVNUMBER123", "London Private Drive 4", "", 40, "Real Estate");
        const id = await result.logs[0].args.id.c[0];

        var assetObj = await smartAsset.getAssetById(id);
        assert.equal(accounts[0], assetObj[10]);

        await realEstateAssetLogic.updateViaIotSimulator(id, '11,11', '22,22', "/link", { from: accounts[1] });
        await smartAsset.calculateAssetPrice(id);
        const assetPrice = await smartAsset.getSmartAssetPrice(id);

        assert.isAbove(parseInt(assetPrice), 0);
        await smartAsset.makeOnSale(id);

        const totalPrice = await buySmartAsset.getTotalPrice(id, 'Saint-Petersburg');
        assert.isAbove(parseInt(totalPrice), assetPrice);

        await buySmartAsset.buyAsset(id, 'Saint-Petersburg', { from: accounts[1], value: totalPrice });
        assetObj = await smartAsset.getAssetById(id);

        assert.equal(accounts[1], assetObj[10]);
    })
})
