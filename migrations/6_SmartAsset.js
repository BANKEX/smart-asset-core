var SmartAsset = artifacts.require("SmartAsset.sol");
var SmartAssetMetadata = artifacts.require("SmartAssetMetadata.sol");
var SmartAssetRouter = artifacts.require("SmartAssetRouter.sol");


module.exports = (deployer) => {
    deployer.deploy(SmartAsset, SmartAssetRouter.address, SmartAssetMetadata.address);
}
