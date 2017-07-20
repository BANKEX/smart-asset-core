var IotSimulation = artifacts.require("./IotSimulation.sol");
var SmartAsset = artifacts.require("./SmartAsset.sol");

function toAscii(input) {
    return web3.toAscii(input).replace(/\u0000/g, '');
}

contract('IotSimulation', function(accounts) {

    it("Should update params of SmartAsset", function() {
        var smartAssetGeneratedId;
        var smartAsset;
        var simulator;

        SmartAsset.deployed().then(function(instance) {
                smartAsset = instance;
                return smartAsset.createAsset("BMW X5", "photo_url", "document_url");
            }).then(function(result) {
                smartAssetGeneratedId = result.logs[0].args.id.c[0];
                return IotSimulation.deployed();
            })
            .then(function(instance) {
                simulator = instance;
                console.log(SmartAsset.address);
                return simulator.setSmartAssetAddr(SmartAsset.address);
            })
            .then(function(result) {
                console.log("address set up");
                console.log("id =" + smartAssetGeneratedId);
                return simulator.generateIotOutput(smartAssetGeneratedId);
            })
            .then(function(result) {
                return smartAsset.getAssetById.call(smartAssetGeneratedId);
            })
            .then(function(returnValue) {
                assert.equal(returnValue[0], smartAssetGeneratedId);
                assert.equal(toAscii(returnValue[1]), "BMW X5");
                assert.equal(toAscii(returnValue[2]), "photo_url");
                assert.equal(toAscii(returnValue[3]), "document_url");
                assert.isAbove(returnValue[4], 0, 'millage should be bigger than 0');
                assert.isAbove(returnValue[5], 0, 'damage should be bigger than 0');
            });
    });

    it("generateIotOutput have to throw exception if SmartAsset contract address is absent", function() {
        return IotSimulation.deployed().then(function(instance) {
            return instance.generateIotOutput(0);
        }).then(function(returnValue) {
            assert(false, "Throw was expected but didn't.");
        }).catch(function(error) {
            console.log('Expected error. Got it');
        });
    });


    it("generateIotOutput have to throw exception if id is absent", function() {
        return IotSimulation.deployed().then(function(instance) {
                simulator = instance;
                return simulator.setSmartAssetAddr(SmartAsset.address);
            })
            .then(function(result) {
                return simulator.generateIotOutput();
            })
            .then(function(returnValue) {
                assert(false, "Throw was expected but didn't.");
            }).catch(function(error) {
                console.log('Expected error. Got it');
            });
    });

    it("generateIotOutput have to throw exception if id is absent", function() {
        return IotSimulation.deployed().then(function(instance) {
                simulator = instance;
                return simulator.setSmartAssetAddr(SmartAsset.address);
            })
            .then(function(result) {
                return simulator.generateIotOutput(0);
            })
            .then(function(returnValue) {
                assert(false, "Throw was expected but didn't.");
            }).catch(function(error) {
                console.log('Expected error. Got it');
            });
    });

});