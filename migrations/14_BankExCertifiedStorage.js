var BankExCertifiedStorage = artifacts.require("BankExCertifiedStorage.sol");
var BankExCertified = artifacts.require("BankExCertified.sol");


module.exports = (deployer) => {
    deployer.deploy(BankExCertifiedStorage)
        .then(() => {
            return BankExCertifiedStorage.deployed();
        }).then((bankExCertifiedStorage) => {
            return bankExCertifiedStorage.setBankExCertifiedAddress(BankExCertified.address);
        }).then(() => {
            return BankExCertified.deployed();
        }).then((bankExCertified) => {
            return bankExCertified.setStorageAddress(BankExCertifiedStorage.address);
        })
}
