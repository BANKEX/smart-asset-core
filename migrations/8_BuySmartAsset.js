var BuySmartAsset = artifacts.require("BuySmartAsset.sol");
var SmartAsset = artifacts.require("SmartAsset.sol");
var SmartAssetRouter = artifacts.require("SmartAssetRouter.sol");


module.exports = function(deployer) {
    deployer.deploy(BuySmartAsset, SmartAsset.address, SmartAssetRouter.address);
}
