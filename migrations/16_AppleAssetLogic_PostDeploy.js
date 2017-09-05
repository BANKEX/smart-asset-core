var SmartAssetMetadata = artifacts.require("SmartAssetMetadata.sol");
var SmartAssetRouter = artifacts.require("SmartAssetRouter.sol");
var SmartAsset = artifacts.require("SmartAsset.sol");
var AppleAssetLogic = artifacts.require("AppleAssetLogic.sol");


module.exports = function(deployer, network) {

    var appleAsset;

    deployer.then(function() {
            return AppleAssetLogic.deployed();
        })
        .then(function(instance){
            appleAsset = instance;
            appleAsset.setSmartAssetAddr(SmartAsset.address);
        })
        .then(function(){
             return appleAsset.setSmartAssetRouterAddr(SmartAssetRouter.address);
        })
        .then(function(){
            return SmartAssetMetadata.deployed()
        })
        .then(function(instance) {
            return instance.addSmartAssetType('apple', AppleAssetLogic.address)
        });
};
