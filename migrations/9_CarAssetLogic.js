var CarAssetLogic = artifacts.require("CarAssetLogic.sol");


module.exports = (deployer) => {
    deployer.deploy(CarAssetLogic);
}
