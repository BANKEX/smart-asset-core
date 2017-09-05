var BKXToken = artifacts.require("BKXToken.sol");


module.exports = function(deployer) {
    deployer.deploy(BKXToken);
};
