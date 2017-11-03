var SmartAssetRouter = artifacts.require("SmartAssetRouter.sol");
var SmartAsset = artifacts.require("SmartAsset.sol");
var CarAssetLogic = artifacts.require("CarAssetLogic.sol");
var RealEstateAssetLogic = artifacts.require("RealEstateAssetLogic.sol");
var AppleAssetLogic = artifacts.require("AppleAssetLogic.sol");
var IotSimulation = artifacts.require("IotSimulation.sol");


module.exports = (deployer) => {
    deployer.then(() => {
        return CarAssetLogic.deployed();
    })
    .then((carAssetLogic) => {
        return Promise.all([
          carAssetLogic.setSmartAssetAddr(SmartAsset.address),
          carAssetLogic.setSmartAssetRouterAddr(SmartAssetRouter.address),
          carAssetLogic.setIotSimulationAddr(IotSimulation.address)
        ]);
    })
    .then(() => {
         return IotSimulation.deployed()
    })
    .then((iotSimulation) => {
        return iotSimulation.setCarAssetLogicAddr(CarAssetLogic.address);
    })
    .then(() => {
        return RealEstateAssetLogic.deployed();
    })
    .then((realEstateAsset) => {
        return Promise.all([
          realEstateAsset.setSmartAssetAddr(SmartAsset.address),
          realEstateAsset.setSmartAssetRouterAddr(SmartAssetRouter.address)
        ]);
    })
    .then(() => {
        return AppleAssetLogic.deployed();
    })
    .then((appleAsset) => {
        return Promise.all([
          appleAsset.setSmartAssetAddr(SmartAsset.address),
          appleAsset.setSmartAssetRouterAddr(SmartAssetRouter.address)
        ]);
    })
}
