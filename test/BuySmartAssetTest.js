var IotSimulation = artifacts.require("./IotSimulation.sol");
var SmartAsset = artifacts.require("./SmartAsset.sol");
var BuySmartAsset = artifacts.require("./BuySmartAsset.sol");
var CarAssetLogic = artifacts.require("./CarAssetLogic.sol");

contract('BuySmartAsset', function(accounts) {
    it("Should sell asset", function() {
         var smartAssetGeneratedId;
         var expectedAssetTotalPrice;
         var deliveryCity = "Lublin";

         var smartAsset;
         var iotSimulation;
         var buySmartAsset;

         return SmartAsset.deployed().then(function(instance) {
                 smartAsset = instance;
                 return smartAsset.createAsset("BMW X5", "photo_url", "document_url", "car");
             }).then(function(result) {
                 smartAssetGeneratedId = result.logs[0].args.id.c[0];
                 return IotSimulation.deployed();
             })
             .then(function(instance) {
                 iotSimulation = instance;
                 return iotSimulation.generateIotOutput(smartAssetGeneratedId, 0);
             })
             .then(function() {
                return iotSimulation.generateIotAvailability(smartAssetGeneratedId, true);
             })
             .then(function() {
                 return smartAsset.calculateAssetPrice(smartAssetGeneratedId);
             })
             .then(function() {
                 return smartAsset.getSmartAssetPrice(smartAssetGeneratedId);
             })
             .then(function(returnValue) {
                assert.isAbove(parseInt(returnValue), 0, 'price should be bigger than 0');
                return smartAsset.makeOnSale(smartAssetGeneratedId);
             })
             .then(function(result) {
                return smartAsset.getAssetById.call(smartAssetGeneratedId);
             })
             .then(function(returnValue) {
                assert.equal(returnValue[8], 3, 'state should be OnSale = position 3 in State enum list');
                return smartAsset.makeOffSale(smartAssetGeneratedId);
             })
             .then(function(result) {
                return smartAsset.getAssetById.call(smartAssetGeneratedId);
             })
             .then(function(returnValue) {
                assert.equal(returnValue[8], 2, 'state should be PriceCalculated = position 2 in State enum list');
                return smartAsset.makeOnSale(smartAssetGeneratedId);
             })
             .then(function(returnValue) {
                return BuySmartAsset.deployed();
             })
             .then(function(instance) {
                buySmartAsset = instance;
                return buySmartAsset.getTotalPrice.call(smartAssetGeneratedId, deliveryCity);
             }).then(function(calculatedTotalPrice) {
                assert.equal(calculatedTotalPrice, 162526397000006467);
                return buySmartAsset.buyAsset(smartAssetGeneratedId, deliveryCity, {from : accounts[1], value: calculatedTotalPrice});
             }).then(function(returnValue) {
                return smartAsset.getAssetById.call(smartAssetGeneratedId);
             }).then(function(returnValue) {
                assert.equal(returnValue[8], 0, 'state should be ManualDataAreEntered = position 0 in State enum list');
                assert.equal(returnValue[9], accounts[1]);
             });
      });
});
