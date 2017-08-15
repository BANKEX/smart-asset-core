var SmartAsset = artifacts.require("./SmartAsset.sol");
var RealEstateAssetLogic = artifacts.require("./RealEstateAssetLogic.sol");
var SmartAssetMetadata = artifacts.require("./SmartAssetMetadata.sol");
var BuySmartAsset = artifacts.require("./BuySmartAsset.sol");


contract('RealEstateAssetLogic', function(accounts) {

    it('Should pass flow', function() {

        var id;
        var realEstateAssetLogic;
        var smartAsset;
        var buySmartAsset;


        return SmartAssetMetadata.deployed().then(function(instance) {
           return instance.addSmartAssetType("real estate", RealEstateAssetLogic.address);

        }).then(function(){
            return SmartAsset.deployed();

        }).then(function(instance) {
            smartAsset = instance;
            return smartAsset.createAsset(Date.now(), "docUrl", 3, "email@email1.com", "GOVNUMBER123", "London Private Drive 4", "", "40", "Real Estate");

        }).then(function(result){
            id = result.logs[0].args.id.c[0];

        }).then(function() {
            return smartAsset.getAssetById(id);

        }).then(function(result) {
            assert.equal(accounts[0], result[9]);


        }).then(function() {
            return RealEstateAssetLogic.deployed()

        }).then(function(instance){
            realEstateAssetLogic = instance;
            return realEstateAssetLogic.updateViaIotSimulator(id, 10, 10, false, 5, 5, {from : accounts[1]});


        }).then(function() {
             return smartAsset.calculateAssetPrice(id);

        }).then(function() {
            return smartAsset.getSmartAssetPrice(id);

        }).then(function(result) {
            assert.equal(40000, parseInt(result));

            return smartAsset.makeOnSale(id);


        }).then(function() {
            return BuySmartAsset.deployed();

        }).then(function (instance) {
            buySmartAsset = instance;
            return buySmartAsset.getTotalPrice(id, 'Saint-Petersburg');

        }).then(function(result) {
            assert.equal(40010, parseInt(result));
            return buySmartAsset.buyAsset(id, 'Saint-Petersburg', {from : accounts[1], value: 40010});

        }).then(function() {
            return smartAsset.getAssetById(id);

        }).then(function(result) {
            assert.equal(accounts[1], result[9]);

        });
    })

});
