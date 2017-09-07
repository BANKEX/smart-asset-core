var IotSimulation = artifacts.require("./IotSimulation.sol");
var SmartAsset = artifacts.require("./SmartAsset.sol");
var CarAssetLogic = artifacts.require("./CarAssetLogic.sol");


function toAscii(input) {
    return web3.toAscii(input).replace(/\u0000/g, '');
}

contract('IotSimulation', function (accounts) {

    it("generateIotOutput have to throw exception if id param is absent", async () => {
        const iotSimulation = await IotSimulation.deployed();
        try {
            await iotSimulation.generateIotOutput(0, 0);
            assert(false, "Throw was expected but didn't.");
        } catch (error) {
            console.log('Expected error. Got it');
        }
    })

    it("generateIotAvailability have to throw exception if id param is absent", async () => {
        const iotSimulation = await IotSimulation.deployed();
        try {
            await iotSimulation.generateIotAvailability(0, true);
            assert(false, "Throw was expected but didn't.");
        } catch (error) {
            console.log('Expected error. Got it');
        }
    })

    it("generateIotOutput have to throw exception if asset with such id is absent", async () => {
        const iotSimulation = await IotSimulation.deployed();
        try {
            await iotSimulation.generateIotOutput(4294967295, 0);
            assert(false, "Throw was expected but didn't.");
        } catch (error) {
            console.log('Expected error. Got it');
        }
    })

    it("generateIotAvailability have to throw exception if asset with such id is absent", async () => {
        const iotSimulation = await IotSimulation.deployed();
        try {
            await iotSimulation.generateIotAvailability(4294967295, true);
            assert(false, "Throw was expected but didn't.");
        } catch (error) {
            console.log('Expected error. Got it');
        }
    })
})
