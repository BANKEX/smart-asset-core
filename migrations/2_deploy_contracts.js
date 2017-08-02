var SmartAsset = artifacts.require("./SmartAsset.sol");
var SmartAssetPrice = artifacts.require("./SmartAssetPrice.sol");
var SmartAssetAvailability = artifacts.require("./SmartAssetAvailability.sol");
var IotSimulation = artifacts.require("./IotSimulation.sol");
var CarAssetLogic = artifacts.require("CarAssetLogic");

module.exports = function(deployer) {
    deployer
        .deploy(SmartAssetPrice)
        .then(function() {
            return deployer.deploy(IotSimulation);
        })
        .then(function() {
            return deployer.deploy(SmartAssetAvailability, IotSimulation.address);
        })
        .then(function() {
            return deployer.deploy(SmartAsset, SmartAssetPrice.address);
        })
        .then(function() {
            return deployer.deploy(CarAssetLogic);
        })
        .then(function(carAssetLogic) {
            CarAssetLogic.deployed().then(function(instance) {
                carAssetLogic.setSmartAssetAddr(SmartAsset.address);
                carAssetLogic.setIotSimulationAddr(IotSimulation.address);
            });
            IotSimulation.deployed()
                .then(function(instance) {
                    simulation = instance;
                      return simulation.setSmartAssetAddr(SmartAsset.address);
                })
                .then(function(instance) {
                    return simulation.setSmartAssetAvailabilityAddr(SmartAssetAvailability.address);
                })
                .then(function() {
                    SmartAssetPrice.deployed()
                        .then(function(instance) {
                            return instance.setSmartAssetAddr(SmartAsset.address);
                        });
                });
        });
};
