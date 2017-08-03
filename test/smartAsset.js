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
      return smartAsset.createAsset("BMW X5", "photo_url", "document_url", "car");
    }).then(function(result) {
      smartAssetGeneratedId = result.logs[0].args.id.c[0];
      return smartAsset.getAssetById.call(smartAssetGeneratedId);
    }).then(function(returnValue) {
      console.log(returnValue);
      assert.equal(returnValue[0], smartAssetGeneratedId);
      assert.equal(toAscii(returnValue[1]), "BMW X5");
      assert.equal(toAscii(returnValue[2]), "photo_url");
      assert.equal(toAscii(returnValue[3]), "document_url");
      assert.equal(returnValue[10], accounts[0]);
    });
  });

  it("Should return my assets", function() {
    var smartAsset;
    var initialMyAssetsCount;

    return SmartAsset.deployed().then(function(instance) {
      smartAsset = instance;
      return smartAsset.getMyAssetsCount.call();
    }).then(function(returnValue) {
      initialMyAssetsCount = returnValue;
      return smartAsset.createAsset("Audi A8", "a_photo", "a_document", "car");
    }).then(function(returnValue) {
      return smartAsset.getMyAssetsCount.call();
    }).then(function(returnValue) {
      assert.notEqual(returnValue, initialMyAssetsCount);
      return smartAsset.getMyAssets.call(1, 0);
    }).then(function(returnValue) {
      console.log(returnValue);

      var ids = returnValue[0];
      assert.equal(ids[0], 1);
      assert.equal(ids[1], 2);

      var descriptions = returnValue[1];
      assert.equal(toAscii(descriptions[0]), "BMW X5");
      assert.equal(toAscii(descriptions[1]), "Audi A8");

      var photoUrl = returnValue[2];
      assert.equal(toAscii(photoUrl[0]), "photo_url");
      assert.equal(toAscii(photoUrl[1]), "a_photo");

      var documents = returnValue[3];
      assert.equal(toAscii(documents[0]), "document_url");
      assert.equal(toAscii(documents[1]), "a_document");
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

  it('Should change bkxPrice for transaction', function(done){

      var bkxToken;
      var tokensAmount;
      var smartAsset;
      var newBKXFeeForTransaction = 10;

      SmartAsset.deployed().then(function(instance) {
          smartAsset = instance;
          return smartAsset.setBKXPriceForTransaction(newBKXFeeForTransaction);

      }).then(function(){

          BKXToken.deployed().then(function(instance){
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

  })
});
