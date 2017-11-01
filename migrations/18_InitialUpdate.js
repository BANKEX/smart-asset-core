var CarAssetLogic = artifacts.require("CarAssetLogic.sol");
var RealEstateAssetLogic = artifacts.require("RealEstateAssetLogic.sol");
var AppleAssetLogic = artifacts.require("AppleAssetLogic.sol");
var SmartAssetMetadata = artifacts.require("SmartAssetMetadata.sol");


module.exports = function(deployer, network, accounts) {
    deployer.then(function() {
            return SmartAssetMetadata.deployed()
        })
        .then(function(smartAssetMetadata){
            return Promise.all([
              smartAssetMetadata.addSmartAssetType("car", CarAssetLogic.address),
              smartAssetMetadata.addSmartAssetType('Real Estate', RealEstateAssetLogic.address),
              smartAssetMetadata.addSmartAssetType('apple', AppleAssetLogic.address)
            ]);
        })
        .then(function() {
            if(global.isTestNetwork(network)) {
                web3.eth.sendTransaction({from : accounts[0], to : CarAssetLogic.address, value : 200000000000000000}, function(err){
                    if(err) console.log(err);
                })
            }
        })
        .then(function() {
            if(global.isTestNetwork(network)) {
                web3.eth.sendTransaction({from : accounts[0], to : RealEstateAssetLogic.address, value : 200000000000000000}, function(err){
                    if(err) console.log(err);
                })
            }
        })
        .then(function() {
            if(global.isTestNetwork(network)) {
                web3.eth.sendTransaction({from : accounts[0], to : AppleAssetLogic.address, value : 200000000000000000}, function(err){
                    if(err) console.log(err);
                })
            }
        })
}
