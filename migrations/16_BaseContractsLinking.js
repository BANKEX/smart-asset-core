var SmartAssetRouter = artifacts.require("SmartAssetRouter.sol");
var SmartAsset = artifacts.require("SmartAsset.sol");
var BuySmartAsset = artifacts.require("BuySmartAsset.sol");
var SmartAssetStorage = artifacts.require("SmartAssetStorage.sol");
var SmartAssetRouterStorage = artifacts.require("SmartAssetRouterStorage.sol");
var SmartAssetMetadata = artifacts.require("SmartAssetMetadata.sol");


module.exports = function(deployer) {
    deployer.then(function() {
        return SmartAsset.deployed();
    })
    .then(function(smartAsset) {
        return Promise.all([
          smartAsset.setSmartAssetStorage(SmartAssetStorage.address),
          smartAsset.setBuyAssetAddr(BuySmartAsset.address)
        ]);
    })
    .then(function() {
        return SmartAssetStorage.deployed()
    })
    .then(function(smartAssetStorageInstance) {
        return smartAssetStorageInstance.setSmartAsset(SmartAsset.address);
    })

    .then(function() {
        return SmartAssetRouter.deployed();
    })
    .then(function(smartAssetRouter) {
        return Promise.all([
          smartAssetRouter.setSmartAssetAddress(SmartAsset.address),
          smartAssetRouter.setSmartAssetRouterStorage(SmartAssetRouterStorage.address),
          smartAssetRouter.setSmartAssetMetaAddress(SmartAssetMetadata.address)
        ]);
    })
    .then(function(){
        return SmartAssetRouterStorage.deployed();
    })
    .then(function(instance){
        return instance.setSmartAssetRouterAddress(SmartAssetRouter.address);
    })
}
