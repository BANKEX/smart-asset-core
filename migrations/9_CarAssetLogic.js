var CarAssetLogic = artifacts.require("CarAssetLogic.sol");


module.exports = function(deployer) {
    deployer.deploy(CarAssetLogic);
}
