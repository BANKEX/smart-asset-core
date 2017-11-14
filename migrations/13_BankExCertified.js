var BankExCertified = artifacts.require("BankExCertified.sol");


module.exports = (deployer) => {
    deployer.deploy(BankExCertified);
}
