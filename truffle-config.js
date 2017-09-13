var HDWalletProvider = require("truffle-hdwallet-provider");

var mnemonic = "";

module.exports =
{
    networks:
    {
        development:
        {
            host: "localhost",
            port: 8545,
            network_id: "*" // Match any network id
        },
        testnet:
        {
            provider: new HDWalletProvider(mnemonic, "https://ropsten.infura.io/F4WHTukmf2BpFI8UE2L5"),
            network_id: 3
        },
        live: {
            host: 'localhost',
            port: 8545,
            network_id: 1
        }
    },
    mocha:
        {
            reporter: "mocha-junit-reporter",
            reporterOptions:
                {
                    mochaFile: "junit-test-results.xml"
                }
        }
};
