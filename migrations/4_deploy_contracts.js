var SmartAsset = artifacts.require("./SmartAsset.sol");
var DeliveryRequirements = artifacts.require("./DeliveryRequirements.sol");

module.exports = function(deployer) {
    deployer.deploy(DeliveryRequirements, SmartAsset.address);
};