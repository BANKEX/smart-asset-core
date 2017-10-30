const BigNumber = web3.BigNumber

const should = require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should()

const SmartAsset = artifacts.require('SmartAsset')
const FeeToken = artifacts.require('FeeToken')

contract('SmartAsset', ([smartAssetContractOwner, smartAssetOwner, feeTokenContractOwner, feeWallet, _]) => {

  beforeEach(async () => {
    this.smartAsset = await SmartAsset.deployed()
    const result = await this.smartAsset.createAsset(Date.now(), 200, "docUrl", 1, "email@email1.com", "Audi A8", "VIN02", "black", "2500", "car", {from: smartAssetOwner})
    this.assetId = result.logs[0].args.id.c[0]
    await this.smartAsset.calculateAssetPrice(this.assetId, {from: smartAssetOwner})
  })

  describe('when fee is set', () => {

    beforeEach(async () => {
      this.feeToken = await FeeToken.new(this.smartAsset.address, {from: feeTokenContractOwner})
      const feeTokenDecimals = await this.feeToken.decimals()
      this.fee = new BigNumber(10).pow(feeTokenDecimals)
      await this.smartAsset.setFee(this.feeToken.address, feeWallet, this.fee, {from: smartAssetContractOwner})
    })

    it('should collect fee', async () => {
      await this.smartAsset.makeOnSale(this.assetId, {from: smartAssetOwner})
      const feeWalletBalance = await this.feeToken.balanceOf(feeWallet)
      feeWalletBalance.should.be.bignumber.equal(this.fee)
    })
  })
})
