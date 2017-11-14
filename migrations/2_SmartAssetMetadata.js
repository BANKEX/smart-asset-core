var SmartAssetMetadata = artifacts.require("SmartAssetMetadata.sol");


module.exports = (deployer) => {
    deployer.deploy(SmartAssetMetadata);
};
