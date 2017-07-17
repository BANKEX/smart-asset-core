var SmartAsset = artifacts.require("./SmartAsset.sol");

function toAscii(input) {
  return web3.toAscii(input).replace(/\u0000/g, '');
}

contract('SmartAsset', function(accounts) {

  it("Should create asset", function() {
    var smartAsset;

    return SmartAsset.deployed().then(function(instance) {
      smartAsset = instance;
      return smartAsset.createAsset("abc", "X5", "BMW", 2011, "Black");
    }).then(function(returnValue) {
      return smartAsset.getAssetByVin.call("abc");
    }).then(function(returnValue) {
      console.log(returnValue);
      assert.equal(toAscii(returnValue[0]), "abc");
      assert.equal(toAscii(returnValue[1]), "X5");
      assert.equal(toAscii(returnValue[2]), "BMW");
      assert.equal(returnValue[3].c, 2011);
      assert.equal(toAscii(returnValue[4]), "Black");
      assert.equal(returnValue[5].c, 0);
    })
  });

  it("Should return my assets", function() {
    var smartAsset;

    return SmartAsset.deployed().then(function(instance) {
      smartAsset = instance;
      return smartAsset.createAsset("second", "A8", "Audi", 2012, "White");
    }).then(function(returnValue) {
      return smartAsset.getMyAssetsCount.call();
    }).then(function(returnValue) {
      assert.equal(returnValue, 2);
      return smartAsset.getMyAssets.call(1, 0);
    }).then(function(returnValue) {
      console.log(returnValue);

      var vins = returnValue[0];
      assert.equal(toAscii(vins[0]), "abc");
      assert.equal(toAscii(vins[1]), "second");

      var models = returnValue[1];
      assert.equal(toAscii(models[0]), "X5");
      assert.equal(toAscii(models[1]), "A8");

      var brands = returnValue[2];
      assert.equal(toAscii(brands[0]), "BMW");
      assert.equal(toAscii(brands[1]), "Audi");

      var years = returnValue[3];
      assert.equal(years[0], 2011);
      assert.equal(years[1], 2012);

      var colors = returnValue[4];
      assert.equal(toAscii(colors[0]), "Black");
      assert.equal(toAscii(colors[1]), "White");
    });
  });

  it("Should remove asset", function() {
    var smartAsset;

    return SmartAsset.deployed().then(function(instance) {
      smartAsset = instance;
      return smartAsset.removeAsset("abc");
    }).then(function(returnValue) {
      return smartAsset.getAssetByVin.call("abc");
    }).then(function(returnValue) {
      assert(false, "Throw was expected but didn't.");
    }).catch(function(error) {
      if(error.toString().indexOf("invalid opcode") != -1) {
        console.log("We were expecting a Solidity throw (aka an invalid opcode), we got one. Test succeeded.");
      } else {
        // if the error is something else (e.g., the assert from previous promise), then we fail the test
        assert(false, error.toString());
      }
    });
  });

  it("getAssetByVin have to throw expection if asset is absent", function() {
    return SmartAsset.deployed().then(function(instance) {
      return instance.getAssetByVin.call("unknown");
    }).then(function(returnValue) {
      assert(false, "Throw was expected but didn't.");
    }).catch(function(error) {
      if(error.toString().indexOf("invalid opcode") != -1) {
        console.log("We were expecting a Solidity throw (aka an invalid opcode), we got one. Test succeeded.");
      } else {
        // if the error is something else (e.g., the assert from previous promise), then we fail the test
        assert(false, error.toString());
      }
    });
  });
});
