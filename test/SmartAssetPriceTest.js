var IotSimulation = artifacts.require("./IotSimulation.sol");
var SmartAsset = artifacts.require("./SmartAsset.sol");
var CarAssetLogic = artifacts.require("./CarAssetLogic.sol");

contract('IotSimulation', function (accounts) {

    it("Check exception will be thrown in case asset is in step OnSale or after", async () => {
        const smartAsset = await SmartAsset.deployed();
        const simulator = await IotSimulation.deployed();
        var result = await smartAsset.createAsset(Date.now(), 200, "docUrl", 1, "email@email.com", "BMW X5", "VIN01", "yellow", "25000", "car");
        const smartAssetGeneratedId = result.logs[0].args.id.c[0];

        await simulator.generateIotOutput(smartAssetGeneratedId, 0);
        await smartAsset.calculateAssetPrice(smartAssetGeneratedId);
        await smartAsset.makeOnSale(smartAssetGeneratedId);

        try {
            await simulator.generateIotOutput(smartAssetGeneratedId, 1);
            assert(false, "Throw was expected but didn't.");
        } catch (error) {
            console.log('Expected error. Got it');
        }
    })

    it("Check exception will be thrown in id is not present", async () => {
        const carAssetLogic = await CarAssetLogic.deployed();
        try {
            await carAssetLogic.checkSmartAssetModification(10000);
            assert(false, "Throw was expected but didn't.");
        } catch (error) {
            console.log('Expected error. Got it');
        }
    })
})
