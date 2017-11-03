var CarAssetLogicStorage = artifacts.require("CarAssetLogicStorage.sol");
var CarAssetLogicStorageMock = artifacts.require("CarAssetLogicStorageMock.sol");
var CarAssetLogic = artifacts.require("CarAssetLogic.sol");


module.exports = (deployer, network) => {
    var carAssetLogicStorageOrMock;

    deployer.then(() => {
        if(network == 'development') {
            return deployer.deploy(CarAssetLogicStorageMock);
        }
        else {
            return deployer.deploy(CarAssetLogicStorage);
        }
    })
    .then(() => {
        if(network == 'development') {
            return CarAssetLogicStorageMock.deployed();
        }
        else {
            return CarAssetLogicStorage.deployed();
        }
    })
    .then((instance) => {
        carAssetLogicStorageOrMock = instance;
        carAssetLogicStorageOrMock.setCarAssetLogic(CarAssetLogic.address);
    })
    .then(() => {
         return CarAssetLogic.deployed();
    })
    .then((carAssetLogic) => {
        carAssetLogic.setCarAssetLogicStorage(carAssetLogicStorageOrMock.address);
    })
}
