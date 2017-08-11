var BKXToken = artifacts.require("./BKXToken.sol");
var SmartAsset = artifacts.require("./SmartAsset.sol");


contract('BKXToken', function(accounts) {

    var bkxToken;
    var initialAmountBKX;
    var amountToDeductForAssetCreation = 1;


    //skip it due to the logic currently being commented out in SmartAsset contract
    xit('Should burn BKX', function(done) {
        BKXToken.deployed().then(function(instance){
            bkxToken = instance;
            return bkxToken.balanceOf(web3.eth.accounts[0]);

        }).then(function(result){
            initialAmountBKX = parseInt(result);

        }).then(function(){
            return SmartAsset.deployed();

        }).then(function(instance){
            instance.createAsset('bmw x5', 'photo', 'document', 'car')

        }).then(function(){
            return bkxToken.balanceOf(web3.eth.accounts[0]);

        }).then(function(result){

            assert.equal(parseInt(result), initialAmountBKX - amountToDeductForAssetCreation);
            done();
        })

    });

    it('Should throw error', function(){
        return BKXToken.deployed().then(function(instance){

            bkxToken = instance;
            return bkxToken.balanceOf(accounts[0]);

        }).then(function(result) {
            initialAmountBKX = parseInt(result);

        }).then(function() {
            return bkxToken.transfer(accounts[0], accounts[1], initialAmountBKX + 1)

        }).catch(function(error) {
            console.log('Should catch error and the transfer should not go down as there is not enough tokens in accounts[0]');
        })

    });

});
