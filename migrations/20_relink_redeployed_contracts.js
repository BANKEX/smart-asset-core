var SmartAssetMetadata = artifacts.require("SmartAssetMetadata.sol");
var SmartAssetRouter = artifacts.require("SmartAssetRouter.sol");
var SmartAsset = artifacts.require("SmartAsset.sol");
var BuySmartAsset = artifacts.require("BuySmartAsset.sol");
var BKXToken = artifacts.require("BKXToken.sol");
var CarAssetLogic = artifacts.require("CarAssetLogic.sol");
var RealEstateAssetLogic = artifacts.require("RealEstateAssetLogic.sol");
var SmartAssetStorage = artifacts.require("SmartAssetStorage.sol");
var SmartAssetRouterStorage = artifacts.require("SmartAssetRouterStorage.sol");

module.exports = function(deployer, network) {
    deployer.then(function() {
        return SmartAsset.deployed();
    })
        .then(function(smartAsset) {
            return Promise.all([
              smartAsset.setSmartAssetStorage(SmartAssetStorage.address),
              smartAsset.setBuyAssetAddr(BuySmartAsset.address),
              smartAsset.setBKXTokenAddress(BKXToken.address)
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
              smartAssetRouter.setSmartAssetRouterStorage(SmartAssetRouterStorage.address)
            ]);
        })

        .then(function(){
            return SmartAssetRouterStorage.deployed();
        })
        .then(function(instance){
            return instance.setSmartAssetRouterAddress(SmartAssetRouter.address);
        })

        .then(function(){
            return CarAssetLogic.deployed();
        })
        .then(function(carAssetLogic){
            return Promise.all([
              carAssetLogic.setSmartAssetAddr(SmartAsset.address),
              carAssetLogic.setSmartAssetRouterAddr(SmartAssetRouter.address)
            ]);

        })

        .then(function() {
            return RealEstateAssetLogic.deployed();
        })
        .then(function(realEstateAsset){
            return Promise.all([
              realEstateAsset.setSmartAssetAddr(SmartAsset.address),
              realEstateAsset.setSmartAssetRouterAddr(SmartAssetRouter.address)
            ]);
        })

        .then(function(){
            return BKXToken.deployed()
        })
        .then(function(instance){
            return instance.setSmartAssetContract(SmartAsset.address);
        })
};
