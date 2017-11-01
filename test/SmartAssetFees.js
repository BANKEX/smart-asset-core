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
  })

  describe('if the fee is set', () => {

    beforeEach(async () => {
      this.feeToken = await FeeToken.new(this.smartAsset.address, {from: feeTokenContractOwner})
      const feeTokenDecimals = await this.feeToken.decimals()
      this.fee = new BigNumber(10).pow(feeTokenDecimals)
      await this.smartAsset.setFee(this.feeToken.address, feeWallet, this.fee, {from: smartAssetContractOwner})
    })

    it('should collect the fee when an asset is created', async () => {
      await this.smartAsset.createAsset(Date.now(), 200, "docUrl", 1, "email@email1.com", "Audi A8", "VIN02", "black", "2500", "car", {from: smartAssetOwner})
      const feeWalletBalance = await this.feeToken.balanceOf(feeWallet)
      feeWalletBalance.should.be.bignumber.equal(this.fee)
    })

    // it('should not allow to create an asset without the fee', async () => {
    //   await this.smartAsset.createAsset(Date.now(), 200, "docUrl", 1, "email@email1.com", "Audi A8", "VIN02", "black", "2500", "car", {from: smartAssetOwner}).should.be.rejected
    // })
  })
})
