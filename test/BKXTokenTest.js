var BKXToken = artifacts.require("./BKXToken.sol");
var SmartAsset = artifacts.require("./SmartAsset.sol");


contract('BKXToken', function (accounts) {

    it('Should throw error', async () => {
        const bkxToken = await BKXToken.deployed();
        var result = await bkxToken.balanceOf(accounts[0]);
        const initialAmountBKX = parseInt(result);

        try {
            bkxToken.transfer(accounts[0], accounts[1], initialAmountBKX + 1)
        } catch (error) {
            console.log('Should catch error and the transfer should not go down as there is not enough tokens in accounts[0]');
        }
    })
})
