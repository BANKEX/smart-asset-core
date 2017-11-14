var IotSimulation = artifacts.require("IotSimulation.sol");


module.exports = (deployer) => {
    deployer.deploy(IotSimulation);
}
