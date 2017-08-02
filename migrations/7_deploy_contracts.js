var SmartAssetMetadata = artifacts.require("./SmartAssetMetadata.sol");

module.exports = function(deployer) {
    deployer.deploy(SmartAssetMetadata);
};
