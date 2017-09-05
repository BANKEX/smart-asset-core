var SmartAssetMetadata = artifacts.require("SmartAssetMetadata.sol");
var SmartAssetRouter = artifacts.require("SmartAssetRouter.sol");
var IotSimulation = artifacts.require("IotSimulation.sol");
var SmartAsset = artifacts.require("SmartAsset.sol");
var BuySmartAsset = artifacts.require("BuySmartAsset.sol");
var CarAssetLogic = artifacts.require("CarAssetLogic.sol");
var BKXToken = artifacts.require("BKXToken.sol");
var RealEstateAssetLogic = artifacts.require("RealEstateAssetLogic.sol");
var CarAssetLogicStorage = artifacts.require("CarAssetLogicStorage.sol");
var CarAssetLogicStorageMock = artifacts.require("CarAssetLogicStorageMock.sol");
var SmartAssetStorage = artifacts.require("SmartAssetStorage.sol");
var BankExCertified = artifacts.require("./BankExCertified.sol");
var BankExCertifiedStorage = artifacts.require('./BankExCertifiedStorage.sol');


module.exports = function(deployer, network) {

    var smartAssetMetadata;

    deployer.then(function() {
            return SmartAsset.deployed();
        })
        .then(function(smartAssetInstance) {
            return smartAssetInstance.setSmartAssetStorage(SmartAssetStorage.address);
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
            return smartAssetRouter.setSmartAssetAddress(SmartAsset.address);
        })
        .then(function() {
            return SmartAsset.deployed();
        })
        .then(function(smartAsset) {
            return smartAsset.setBuyAssetAddr(BuySmartAsset.address);
        })
        .then(function(){
             return CarAssetLogic.deployed();
        })
        .then(function(instance){
             return instance.setSmartAssetAddr(SmartAsset.address);
        })
        .then(function(){
            return CarAssetLogic.deployed();
        })
        .then(function(instance){
             return instance.setSmartAssetRouterAddr(SmartAssetRouter.address);
        })
        .then(function(){
            return CarAssetLogic.deployed();
        })
        .then(function(instance){
            return instance.setIotSimulationAddr(IotSimulation.address);
        })
        .then(function() {
            if(network == 'development') {
                return CarAssetLogicStorageMock.deployed();
            }
            else {
                return CarAssetLogicStorage.deployed();
            }
        })
        .then(function(instance){
            return instance.setCarAssetLogic(CarAssetLogic.address);
        })
        .then(function() {
            return CarAssetLogic.deployed();
        })
        .then(function(instance) {
            if(network == 'development') {
                return instance.setCarAssetLogicStorage(CarAssetLogicStorageMock.address);
            }
            else {
                return instance.setCarAssetLogicStorage(CarAssetLogicStorage.address);
            }
        })
        .then(function() {
             return IotSimulation.deployed()
        })
        .then(function(instance){
            return instance.setCarAssetLogicAddr(CarAssetLogic.address);
        })

        .then(function(){
            return SmartAssetMetadata.deployed()
        })
        .then(function(instance){
            smartAssetMetadata = instance;
            return smartAssetMetadata.addSmartAssetType("car", CarAssetLogic.address);
        })
        .then(function(){
            return BKXToken.deployed()
        })
        .then(function(instance){
            return instance.setSmartAssetContract(SmartAsset.address);
        })
        .then(function() {
            return SmartAsset.deployed();
        })
        .then(function(instance){
            return instance.setBKXTokenAddress(BKXToken.address);
        })
        .then(function() {
            return RealEstateAssetLogic.deployed();
        })
        .then(function(instance){
            return instance.setSmartAssetAddr(SmartAsset.address);
        })
        .then(function(){
            return RealEstateAssetLogic.deployed();
        })
        .then(function(instance){
             return instance.setSmartAssetRouterAddr(SmartAssetRouter.address);
        })
        .then(function() {
            return BankExCertified.deployed();
        }).then(function(instance) {
            return instance.setStorageAddress(BankExCertifiedStorage.address);
        }).then(function() {
            return BankExCertifiedStorage.deployed();
        }).then(function(instance) {
            return instance.setBankExCertifiedAddress(BankExCertified.address);
        })
        .then(function() {
            return smartAssetMetadata.addSmartAssetType('Real Estate', RealEstateAssetLogic.address)
        })
    ;

};
