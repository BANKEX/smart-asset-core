var SmartAssetMetadata = artifacts.require("SmartAssetMetadata.sol");
var SmartAssetRouter = artifacts.require("SmartAssetRouter.sol");
var IotSimulation = artifacts.require("IotSimulation.sol");
var SmartAsset = artifacts.require("SmartAsset.sol");
var BuySmartAsset = artifacts.require("BuySmartAsset.sol");
var CarAssetLogic = artifacts.require("CarAssetLogic.sol");
var BKXToken = artifacts.require("BKXToken.sol");


module.exports = function(deployer) {
    deployer
        .deploy(SmartAssetMetadata)
        .then(function() {
            return deployer.deploy(SmartAssetRouter, SmartAssetMetadata.address);
        })
        .then(function() {
            return deployer.deploy(IotSimulation);
        })
        .then(function() {
            return deployer.deploy(SmartAsset, SmartAssetRouter.address, SmartAssetMetadata.address);
        })

        .then(function() {
            return SmartAssetRouter.deployed();
        })
        .then(function(smartAssetRouter) {
            return smartAssetRouter.setSmartAssetAddress(SmartAsset.address);
        })

        .then(function() {
            return IotSimulation.deployed();
        })

        .then(function() {
             return deployer.deploy(BuySmartAsset, SmartAsset.address, SmartAssetRouter.address)
        })

        .then(function() {
            return SmartAsset.deployed();
        })
        .then(function(smartAsset) {
            return smartAsset.setBuyAssetAddr(BuySmartAsset.address);
        })


        .then(function() {
            return deployer.deploy(CarAssetLogic)
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
            return instance.setIotSimulationAddr(IotSimulation.address);
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
            return instance.addSmartAssetType("car", CarAssetLogic.address);
        })

        .then(function(){
            return deployer.deploy(BKXToken)
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
        });
};
