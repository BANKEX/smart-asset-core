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


module.exports = function(deployer, network, accounts) {

    var smartAssetMetadata;
    var smartAsset;
    var realEstateAsset;
    var carAssetLogic;

//      SmartAsset linking
    deployer.then(function() {
            return SmartAsset.deployed();
        })
        .then(function(instance) {
            smartAsset = instance;
            return smartAsset.setSmartAssetStorage(SmartAssetStorage.address);
        })
        .then(function() {
            return smartAsset.setBuyAssetAddr(BuySmartAsset.address);
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
//      Logic contracts linking
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
        .then(function(){
            return carAssetLogic.setIotSimulationAddr(IotSimulation.address);
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
            if(network == 'development') {
                return carAssetLogic.setCarAssetLogicStorage(CarAssetLogicStorageMock.address);
            }
            else {
                return carAssetLogic.setCarAssetLogicStorage(CarAssetLogicStorage.address);
            }
        })
        .then(function() {
             return IotSimulation.deployed()
        })
        .then(function(instance){
            return instance.setCarAssetLogicAddr(CarAssetLogic.address);
        })
        .then(function() {
            return RealEstateAssetLogic.deployed();
        })
        .then(function(instance){
            realEstateAsset = instance;
            realEstateAsset.setSmartAssetAddr(SmartAsset.address);
        })
        .then(function(){
             return realEstateAsset.setSmartAssetRouterAddr(SmartAssetRouter.address);
        })
//      Additional contracts
        .then(function(){
            return BKXToken.deployed()
        })
        .then(function(instance){
            return instance.setSmartAssetContract(SmartAsset.address);
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
//      Post deploy steps
        .then(function(){
            return SmartAssetMetadata.deployed()
        })
        .then(function(instance){
            smartAssetMetadata = instance;
            return smartAssetMetadata.addSmartAssetType("car", CarAssetLogic.address);
        })
        .then(function() {
            return smartAssetMetadata.addSmartAssetType('Real Estate', RealEstateAssetLogic.address)
        })
        .then(function() {
            if(global.isTestNetwork(network)) {
                web3.eth.sendTransaction({from : accounts[0], to : CarAssetLogic.address, value : 2000000000000000000}, function(err){
                    if(err) console.log(err);
                })
            }
        })
        .then(function() {
            if(global.isTestNetwork(network)) {
                web3.eth.sendTransaction({from : accounts[0], to : RealEstateAssetLogic.address, value : 2000000000000000000}, function(err){
                    if(err) console.log(err);
                })
            }
        });
};
