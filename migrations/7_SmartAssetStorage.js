var SmartAssetStorage = artifacts.require("SmartAssetStorage.sol");


module.exports = function(deployer, network) {
    global.isTestNetwork(network) ? deployer.deploy(SmartAssetStorage, 1) : deployer.deploy(SmartAssetStorage, 2);
}
