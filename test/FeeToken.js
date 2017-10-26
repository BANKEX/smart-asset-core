const BigNumber = web3.BigNumber

const should = require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should()

const FeeToken = artifacts.require('FeeToken')

const MULTIPLIER = new BigNumber(10).pow(9)
const REWARD = new BigNumber(100).mul(MULTIPLIER)
const APPROVAL_AMOUNT = new BigNumber(10).mul(MULTIPLIER)
const FEE = new BigNumber(1).mul(MULTIPLIER)

contract('FeeToken', function ([_, tokenContractOwner, tokenHolder, someAccount, smartAssetContract, bankex]) {

  beforeEach(async function () {
    this.token = await FeeToken.new({from: tokenContractOwner})
  })

  it('each account is given a reward', async function() {
    const balance = await this.token.balanceOf(tokenHolder, {from: someAccount})
    balance.should.be.bignumber.equal(REWARD)
  })

  it('token holder can approve tokens to smart asset contract', async function() {
    await this.token.approve(smartAssetContract, APPROVAL_AMOUNT, {from: tokenHolder})
    const smartAssetContractAllowance = await this.token.allowance(tokenHolder, smartAssetContract, {from: someAccount})
    smartAssetContractAllowance.should.be.bignumber.equal(APPROVAL_AMOUNT)
  })

  it('smart asset contract can transfer approved tokens to BANKEX', async function() {
    await this.token.approve(smartAssetContract, APPROVAL_AMOUNT, {from: tokenHolder})
    await this.token.transferFrom(tokenHolder, bankex, FEE, {from: smartAssetContract})
    const tokenHolderBalance = await this.token.balanceOf(tokenHolder, {from: someAccount})
    tokenHolderBalance.should.be.bignumber.equal(REWARD.sub(FEE))
    const bankexBalance = await this.token.balanceOf(bankex, {from: someAccount})
    bankexBalance.should.be.bignumber.equal(FEE)
    const smartAssetContractAllowance = await this.token.allowance(tokenHolder, smartAssetContract, {from: someAccount})
    smartAssetContractAllowance.should.be.bignumber.equal(APPROVAL_AMOUNT.sub(FEE))
  })
})
