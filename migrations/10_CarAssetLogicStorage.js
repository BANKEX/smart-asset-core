var CarAssetLogicStorage = artifacts.require("CarAssetLogicStorage.sol");
var CarAssetLogicStorageMock = artifacts.require("CarAssetLogicStorageMock.sol");
var CarAssetLogic = artifacts.require("CarAssetLogic.sol");


module.exports = function(deployer, network) {
    var carAssetLogicStorageOrMock;

    deployer.then(function() {
        if(network == 'development') {
            return deployer.deploy(CarAssetLogicStorageMock);
        }
        else {
            return deployer.deploy(CarAssetLogicStorage);
        }
    })
    .then(function() {
        if(network == 'development') {
            return CarAssetLogicStorageMock.deployed();
        }
        else {
            return CarAssetLogicStorage.deployed();
        }
    })
    .then(function(instance){
        carAssetLogicStorageOrMock = instance;
        carAssetLogicStorageOrMock.setCarAssetLogic(CarAssetLogic.address);
    })
    .then(function() {
         return CarAssetLogic.deployed();
    })
    .then(function(carAssetLogic){
        carAssetLogic.setCarAssetLogicStorage(carAssetLogicStorageOrMock.address);
    })
}
