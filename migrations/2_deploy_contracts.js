var SmartAsset = artifacts.require("./SmartAsset.sol");
var SmartAssetPrice = artifacts.require("./SmartAssetPrice.sol");
var SmartAssetAvailability = artifacts.require("./SmartAssetAvailability.sol");
var IotSimulation = artifacts.require("./IotSimulation.sol");

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
          return deployer.deploy(SmartAsset, IotSimulation.address, SmartAssetPrice.address);
        });
};
