var SmartAssetMetadata = artifacts.require("./SmartAssetMetadata.sol");
var CarAssetLogic = artifacts.require("./CarAssetLogic.sol");

module.exports = function(deployer) {
    SmartAssetMetadata.deployed().then(function(instance){
                instance.addSmartAssetType("car", CarAssetLogic.address);
            })
};
