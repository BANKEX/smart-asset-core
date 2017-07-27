var IotSimulation = artifacts.require("./IotSimulation.sol");
var SmartAsset = artifacts.require("./SmartAsset.sol");
var SmartAssetPrice = artifacts.require("./SmartAssetPrice.sol");
var SmartAssetAvailability = artifacts.require("./SmartAssetAvailability.sol");

function toAscii(input) {
    return web3.toAscii(input).replace(/\u0000/g, '');
}

contract('IotSimulation', function(accounts) {

    it("Should update params of SmartAsset", function() {
        var smartAssetGeneratedId;
        var smartAsset;
        var simulator;

        SmartAsset.deployed()
            .then(function(instance) {
                smartAsset = instance;
                return smartAsset.createAsset("BMW X5", "photo_url", "document_url");
            })
            .then(function(result) {
                smartAssetGeneratedId = result.logs[0].args.id.c[0];
                return IotSimulation.deployed();
            })
            .then(function(instance) {
                simulator = instance;
                return simulator.setSmartAssetAddr(SmartAsset.address);
            })
            .then(function() {
                return SmartAssetPrice.deployed();
            })
            .then(function(instance) {
                return instance.setSmartAssetAddr(SmartAsset.address);
            })
            .then(function(result) {
                return simulator.generateIotOutput(smartAssetGeneratedId, 0);
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
                assert.isAbove(returnValue[6], 0, 'latitude should be bigger than 0');
                assert.isAbove(returnValue[7], 0, 'longitude should be bigger than 0');

                assert.equal(returnValue[9], 1, 'state should be SensorDataAreCollected = position 1 in State enum list');
            });
    });

    it("Should update params of SmartAssetAvailability", function() {
        var smartAssetGeneratedId;
        var smartAsset;
        var simulator;
        var smartAssetAvailability;

        SmartAsset.deployed()
            .then(function(instance) {
                smartAsset = instance;
                return smartAsset.createAsset("BMW X5", "photo_url", "document_url");
            })
            .then(function(result) {
                smartAssetGeneratedId = result.logs[0].args.id.c[0];
                return IotSimulation.deployed();
            })
            .then(function(instance) {
                simulator = instance;
                return SmartAssetAvailability.deployed(IotSimulation.address);
            })
            .then(function(instance) {
                smartAssetAvailability = instance;
                return simulator.setSmartAssetAvailabilityAddr(SmartAssetAvailability.address);
            })
            .then(function(result) {
                return simulator.generateIotAvailability(smartAssetGeneratedId, true);
            })
            .then(function(result) {
                return smartAssetAvailability.getSmartAssetAvailability.call(smartAssetGeneratedId);
            })
            .then(function(returnValue) {
                assert.equal(returnValue, true);
            });
    });

    it("generateIotOutput have to throw exception if SmartAsset contract address is absent", function() {
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

    it("generateIotAvailability have to throw exception if SmartAssetAvailability contract address is absent", function() {
        return IotSimulation.deployed()
        .then(function(instance) {
            return instance.generateIotAvailability(0, 0);
        })
        .then(function(returnValue) {
            assert(false, "Throw was expected but didn't.");
        }).catch(function(error) {
            console.log('Expected error. Got it');
        });
    });

    it("generateIotOutput have to throw exception if id param is absent", function() {
        return IotSimulation.deployed()
            .then(function(instance) {
                simulator = instance;
                return simulator.setSmartAssetAddr(SmartAsset.address);
            })
            .then(function(result) {
                return simulator.generateIotOutput(0, 0);
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
                simulator = instance;
                return simulator.setSmartAssetAvailabilityAddr(SmartAssetAvailability.address);
            })
            .then(function(result) {
                return simulator.generateIotAvailability(0, true);
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
                simulator = instance;
                return simulator.setSmartAssetAddr(SmartAsset.address);
            })
            .then(function(result) {
                maxUint32 = 4294967295;
                return simulator.generateIotOutput(maxUint32, 0);
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
                simulator = instance;
                return simulator.setSmartAssetAvailabilityAddr(SmartAssetAvailability.address);
            })
            .then(function(result) {
                maxUint32 = 4294967295;
                return simulator.generateIotAvailability(maxUint32, true);
            })
            .then(function(returnValue) {
                assert(false, "Throw was expected but didn't.");
            }).catch(function(error) {
                console.log('Expected error. Got it');
            });
    });

});