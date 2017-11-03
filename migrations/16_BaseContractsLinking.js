var SmartAssetRouter = artifacts.require("SmartAssetRouter.sol");
var SmartAsset = artifacts.require("SmartAsset.sol");
var BuySmartAsset = artifacts.require("BuySmartAsset.sol");
var SmartAssetStorage = artifacts.require("SmartAssetStorage.sol");
var SmartAssetRouterStorage = artifacts.require("SmartAssetRouterStorage.sol");
var SmartAssetMetadata = artifacts.require("SmartAssetMetadata.sol");


module.exports = (deployer) => {
    deployer.then(() => {
        return SmartAsset.deployed();
    })
    .then((smartAsset) => {
        return Promise.all([
          smartAsset.setSmartAssetStorage(SmartAssetStorage.address),
          smartAsset.setBuyAssetAddr(BuySmartAsset.address)
        ]);
    })
    .then(() => {
        return SmartAssetStorage.deployed()
    })
    .then((smartAssetStorageInstance) => {
        return smartAssetStorageInstance.setSmartAsset(SmartAsset.address);
    })

    .then(() => {
        return SmartAssetRouter.deployed();
    })
    .then((smartAssetRouter) => {
        return Promise.all([
          smartAssetRouter.setSmartAssetAddress(SmartAsset.address),
          smartAssetRouter.setSmartAssetRouterStorage(SmartAssetRouterStorage.address),
          smartAssetRouter.setSmartAssetMetaAddress(SmartAssetMetadata.address)
        ]);
    })
    .then(() => {
        return SmartAssetRouterStorage.deployed();
    })
    .then((instance) => {
        return instance.setSmartAssetRouterAddress(SmartAssetRouter.address);
    })
}
