var SmartAsset = artifacts.require("./SmartAsset.sol");
var IotSimulation = artifacts.require("./IotSimulation.sol");

module.exports = function(deployer) {
deployer.deploy(IotSimulation).then(function() {
  return deployer.deploy(SmartAsset, IotSimulation.address);
});

};
