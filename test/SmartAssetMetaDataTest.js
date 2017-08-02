var SmartAssetMetadata = artifacts.require("./SmartAssetMetadata.sol");

function toAscii(input) {
    return web3.toAscii(input).replace(/\u0000/g, '');
}

contract('SmartAssetMetadata', function(accounts) {

    var meta;
    var assetType = "Car Tokenization";
    var smartAssetAddress = '0x586Bfe2c9a8A69727549e92326642301389771B8';
    var smartAssetLogicAddress = '0x586Bfe2c9a8A69727549e92326642301389771B8';

    it("Should add new asset type", function() {

        return SmartAssetMetadata.deployed().then(function(instance) {

            meta = instance;
            return meta.addSmartAssetType(assetType, smartAssetAddress, smartAssetLogicAddress);

        }).then(function() {
            return meta.getAssetTypes();

        }).then(function(result) {
            assert.equal(1, result.length);
            assert.equal(assetType, toAscii(result[0]));
        })
    });

    it("Should update Smart Asset Logic Address And Smart Asset Address", function() {

        var newSmartAssetLogicAddress = '0xFF7766715a9Ea89007a2Fc6d2c2D7b6909490E25';
        var newSmartAssetAddress = '0xFF7766715a9Ea89007a2Fc6d2c2D7b6909490E25';

        return SmartAssetMetadata.deployed().then(function(instance) {

            meta = instance;
            return meta.addSmartAssetType(assetType, smartAssetAddress, smartAssetLogicAddress);

        }).then(function() {
            return meta.getAssetLogicAddress(assetType);

        }).then(function(result) {
            assert.equal(smartAssetLogicAddress.toLowerCase(), result);

        }).then(function(){
            return meta.getSmartAssetAddress(assetType);

        }).then(function(result){
            assert.equal(smartAssetAddress.toLowerCase(), result);

        }).then(function() {
            meta.updateAssetLogicAddress(assetType, newSmartAssetLogicAddress);

        }).then(function() {
            return meta.getAssetLogicAddress(assetType);

        }).then(function(result) {
            assert.equal(newSmartAssetLogicAddress.toLowerCase(), result);

        }).then(function(){
            meta.updateSmartAssetAddress(assetType, newSmartAssetAddress);

        }).then(function(){
            return meta.getSmartAssetAddress(assetType);

        }).then(function(result) {
            assert.equal(newSmartAssetAddress.toLowerCase(), result);
        })
    });


});
