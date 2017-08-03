var SmartAsset = artifacts.require("./SmartAsset.sol");
var SmartAssetRouter = artifacts.require("./SmartAssetRouter.sol");
var SmartAssetAvailability = artifacts.require("./SmartAssetAvailability.sol");

var BuySmartAsset = artifacts.require("./BuySmartAsset.sol");

module.exports = function(deployer) {
    deployer
    .deploy(BuySmartAsset, SmartAsset.address, SmartAssetRouter.address)
    .then(function() {
        return SmartAsset.deployed();
	})
	.then(function(instance) {
        instance.setBuyAssetAddr(BuySmartAsset.address);
    });
};
