var BankExCertified = artifacts.require("BankExCertified.sol");


module.exports = function(deployer) {
    deployer.deploy(BankExCertified);
};
