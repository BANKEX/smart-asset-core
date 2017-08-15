var IotSimulation = artifacts.require("./IotSimulation.sol");
var SmartAsset = artifacts.require("./SmartAsset.sol");
var CarAssetLogic = artifacts.require("./CarAssetLogic.sol");

contract('IotSimulation', function(accounts) {

     it("Check exception will be thrown in case asset is in step OnSale or after", function() {
          var smartAssetGeneratedId;
          var smartAsset;
          var simulator;

          return SmartAsset.deployed().then(function(instance) {
                  smartAsset = instance;
                  return smartAsset.createAsset(200, "docUrl", 1, "email@email.com", "BMW X5", "VIN01", "yellow", "25000", "car");
              }).then(function(result) {
                  smartAssetGeneratedId = result.logs[0].args.id.c[0];
                  return IotSimulation.deployed();
              })
              .then(function(instance) {
                  simulator = instance;
                  return simulator.generateIotOutput(smartAssetGeneratedId, 0);
              })
              .then(function(result) {
                  return smartAsset.makeOnSale(smartAssetGeneratedId);
              })
              .then(function(result) {
                  return simulator.generateIotOutput(smartAssetGeneratedId, 1);
              })
              .then(function(returnValue) {
                  assert(false, "Throw was expected but didn't.");
              }).catch(function(error) {
                  console.log('Expected error. Got it');
              });
      });

     it("Check exception will be thrown in id is not present", function() {
          return CarAssetLogic.deployed()
              .then(function(instance) {
                  return instance.checkSmartAssetModification(10000);
              })
              .then(function(returnValue) {
                  assert(false, "Throw was expected but didn't.");
              }).catch(function(error) {
                  console.log('Expected error. Got it');
              });
      });
});
