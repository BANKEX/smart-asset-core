var SmartAssetMetadata = artifacts.require("./SmartAssetMetadata.sol");

function toAscii(input) {
    return web3.toAscii(input).replace(/\u0000/g, '');
}

contract('SmartAssetMetadata', function (accounts) {
    var assetType = "New Asset Type";
    var smartAssetLogicAddress = '0x586Bfe2c9a8A69727549e92326642301389771B8';

    it("Should add new asset type", async () => {
        const meta = await SmartAssetMetadata.deployed();
        var result = await meta.getAssetTypes();
        const assetTypesInitial = result.length;

        await meta.addSmartAssetType(assetType, smartAssetLogicAddress);

        result = await meta.getAssetTypes();

        assert.equal(assetTypesInitial + 1, result.length);
        assert.equal(assetType, toAscii(result[assetTypesInitial]));
    })

    it("Should update Smart Asset Logic Address", async () => {
        var newSmartAssetLogicAddress = '0xFF7766715a9Ea89007a2Fc6d2c2D7b6909490E25';

        const meta = await SmartAssetMetadata.deployed();
        await meta.addSmartAssetType(assetType, smartAssetLogicAddress);

        var result = await meta.getAssetLogicAddress(assetType);
        assert.equal(smartAssetLogicAddress.toLowerCase(), result);

        await meta.updateAssetLogicAddress(assetType, newSmartAssetLogicAddress);
        result = await meta.getAssetLogicAddress(assetType);

        assert.equal(newSmartAssetLogicAddress.toLowerCase(), result);
    })

    it('should not add asset type that already defined but update the logic address', async () => {
        assetType = 'Not Used Type';
        var newSmartAssetLogicAddress = '0xFF7766715a9Ea89007a2Fc6d2c2D7b6909490E25';
        const meta = await SmartAssetMetadata.deployed();

        var result = await meta.getAssetTypes();
        const assetTypesInitial = result.length;

        await meta.addSmartAssetType(assetType, smartAssetLogicAddress);

        result = await meta.getAssetTypes();
        assert.equal(assetTypesInitial + 1, result.length);

        result = await meta.getAssetLogicAddress(assetType);
        assert.equal(smartAssetLogicAddress.toLowerCase(), result);

        await meta.addSmartAssetType(assetType, newSmartAssetLogicAddress);
        result = await meta.getAssetTypes();
        assert.equal(assetTypesInitial + 1, result.length);

        result = await meta.getAssetLogicAddress(assetType);
        assert.equal(newSmartAssetLogicAddress.toLowerCase(), result);
    })
})
