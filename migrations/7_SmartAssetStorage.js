var SmartAssetStorage = artifacts.require("SmartAssetStorage.sol");


module.exports = function(deployer) {
    deployer.deploy(SmartAssetStorage);
}
