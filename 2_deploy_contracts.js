var SmartAsset = artifacts.require("./SmartAsset.sol");

module.exports = function(deployer) {
  deployer.deploy(SmartAsset);
};
