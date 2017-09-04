var CarAssetLogicStorage = artifacts.require("CarAssetLogicStorage.sol");
var CarAssetLogicStorageMock = artifacts.require("CarAssetLogicStorageMock.sol");


module.exports = function(deployer, network) {
    if(network == 'development') {
        return deployer.deploy(CarAssetLogicStorageMock);
    }
    else {
        return deployer.deploy(CarAssetLogicStorage);
    }
};
