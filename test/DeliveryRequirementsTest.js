var CarAssetLogic = artifacts.require("./CarAssetLogic.sol");
var SmartAsset = artifacts.require("./SmartAsset.sol");
var IotSimulation = artifacts.require("./IotSimulation.sol");

contract('CarAssetLogic', function (accounts) {

    var smartAssetId;
    var smartAsset;
    var iotSimulationInstance;

    it("Should return price", async () => {
        const smartAsset = await SmartAsset.deployed();
        const iotSimulation = await IotSimulation.deployed();

        const result = await smartAsset.createAsset(200, "docUrl", 1, "email@email.com", "BMW X5", "VIN01", "yellow", "25000", "car");
        const smartAssetId = await result.logs[0].args.id.c[0];

        await iotSimulation.generateIotOutput(smartAssetId, 10);
        const deliveryPrice = await smartAsset.calculateDeliveryPrice(smartAssetId, "Saint-Petersburg")

        assert.isAbove(deliveryPrice, 0);
    })

    it('Should add city', async () => {
        const carAssetLogic = await CarAssetLogic.deployed();
        const availableCitiesBeforeAdd = await carAssetLogic.getAvailableCities.call();

        await carAssetLogic.addCity('London', '60', '60');
        const availableCitiesAfterAdd = await carAssetLogic.getAvailableCities.call();

        assert.notEqual(availableCitiesBeforeAdd.length, availableCitiesAfterAdd.length);
    })


    it('Should not add city', async () => {
        const carAssetLogic = await CarAssetLogic.deployed();
        const availableCitiesBeforeAdd = await carAssetLogic.getAvailableCities.call();

        await carAssetLogic.addCity('Moscow', 60, 60);
        const availableCitiesAfterAdd = await carAssetLogic.getAvailableCities.call();

        assert.equal(availableCitiesBeforeAdd.length, availableCitiesAfterAdd.length);
    })

    it("Should set coefficient", async () => {
        var coefficientToSet = 2226389; // == (DEFAULT_COEFFICIENT / 10 to the 9th)

        const smartAsset = await SmartAsset.deployed();
        const iotSimulation = await IotSimulation.deployed();
        const carAssetLogic = await CarAssetLogic.deployed();
        const result = await smartAsset.createAsset(Date.now(), "docUrl", 1, "email@email1.com", "Audi A8", "VIN02", "black", "2500", "car");
        const smartAssetId = await result.logs[0].args.id.c[0];

        await iotSimulation.generateIotOutput(smartAssetId, 100);

        const initialPrice = await smartAsset.calculateDeliveryPrice(smartAssetId, "Saint-Petersburg")
        await carAssetLogic.setCoefficientInWei(coefficientToSet);
        const newPrice = await smartAsset.calculateDeliveryPrice(smartAssetId, "Saint-Petersburg")

        assert.equal(initialPrice / Math.pow(10, 9), newPrice);
    })
})
