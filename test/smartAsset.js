var SmartAsset = artifacts.require("./SmartAsset.sol");
var BKXToken = artifacts.require("./BKXToken.sol");

function toAscii(input) {
    return web3.toAscii(input).replace(/\u0000/g, '');
}

contract('SmartAsset', function (accounts) {

    it("Should create asset", async () => {
        const timestamp = Date.now();
        const smartAsset = await SmartAsset.deployed();
        const result = await smartAsset.createAsset(timestamp, 200, "docUrl", 1, "email@email.com", "BMW X5", "VIN01", "yellow", "25000", "car");
        const smartAssetGeneratedId = result.logs[0].args.id.c[0];

        const returnValue = await smartAsset.getAssetById.call(smartAssetGeneratedId);

        console.log(returnValue);
        assert.equal(returnValue[0], timestamp);
        assert.equal(returnValue[1], 200);
        assert.equal(toAscii(returnValue[2]), "docUrl");
        assert.equal(returnValue[3], 1);
        assert.equal(toAscii(returnValue[4]), "email@email.com");
        assert.equal(toAscii(returnValue[5]), "BMW X5");
        assert.equal(toAscii(returnValue[6]), "VIN01");
        assert.equal(toAscii(returnValue[7]), "yellow");
        assert.equal(returnValue[8], 25000);
        assert.equal(returnValue[9], 0);
        assert.equal(returnValue[10], accounts[0]);
        assert.equal(toAscii(returnValue[11]), "car");

    })

    it("Should return my assets", async () => {
        const smartAsset = await SmartAsset.deployed();
        const initialMyAssetsCarCount = await smartAsset.getMyAssetsCount.call("car");

        const timestamp = Date.now();

        await smartAsset.createAsset(timestamp, 200, "docUrl", 1, "email@email1.com", "Audi A8", "VIN02", "black", "2500", "car");
        await smartAsset.createAsset(timestamp, 201, "docUrl", 25, "email@email2.com", "notCar", "info", "data", "25", "Notcar");

        const newMyAssetsCarCount = await smartAsset.getMyAssetsCount.call("car");
        assert.equal(parseInt(newMyAssetsCarCount), parseInt(initialMyAssetsCarCount) + 1);

        const returnValue = await smartAsset.getMyAssets.call("car", 0, 1);
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
    })

    it("Should remove asset", async () => {
        var assetIdToRemove = 1;
        const smartAsset = await SmartAsset.deployed();

        await smartAsset.removeAsset(assetIdToRemove);
        try {
            await smartAsset.getAssetById.call(assetIdToRemove);
            assert(false, "Throw was expected but didn't.");
        } catch (error) {
            if (error.toString().indexOf("invalid opcode") != -1) {
                console.log("We were expecting a Solidity throw (aka an invalid opcode), we got one. Test succeeded.");
            } else {
                // if the error is something else (e.g., the assert from previous promise), then we fail the test
                assert(false, error.toString());
            }
        }
    })

    it("getAssetByVin have to throw exception if asset is absent", async () => {
        const smartAsset = await SmartAsset.deployed();

        try {
            await smartAsset.getAssetById.call(999);
            assert(false, "Throw was expected but didn't.");
        } catch (error) {
            if (error.toString().indexOf("invalid opcode") != -1) {
                console.log("We were expecting a Solidity throw (aka an invalid opcode), we got one. Test succeeded.");
            } else {
                // if the error is something else (e.g., the assert from previous promise), then we fail the test
                assert(false, error.toString());
            }
        }
    })

    it('Should throw error as last index is smaller that first', async () => {
        const smartAsset = await SmartAsset.deployed();
        try {
            await smartAsset.getMyAssets('car', 1, 0);
        } catch (error) {
            //do nothing
        }
    })

    it('Should throw error as the last index if out of bound', async () => {
        const smartAsset = await SmartAsset.deployed();
        try {
            await smartAsset.getMyAssets('car', 0, 5);
        } catch (error) {
            //do nothing
        }
    })

    it('Should return assets on sale', async () => {
        const timestamp = Date.now();
        const smartAsset = await SmartAsset.deployed();
        const res = await smartAsset.createAsset(timestamp, 200, "docUrl", 1, "email@email1.com", "Audi A8", "VIN02", "black", "2500", "car");
        const smartAssetGeneratedId = res.logs[0].args.id.c[0];

        await smartAsset.calculateAssetPrice(smartAssetGeneratedId);
        await smartAsset.makeOnSale(smartAssetGeneratedId);
        const result = await smartAsset.getAssetsOnSale('car', 0, 0);

        var ids = result[0];
        assert.equal(ids[0], smartAssetGeneratedId);

        var year = result[1];
        assert.equal(year[0], 200);

        var _types = result[2];
        assert.equal(_types[0], 1);

        var vins = result[3];
        assert.equal(toAscii(vins[0]), 'Audi A8');

        var owner = result[6];
        assert.equal(owner, web3.eth.accounts[0]);

    })

    it('Should search for smart assets', async () => {
        const timestamp = Date.now();
        const smartAsset = await SmartAsset.deployed();
        var result = await smartAsset.createAsset(timestamp, 200, "docUrl", 1, "email@email1.com", "Audi A8", "VIN02", "black", "2500", "car");
        var smartAssetGeneratedId = result.logs[0].args.id.c[0];

        await smartAsset.calculateAssetPrice(smartAssetGeneratedId);

        await smartAsset.makeOnSale(smartAssetGeneratedId);

        result = await smartAsset.createAsset(timestamp, 201, "docUrl", 1, "email@email1.com", "BMW X3", "VIN007", "red", "2500", "car");
        smartAssetGeneratedId = result.logs[0].args.id.c[0];

        await smartAsset.calculateAssetPrice(smartAssetGeneratedId);

        await smartAsset.makeOnSale(smartAssetGeneratedId);

        result = await smartAsset.searchAssetsOnSaleByKeyWord('car', 'BMW X3');

        assert.equal(1, result[0].length);
        var ids = result[0];
        assert.equal(smartAssetGeneratedId, ids[0]);
    })
})
