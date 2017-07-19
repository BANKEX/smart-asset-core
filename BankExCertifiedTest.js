var BankExCertified = artifacts.require("./BankExCertified.sol");

contract('BankExCertified', function(accounts) {

    it("Should return UnCertified by default", function() {

        return BankExCertified.deployed().then(function(instance) {
            return instance.isCertified.call("0xFF7766715a9Ea89007a2Fc6d2c2D7b6909490E25");

        }).then(function(returnValue) {
            assert.equal(returnValue, false);
        })
    });

    it("Should certify", function() {
        var bankExCertified;

        return BankExCertified.deployed().then(function(instance) {
            bankExCertified = instance;
            return bankExCertified.certify("0xFF7766715a9Ea89007a2Fc6d2c2D7b6909490E25");
        }).then(function(returnValue) {
            return bankExCertified.isCertified.call("0xFF7766715a9Ea89007a2Fc6d2c2D7b6909490E25");
        }).then(function(returnValue) {
            assert.equal(returnValue, true);
        })
    });

    it("Should unCertify", function() {
        var bankExCertified;

        return BankExCertified.deployed().then(function(instance) {
            bankExCertified = instance;
            return bankExCertified.unCertify("0xFF7766715a9Ea89007a2Fc6d2c2D7b6909490E25");
        }).then(function(returnValue) {
            return bankExCertified.isCertified.call("0xFF7766715a9Ea89007a2Fc6d2c2D7b6909490E25");
        }).then(function(returnValue) {
            assert.equal(returnValue, false);
        })
    });

    it("Should throw on certify", function() {

        return BankExCertified.deployed().then(function(instance) {

            return instance.certify("0xFF7766715a9Ea89007a2Fc6d2c2D7b6909490E25", {from : web3.eth.accounts[1]});

        }).catch(function (error) {
            console.log('Expected error. Got it');
        })
    });

    it("Should throw on unCertify", function() {

        return BankExCertified.deployed().then(function(instance) {

            return instance.unCertify("0xFF7766715a9Ea89007a2Fc6d2c2D7b6909490E25", {from : web3.eth.accounts[1]});

        }).catch(function (error) {
            console.log('Expected error. Got it');
        })
    });

});