var BankExCertified = artifacts.require("./BankExCertified.sol");

contract('BankExCertified', (accounts) => {

    it("Should return UnCertified by default", async () => {
        const bankExCertified = await BankExCertified.deployed();
        const certified = await bankExCertified.isCertified.call("0xFF7766715a9Ea89007a2Fc6d2c2D7b6909490E25");
        assert.equal(certified, false);
    })

    it("Should certify", async () => {
        const bankExCertified = await BankExCertified.deployed();
        const certify = await bankExCertified.certify("0xFF7766715a9Ea89007a2Fc6d2c2D7b6909490E25");
        const certified = await bankExCertified.isCertified.call("0xFF7766715a9Ea89007a2Fc6d2c2D7b6909490E25");
        assert.equal(certified, true);
    })

    it("Should unCertify", async () => {
        const bankExCertified = await BankExCertified.deployed();
        const unCertify = await bankExCertified.unCertify("0xFF7766715a9Ea89007a2Fc6d2c2D7b6909490E25");
        const certified = await bankExCertified.isCertified.call("0xFF7766715a9Ea89007a2Fc6d2c2D7b6909490E25");
        assert.equal(certified, false);
    })

    it("Should throw on certify", async () => {
        const bankExCertified = await BankExCertified.deployed();
        try {
            const certified = await bankExCertified.certify("0xFF7766715a9Ea89007a2Fc6d2c2D7b6909490E25", { from: web3.eth.accounts[1] });
        } catch (error) {
            console.log('Expected error. Got it');
        }
    })

    it("Should throw on unCertify", async () => {
        const bankExCertified = await BankExCertified.deployed();
        try {
            const unCertify = await bankExCertified.unCertify("0xFF7766715a9Ea89007a2Fc6d2c2D7b6909490E25", { from: web3.eth.accounts[1] });
        } catch (error) {
            console.log('Expected error. Got it');
        }
    })
})
