var SmartAssetMetadata = artifacts.require('./SmartAssetMetadata.sol');
var CarAssetLogic = artifacts.require('./CarAssetLogic.sol');
var RealEstateAssetLogic = artifacts.require('./RealEstateAssetLogic.sol');
var AppleAssetLogic = artifacts.require('./AppleAssetLogic.sol');

module.exports = function(deployer) {

    deployer.deploy(SmartAssetMetadata)

        .then(function(){
            return SmartAssetMetadata.deployed();
        })
        .then(function(instance) {
            instance.addSmartAssetType("car", CarAssetLogic.address);
            instance.addSmartAssetType('Real Estate', RealEstateAssetLogic.address);
        });
};
