var BankExCertifiedStorage = artifacts.require("BankExCertifiedStorage.sol");


module.exports = function(deployer) {
    deployer.deploy(BankExCertifiedStorage);
};
