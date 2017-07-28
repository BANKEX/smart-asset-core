var BuySmartAsset = artifacts.require("./BuySmartAsset.sol");

contract('BuySmartAsset', function(accounts) {

    it("Should return total price", function() {
        var buySmartAsset;

        BuySmartAsset.deployed().then(function(instance) {
           console.log("Hello");
           buySmartAsset = instance;
           return buySmartAsset.getTotalPrice(1, "Lublin");
       }).then(function(result) {
           assert.equal(returnValue, 12345);
       });
   });

    /*it("Should buy asset", function() {
        var buySmartAsset;

        BuySmartAsset.deployed().then(function(instance) {
           buySmartAsset = instance;
           return buySmartAsset.buyAsset(1, "Lublin");
       }).then(function(result) {
           assert.equal(returnValue, 12345);
       });
});*/
});