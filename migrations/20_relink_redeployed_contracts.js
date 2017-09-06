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

    var smartAsset;
    var carAssetLogic;
    var realEstateAsset;
    var smartAssetRouter;

    deployer.then(function() {
        return SmartAsset.deployed();
    })
        .then(function(instance) {
            smartAsset = instance;
            return smartAsset.setSmartAssetStorage(SmartAssetStorage.address);
        })
        .then(function(){
            return smartAsset.setBuyAssetAddr(BuySmartAsset.address);
        })
        .then(function() {
            return smartAsset.setBKXTokenAddress(BKXToken.address);
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
        .then(function(instance) {
            smartAssetRouter = instance;
            return smartAssetRouter.setSmartAssetAddress(SmartAsset.address);
        })
        .then(function(){
            return smartAssetRouter.setSmartAssetRouterStorage(SmartAssetRouterStorage.address);
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
        .then(function(instance){
            carAssetLogic = instance;
            return carAssetLogic.setSmartAssetAddr(SmartAsset.address);
        })
        .then(function(){
            return carAssetLogic.setSmartAssetRouterAddr(SmartAssetRouter.address);
        })
        .then(function() {
            return RealEstateAssetLogic.deployed();
        })
        .then(function(instance){
            realEstateAsset = instance;
            return realEstateAsset.setSmartAssetAddr(SmartAsset.address);
        })
        .then(function(){
            return realEstateAsset.setSmartAssetRouterAddr(SmartAssetRouter.address);
        })
        .then(function(){
            return BKXToken.deployed()
        })
        .then(function(instance){
            return instance.setSmartAssetContract(SmartAsset.address);
        })



};
