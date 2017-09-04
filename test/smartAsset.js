var SmartAsset = artifacts.require("./SmartAsset.sol");
var BKXToken = artifacts.require("./BKXToken.sol");

function toAscii(input) {
  return web3.toAscii(input).replace(/\u0000/g, '');
}

contract('SmartAsset', function(accounts) {

  it("Should create asset", function() {
    var smartAsset;
    var smartAssetGeneratedId;
    return SmartAsset.deployed().then(function(instance) {
      smartAsset = instance;
      return smartAsset.createAsset(200, "docUrl", 1, "email@email.com", "BMW X5", "VIN01", "yellow", "25000", "car");
    }).then(function(result) {
      smartAssetGeneratedId = result.logs[0].args.id.c[0];
      return smartAsset.getAssetById.call(smartAssetGeneratedId);
    }).then(function(returnValue) {
      console.log(returnValue);
      assert.equal(returnValue[0], 200);
      assert.equal(toAscii(returnValue[1]), "docUrl");
      assert.equal(returnValue[2], 1);
      assert.equal(toAscii(returnValue[3]), "email@email.com");
      assert.equal(toAscii(returnValue[4]), "BMW X5");
      assert.equal(toAscii(returnValue[5]), "VIN01");
      assert.equal(toAscii(returnValue[6]), "yellow");
      assert.equal(returnValue[7], 25000);
      assert.equal(returnValue[8], 0);
      assert.equal(returnValue[9], accounts[0]);
      assert.equal(toAscii(returnValue[10]), "car");
    });
  });

  it("Should return my assets", function() {
    var smartAsset;
    var initialMyAssetsCarCount;

    return SmartAsset.deployed().then(function(instance) {
      smartAsset = instance;
      return smartAsset.getMyAssetsCount.call("car");
    }).then(function(returnValue) {
      initialMyAssetsCarCount = returnValue;
      return smartAsset.createAsset(200, "docUrl", 1, "email@email1.com", "Audi A8", "VIN02", "black", "2500", "car");
    }).then(function(returnValue) {
      return smartAsset.createAsset(201, "docUrl", 25, "email@email2.com", "notCar", "info", "data", "25", "Notcar");
      })
    .then(function(returnValue) {
      return smartAsset.getMyAssetsCount.call("car");
    }).then(function(returnValue) {
      assert.equal(parseInt(returnValue), parseInt(initialMyAssetsCarCount) +1);
      return smartAsset.getMyAssets.call("car", 0, 1);
    }).then(function(returnValue) {
      console.log(returnValue);

      var ids = returnValue[0];
      assert.equal(ids[0], 1);
      assert.equal(ids[1], 2);

      var b1 = returnValue[3];
      assert.equal(toAscii(b1[0]), "BMW X5");
      assert.equal(toAscii(b1[1]), "Audi A8");

      var b2 = returnValue[4];
      assert.equal(toAscii(b2[0]), "VIN01");
      assert.equal(toAscii(b2[1]), "VIN02");

      var b3 = returnValue[5];
      assert.equal(toAscii(b3[0]), "yellow");
      assert.equal(toAscii(b3[1]), "black");
    });
  });

  it("Should remove asset", function() {
    var smartAsset;

    var assetIdToRemove = 1;

    return SmartAsset.deployed().then(function(instance) {
      smartAsset = instance;
      return smartAsset.removeAsset(assetIdToRemove);
    }).then(function(returnValue) {
      return smartAsset.getAssetById.call(assetIdToRemove);
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
      return instance.getAssetById.call(999);
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

  //skip it due to the logic currently being commented out in SmartAsset contract
  xit('Should change bkxPrice for transaction', function(done) {

      var bkxToken;
      var tokensAmount;
      var smartAsset;
      var newBKXFeeForTransaction = 10;

      SmartAsset.deployed().then(function(instance) {
          smartAsset = instance;
          return smartAsset.setBKXPriceForTransaction(newBKXFeeForTransaction);

      }).then(function(){

          return BKXToken.deployed().then(function(instance){
              bkxToken = instance;
              return bkxToken.balanceOf(web3.eth.accounts[0]);

          }).then(function(result){
              tokensAmount = parseInt(result);

          }).then(function(){
              smartAsset.createAsset('bmw x5', 'photo', 'document', 'car');

          }).then(function() {
              return bkxToken.balanceOf(web3.eth.accounts[0]);

          }).then(function(result){

              assert.equal(parseInt(result), tokensAmount - newBKXFeeForTransaction);
              done();
          })
      })

  });

    it('Should throw error as last index is smaller that first', function() {
        var smartAsset;

        return SmartAsset.deployed().then(function(instance) {
            smartAsset = instance;
            return smartAsset.getMyAssets('car', 1, 0);

        }).catch(function(error) {
            //do nothing
        })
    });

    it('Should throw error as the last index if out of bound', function() {
        var smartAsset;

        return SmartAsset.deployed().then(function(instance) {
            smartAsset = instance;
            return smartAsset.getMyAssets('car', 0, 5);

        }).catch(function(error) {
            //do nothing
        })
    });

    it('Should return assets on sale', function() {
        var smartAsset;
        var smartAssetGeneratedId;

        return SmartAsset.deployed().then(function(instance) {
            smartAsset = instance;
            return smartAsset.createAsset(200, "docUrl", 1, "email@email1.com", "Audi A8", "VIN02", "black", "2500", "car");

        }).then(function(result) {
            smartAssetGeneratedId = result.logs[0].args.id.c[0];

        }).then(function() {
            return smartAsset.calculateAssetPrice(smartAssetGeneratedId);

        }).then(function() {
            return smartAsset.makeOnSale(smartAssetGeneratedId);

        }).then(function(){
            return smartAsset.getAssetsOnSale('car', 0, 0);

        }).then(function(result) {
            var ids = result[0];
            assert.equal(ids[0] , smartAssetGeneratedId);

            var year = result[1];
            assert.equal(year[0], 200);

            var _types = result[2];
            assert.equal(_types[0], 1);

            var vins = result[3];
            assert.equal(toAscii(vins[0]), 'Audi A8');

            var status = result[6];
            assert.equal(status, 3, "Status should be on 3 - OnSale position in the list of states ");
        })

    });

    it('Should search for smart assets', function() {
        var smartAsset;
        var smartAssetGeneratedId;

        return SmartAsset.deployed().then(function(instance) {
            smartAsset = instance;
            return smartAsset.createAsset(200, "docUrl", 1, "email@email1.com", "Audi A8", "VIN02", "black", "2500", "car");

        }).then(function(result) {
            smartAssetGeneratedId = result.logs[0].args.id.c[0];

        }).then(function() {
            return smartAsset.calculateAssetPrice(smartAssetGeneratedId);

        }).then(function() {
            return smartAsset.makeOnSale(smartAssetGeneratedId);

        }).then(function() {
            return smartAsset.createAsset(201, "docUrl", 1, "email@email1.com", "BMW X3", "VIN007", "red", "2500", "car");

        }).then(function(result) {
            smartAssetGeneratedId = result.logs[0].args.id.c[0];

        }).then(function() {
            return smartAsset.calculateAssetPrice(smartAssetGeneratedId);

        }).then(function() {
            return smartAsset.makeOnSale(smartAssetGeneratedId);

        }).then(function() {
            return smartAsset.searchAssetsOnSaleByKeyWord('car', 'BMW X3');

        }).then(function(result){

            assert.equal(1, result[0].length);

            var ids = result[0];

            assert.equal(smartAssetGeneratedId, ids[0]);

        })
    })
});
