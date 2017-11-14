var AppleAssetLogic = artifacts.require("AppleAssetLogic.sol");


module.exports = (deployer) => {
    deployer.deploy(AppleAssetLogic);
}
