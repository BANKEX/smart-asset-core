var IotSimulation = artifacts.require("./IotSimulation.sol");
var SmartAsset = artifacts.require("./SmartAsset.sol");

function toAscii(input) {
    return web3.toAscii(input).replace(/\u0000/g, '');
}

contract('IotSimulation', function(accounts) {

    it("Simulation of IoT change data. Should change status to FailedAssetModified", function() {
         var smartAssetGeneratedId;
         var smartAsset;
         var simulator;

         return SmartAsset.deployed().then(function(instance) {
                 smartAsset = instance;
                 return smartAsset.createAsset("BMW X5", "photo_url", "document_url", "car");
             }).then(function(result) {
                 smartAssetGeneratedId = result.logs[0].args.id.c[0];
                 return IotSimulation.deployed();
             })
             .then(function(instance) {
                 simulator = instance;
                 return simulator.generateIotOutput(smartAssetGeneratedId, 0);
             })
             .then(function(result) {
                 return simulator.generateIotOutput(smartAssetGeneratedId, 1921);
             })
             .then(function(result) {
                 return smartAsset.getAssetById.call(smartAssetGeneratedId);
             })
             .then(function(returnValue) {
                assert.equal(toAscii(returnValue[0]), "BMW X5");
                assert.equal(toAscii(returnValue[1]), "photo_url");
                assert.equal(toAscii(returnValue[2]), "document_url");
                assert.isAbove(returnValue[3], 0, 'millage should be bigger than 0');
                assert.isAbove(returnValue[4], 0, 'damage should be bigger than 0');
                assert.isAbove(returnValue[5], 0, 'latitude should be bigger than 0');
                assert.isAbove(returnValue[6], 0, 'longitude should be bigger than 0');

                assert.equal(toAscii(returnValue[10]), "car");
             });
     });
});
