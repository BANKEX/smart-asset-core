var IotSimulation = artifacts.require("./IotSimulation.sol");
var SmartAsset = artifacts.require("./SmartAsset.sol");
var SmartAssetPrice = artifacts.require("./SmartAssetPrice.sol");


function toAscii(input) {
    return web3.toAscii(input).replace(/\u0000/g, '');
}

contract('IotSimulation', function(accounts) {

    it("Check that price is calculated after IoT simulation step", function() {
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
                 return simulator.setSmartAssetAddr(SmartAsset.address);
             })
             .then(function() {
                 return SmartAssetPrice.deployed();
             })
             .then(function(instance) {
                 smartAssetPrice = instance;
                 return smartAssetPrice.setSmartAssetAddr(SmartAsset.address);
             })
             .then(function(result) {
                 return simulator.generateIotOutput(smartAssetGeneratedId, 0);
             })
             .then(function(result) {
                 return smartAssetPrice.getSmartAssetPrice(smartAssetGeneratedId);
             })
             .then(function(returnValue) {
                assert.isAbove(returnValue, 0, 'price should be bigger than 0');
             })
             .then(function(result) {
                 return smartAsset.getAssetById.call(smartAssetGeneratedId);
             })
             .then(function(returnValue) {
                 assert.equal(returnValue[7], 1, 'state should be PriceFromFormula1IsCalculated = position 1 in State enum list');
             });
     });
});