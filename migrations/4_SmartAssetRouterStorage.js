var SmartAssetRouterStorage = artifacts.require("SmartAssetRouterStorage.sol");


module.exports = (deployer) => {
    deployer.deploy(SmartAssetRouterStorage);
}
