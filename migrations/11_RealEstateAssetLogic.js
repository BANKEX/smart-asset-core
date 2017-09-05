var RealEstateAssetLogic = artifacts.require("RealEstateAssetLogic.sol");


module.exports = function(deployer) {
    deployer.deploy(RealEstateAssetLogic);
};
