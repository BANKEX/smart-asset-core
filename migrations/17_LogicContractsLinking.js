var SmartAssetRouter = artifacts.require("SmartAssetRouter.sol");
var SmartAsset = artifacts.require("SmartAsset.sol");
var CarAssetLogic = artifacts.require("CarAssetLogic.sol");
var RealEstateAssetLogic = artifacts.require("RealEstateAssetLogic.sol");
var AppleAssetLogic = artifacts.require("AppleAssetLogic.sol");
var IotSimulation = artifacts.require("IotSimulation.sol");


module.exports = function(deployer) {
    deployer.then(function() {
            return CarAssetLogic.deployed();
        })
        .then(function(carAssetLogic){
            return Promise.all([
              carAssetLogic.setSmartAssetAddr(SmartAsset.address),
              carAssetLogic.setSmartAssetRouterAddr(SmartAssetRouter.address),
              carAssetLogic.setIotSimulationAddr(IotSimulation.address)
            ]);
        })
        .then(function() {
             return IotSimulation.deployed()
        })
        .then(function(iotSimulation){
            return iotSimulation.setCarAssetLogicAddr(CarAssetLogic.address);
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
        .then(function() {
            return AppleAssetLogic.deployed();
        })
        .then(function(appleAsset){
            return Promise.all([
              appleAsset.setSmartAssetAddr(SmartAsset.address),
              appleAsset.setSmartAssetRouterAddr(SmartAssetRouter.address)
            ]);
        })
}
