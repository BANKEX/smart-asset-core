var BankExCertified = artifacts.require("./BankExCertified.sol");
var BankExCertifiedStorage = artifacts.require('./BankExCertifiedStorage.sol');

module.exports = function(deployer) {
    deployer.deploy(BankExCertified).then(function() {
        return deployer.deploy(BankExCertifiedStorage);

    }).then(function() {
        return BankExCertified.deployed();

    }).then(function(instance) {
        instance.setStorageAddress(BankExCertifiedStorage.address);

    }).then(function() {
        return BankExCertifiedStorage.deployed();

    }).then(function(instance) {
        instance.setBankExCertifiedAddress(BankExCertified.address);
    });
};
