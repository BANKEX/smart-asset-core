var RealEstateAssetLogic = artifacts.require("RealEstateAssetLogic.sol");


module.exports = (deployer) => {
    deployer.deploy(RealEstateAssetLogic);
}
