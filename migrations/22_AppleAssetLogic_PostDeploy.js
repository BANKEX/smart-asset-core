var SmartAssetMetadata = artifacts.require("SmartAssetMetadata.sol");
var SmartAssetRouter = artifacts.require("SmartAssetRouter.sol");
var SmartAsset = artifacts.require("SmartAsset.sol");
var AppleAssetLogic = artifacts.require("AppleAssetLogic.sol");


module.exports = function(deployer, network, accounts) {

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
        })
        .then(function() {
            if(global.isTestNetwork(network)) {
                web3.eth.sendTransaction({from : accounts[0], to : AppleAssetLogic.address, value : 200000000000000000}, function(err){
                    if(err) console.log(err);
                })
            }
        });
};
