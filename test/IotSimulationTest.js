var IotSimulation = artifacts.require("./IotSimulation.sol");
var SmartAsset = artifacts.require("./SmartAsset.sol");
var CarAssetLogic = artifacts.require("./CarAssetLogic.sol");


function toAscii(input) {
    return web3.toAscii(input).replace(/\u0000/g, '');
}

contract('IotSimulation', function(accounts) {

    xit("Should update params of SmartAsset", function() {
        var smartAssetGeneratedId;
        var smartAsset;

        return SmartAsset.deployed()
            .then(function(instance) {
                smartAsset = instance;
                return smartAsset.createAsset(200, "docUrl", 1, "email@email.com", "BMW X5", "VIN01", "yellow", "25000", "car");
            })
            .then(function(result) {
                smartAssetGeneratedId = result.logs[0].args.id.c[0];
                return IotSimulation.deployed();
            })
            .then(function(instance) {
                return instance.generateIotOutput(smartAssetGeneratedId, 0);
            })
            .then(function(result) {
                return smartAsset.getAssetIotById.call(smartAssetGeneratedId);
            })
            .then(function(returnValue) {
                assert.notEqual(toAscii(returnValue[0]), '');
                assert.notEqual(toAscii(returnValue[1]), '');
                assert.notEqual(toAscii(returnValue[2]), '');
                assert.equal(toAscii(returnValue[3]), "car")
            });
    });

    xit("Should update params of SmartAssetAvailability", function() {
        var smartAssetGeneratedId;
        var smartAsset;
        var simulator;
        var smartAssetAvailability;

        return SmartAsset.deployed()
            .then(function(instance) {
                smartAsset = instance;
                return smartAsset.createAsset(200, "docUrl", 1, "email@email.com", "BMW X5", "VIN01", "yellow", "25000", "car");
            })
            .then(function(result) {
                smartAssetGeneratedId = result.logs[0].args.id.c[0];
                return IotSimulation.deployed();
            })
            .then(function(instance) {
                return instance.generateIotAvailability(smartAssetGeneratedId, true);
            })
            .then(function(instance) {
                return smartAsset.getSmartAssetAvailability.call(smartAssetGeneratedId);
            })
            .then(function(returnValue) {
                assert.equal(returnValue, true);
            });
    });

    it("generateIotOutput have to throw exception if id param is absent", function() {
        return IotSimulation.deployed()
            .then(function(instance) {
                return instance.generateIotOutput(0, 0);
            })
            .then(function(returnValue) {
                assert(false, "Throw was expected but didn't.");
            }).catch(function(error) {
                console.log('Expected error. Got it');
            });
    });

    it("generateIotAvailability have to throw exception if id param is absent", function() {
        return IotSimulation.deployed()
            .then(function(instance) {
                return instance.generateIotAvailability(0, true);
            })
            .then(function(returnValue) {
                assert(false, "Throw was expected but didn't.");
            }).catch(function(error) {
                console.log('Expected error. Got it');
            });
    });

    it("generateIotOutput have to throw exception if asset with such id is absent", function() {
        return IotSimulation.deployed()
            .then(function(instance) {
                maxUint32 = 4294967295;
                return instance.generateIotOutput(maxUint32, 0);
            })
            .then(function(returnValue) {
                assert(false, "Throw was expected but didn't.");
            }).catch(function(error) {
                console.log('Expected error. Got it');
            });
    });

    it("generateIotAvailability have to throw exception if asset with such id is absent", function() {
        return IotSimulation.deployed()
            .then(function(instance) {
                maxUint32 = 4294967295;
                return instance.generateIotAvailability(maxUint32, true);
            })
            .then(function(returnValue) {
                assert(false, "Throw was expected but didn't.");
            }).catch(function(error) {
                console.log('Expected error. Got it');
            });
    });
});
