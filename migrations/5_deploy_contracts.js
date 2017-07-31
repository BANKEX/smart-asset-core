var BKXToken = artifacts.require("./BKXToken.sol");
var SmartAsset = artifacts.require("./SmartAsset.sol");

module.exports = function(deployer) {
    deployer.deploy(BKXToken).then(function(){

        BKXToken.deployed().then(function(instance){
            instance.setSmartAssetContract(SmartAsset.address);

        }).then(function() {

            SmartAsset.deployed().then(function(instance){
                instance.setBKXTokenAddress(BKXToken.address);
            })
        })
    });
};
