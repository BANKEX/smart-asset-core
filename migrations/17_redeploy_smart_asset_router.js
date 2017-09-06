var SmartAssetRouter = artifacts.require("SmartAssetRouter.sol");
var SmartAssetMetadata = artifacts.require('./SmartAssetMetadata.sol');

module.exports = function(deployer) {
    deployer.deploy(SmartAssetRouter, SmartAssetMetadata.address);
};
