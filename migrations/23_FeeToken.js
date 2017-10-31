const SmartAsset = artifacts.require('SmartAsset')
const FeeToken = artifacts.require('FeeToken')

const FEE = new web3.BigNumber(1)

module.exports = (deployer, network, accounts) => {
    if(network != 'testnet') {
      return
    }

    deployer.deploy(FeeToken, SmartAsset.address)
    .then(() => {
      return FeeToken.deployed()
    })
    .then((feeTokenInstance) => {
      return feeTokenInstance.decimals()
    })
    .then((feeTokenDecimals) => {
      return Promise.all([
        SmartAsset.deployed(),
        feeTokenDecimals
      ])
    })
    .then(([smartAssetInstance, feeTokenDecimals]) => {
      const multiplier = new web3.BigNumber(10).pow(feeTokenDecimals)
      return smartAssetInstance.setFee(FeeToken.address, accounts[0], FEE.mul(multiplier))
    })
}
