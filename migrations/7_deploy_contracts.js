var SmartAssetMetadata = artifacts.require("./SmartAssetMetadata.sol");

module.exports = function(deployer) {
    deployer.deploy(SmartAssetMetadata);
    SmartAssetMetadata.deployed().then(function(instance){
                instance.addSmartAssetType("car", CarAssetLogic.address);
            })
};
