var BKXToken = artifacts.require("./BKXToken.sol");
var SmartAsset = artifacts.require("./SmartAsset.sol");


contract('BKXToken', function(accounts) {

    var bkxToken;
    var initialAmountBKX = 3000000;
    var amountToDeductForAssetCreation = 1;


    it('Should burn BKX', function(done) {
        BKXToken.deployed().then(function(instance){
            bkxToken = instance;
            return bkxToken.balanceOf(web3.eth.accounts[0]);

        }).then(function(result){
            assert.equal(initialAmountBKX, parseInt(result));

        }).then(function(){
            return SmartAsset.deployed();

        }).then(function(instance){
            instance.createAsset('bmw x5', 'photo', 'document')

        }).then(function(){
            return bkxToken.balanceOf(web3.eth.accounts[0]);

        }).then(function(result){

            assert.equal(initialAmountBKX,  parseInt(result) + amountToDeductForAssetCreation);
            done();
        })

    })

});
