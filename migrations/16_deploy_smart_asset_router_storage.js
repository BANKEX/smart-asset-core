var SmartAssetRouterStorage = artifacts.require("SmartAssetRouterStorage.sol");

module.exports = function(deployer) {
    deployer.deploy(SmartAssetRouterStorage);

};
