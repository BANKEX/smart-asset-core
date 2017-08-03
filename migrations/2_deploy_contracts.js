var SmartAsset = artifacts.require("./SmartAsset.sol");
var SmartAssetRouter = artifacts.require("./SmartAssetRouter.sol");

var SmartAssetAvailability = artifacts.require("./SmartAssetAvailability.sol");
var IotSimulation = artifacts.require("./IotSimulation.sol");
var SmartAssetMetadata = artifacts.require("./SmartAssetMetadata.sol");

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
            return deployer.deploy(SmartAssetAvailability, IotSimulation.address);
        })
        .then(function() {
            return deployer.deploy(SmartAsset, SmartAssetRouter.address);
        })
        .then(function() {
            IotSimulation.deployed()
                .then(function(instance) {
                    return instance.setSmartAssetAvailabilityAddr(SmartAssetAvailability.address);
                });
        });
};
