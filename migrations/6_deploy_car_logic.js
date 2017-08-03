var SmartAsset = artifacts.require("SmartAsset");
var CarAssetLogic = artifacts.require("CarAssetLogic");
var IotSimulation = artifacts.require("IotSimulation");

module.exports = function(deployer) {
    deployer.deploy(CarAssetLogic).then(function(){

        CarAssetLogic.deployed().then(function(instance){
            instance.setSmartAssetAddr(SmartAsset.address);
            instance.setIotSimulationAddr(IotSimulation.address);
        }).then(function() {

            IotSimulation.deployed().then(function(instance){
                instance.setCarAssetLogicAddr(CarAssetLogic.address);
            });
        })
    });
};
