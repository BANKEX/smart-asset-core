var CarAssetLogic = artifacts.require("./CarAssetLogic.sol");
var SmartAsset = artifacts.require("./SmartAsset.sol");
var IotSimulation = artifacts.require("./IotSimulation.sol");

contract('CarAssetLogic', function(accounts) {

    var smartAssetId;
    var iotSimulationInstance;

    it("Should return price", function(done) {
        SmartAsset.deployed().then(function(instance){
            return instance.createAsset("Description", "photo//", "document//", "car");
        }).then(function(result) {
            smartAssetId = result.logs[0].args.id.c[0];
            return IotSimulation.deployed();
        }).then(function(instance) {
            return instance.generateIotOutput(smartAssetId, 10);
        }).then(function() {
            return CarAssetLogic.deployed()
        }).then(function(instance){
            return instance.calculateDeliveryPrice(smartAssetId, "Saint-Petersburg")
        }).then(function(result){
            assert.isAbove(result, 0);
            done();
        });
    });

    it('Should add city', function(done) {

        var carAssetLogic;
        var citiesNumber;

        CarAssetLogic.deployed().then(function (instance) {
            carAssetLogic = instance;
            return carAssetLogic.getAvailableCities.call();
        }).then(function(result){
            citiesNumber = result.length;
        }).then(function(){
            return carAssetLogic.addCity('London', 60, 60);
        }).then(function(){
            return carAssetLogic.getAvailableCities.call();
        }).then(function(result) {
            assert.notEqual(citiesNumber, result.length);
            done();
        })

    });


    it('Should not add city', function(done) {

        var carAssetLogic;
        var citiesNumber;

        CarAssetLogic.deployed().then(function (instance) {
            carAssetLogic = instance;
            return carAssetLogic.getAvailableCities.call();
        }).then(function(result){
            citiesNumber = result.length;
        }).then(function(){
            return carAssetLogic.addCity('Moscow', 60, 60);
        }).then(function(){
            return carAssetLogic.getAvailableCities.call();
        }).then(function(result) {
            assert.equal(citiesNumber, result.length);
            done();
        })

    });

    it("Should set coefficient", function(done) {

        var carAssetLogic;
        var priceInitial;
        var coefficientToSet = 2226389; // == (DEFAULT_COEFFICIENT / 10 to the 9th)

        SmartAsset.deployed().then(function(instance){
            return instance.createAsset("Description", "photo//", "document//", "car");
        }).then(function(result) {
            smartAssetId = result.logs[0].args.id.c[0];
            return IotSimulation.deployed();
        }).then(function(instance) {
            instance.generateIotOutput(smartAssetId, 100);
        }).then(function() {
            return CarAssetLogic.deployed()
        }).then(function(instance){
            carAssetLogic = instance;
            return carAssetLogic.calculateDeliveryPrice(smartAssetId, "Saint-Petersburg")
        }).then(function(result){
            priceInitial = result;
        }).then(function() {
            return carAssetLogic.setCoefficientInWei(coefficientToSet);
        }).then(function() {
            return carAssetLogic.calculateDeliveryPrice(smartAssetId, "Saint-Petersburg")
        }).then(function(result){
            assert.equal(priceInitial/Math.pow(10, 9), result);
            done();
        });
    });

});
