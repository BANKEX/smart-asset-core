var SmartAsset = artifacts.require("./SmartAsset.sol");

var SmartAssetPrice = artifacts.require("./SmartAssetPrice.sol");
var SmartAssetAvailability = artifacts.require("./SmartAssetAvailability.sol");
var DeliveryRequirements = artifacts.require("./DeliveryRequirements.sol");

var BuySmartAsset = artifacts.require("./BuySmartAsset.sol");

module.exports = function(deployer) {
    deployer
    .deploy(DeliveryRequirements, SmartAsset.address)
    .then(function() {
            return deployer.deploy(BuySmartAsset, SmartAssetPrice.address, SmartAssetAvailability.address, DeliveryRequirements.address, SmartAsset.address);
        });
};