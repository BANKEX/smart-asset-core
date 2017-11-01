var BankExCertifiedStorage = artifacts.require("BankExCertifiedStorage.sol");
var BankExCertified = artifacts.require("BankExCertified.sol");


module.exports = function(deployer) {
    deployer.deploy(BankExCertifiedStorage)
        .then(function() {
            return BankExCertifiedStorage.deployed();
        }).then(function(bankExCertifiedStorage) {
            return bankExCertifiedStorage.setBankExCertifiedAddress(BankExCertified.address);
        }).then(function() {
            return BankExCertified.deployed();
        }).then(function(bankExCertified) {
            return bankExCertified.setStorageAddress(BankExCertifiedStorage.address);
        })
}
