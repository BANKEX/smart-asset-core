var DeliveryRequirements = artifacts.require("./DeliveryRequirements.sol");
var SmartAsset = artifacts.require("./SmartAsset.sol");
var IotSimulation = artifacts.require("./IotSimulation.sol");
var SmartAssetPrice = artifacts.require("./SmartAssetPrice.sol");


contract('DeliveryRequirements', function(accounts) {

    var smartAssetId;
    var iotSimulationInstance;

    it("Should return price", function(done) {

        SmartAsset.deployed().then(function(instance){
            return instance.createAsset("Description", "photo//", "document//");

        }).then(function(result) {
            smartAssetId = result.logs[0].args.id.c[0];

            return IotSimulation.deployed();

        }).then(function(instance) {
            instance.generateIotOutput(smartAssetId, 10);

        }).then(function() {
            return DeliveryRequirements.deployed()

        }).then(function(instance){
            return instance.calculatePrice(smartAssetId, "Saint-Petersburg")

        }).then(function(result){
            assert.isAbove(result, 0);
            done();
        });
    });

    it('Should add city', function(done) {

        var deliveryRequirements;
        var citiesNumber;

        DeliveryRequirements.deployed().then(function (instance) {
            deliveryRequirements = instance;
            return deliveryRequirements.getAvailableCities.call();

        }).then(function(result){
            citiesNumber = result.length;

        }).then(function(){
            deliveryRequirements.addCity('London', 60, 60);

        }).then(function(){
            return deliveryRequirements.getAvailableCities.call();

        }).then(function(result) {
            assert.notEqual(citiesNumber, result.length);
            done();
        })

    });


    it('Should not add city', function(done) {

        var deliveryRequirements;
        var citiesNumber;

        DeliveryRequirements.deployed().then(function (instance) {
            deliveryRequirements = instance;
            return deliveryRequirements.getAvailableCities.call();

        }).then(function(result){
            citiesNumber = result.length;

        }).then(function(){
            deliveryRequirements.addCity('Moscow', 60, 60);

        }).then(function(){
            return deliveryRequirements.getAvailableCities.call();

        }).then(function(result) {
            assert.equal(citiesNumber, result.length);
            done();
        })

    });

    it("Should set coefficient", function(done) {

        var deliveryRequirement;
        var priceInitial;
        var coefficientToSet = 2226389; // == (DEFAULT_COEFFICIENT / 10 to the 9th)

        SmartAsset.deployed().then(function(instance){
            return instance.createAsset("Description", "photo//", "document//");

        }).then(function(result) {
            smartAssetId = result.logs[0].args.id.c[0];

            return IotSimulation.deployed();
        }).then(function(instance) {
            instance.generateIotOutput(smartAssetId, 100);

        }).then(function() {
            return DeliveryRequirements.deployed()

        }).then(function(instance){

            deliveryRequirement = instance;
            return deliveryRequirement.calculatePrice(smartAssetId, "Saint-Petersburg")

        }).then(function(result){
            priceInitial = result;

        }).then(function() {
            deliveryRequirement.setCoefficientInWei(coefficientToSet);

        }).then(function() {
            return deliveryRequirement.calculatePrice(smartAssetId, "Saint-Petersburg")

        }).then(function(result){

            assert.equal(priceInitial/Math.pow(10, 9), result);
            done();
        });
    });

});
