pragma solidity ^0.4.10;


contract SmartAssetMetadata {

    address owner = msg.sender;

    mapping(bytes32 => AssetContractsData) contractsMetaData;

    bytes32[] assetTypes;

    struct AssetContractsData {
        address smartAssetAddress;
        address smartAssetLogic;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }

    function addSmartAssetType(bytes32 newType, address smartAssetAddress, address smartAssetLogic) onlyOwner() {

        contractsMetaData[newType] = AssetContractsData(smartAssetAddress,  smartAssetLogic);

        assetTypes.push(newType);

    }

    function getAssetTypes() constant returns (bytes32[]) {
        return assetTypes;
    }

    function getAssetLogicAddress(bytes32 assetType) constant returns(address) {
        return contractsMetaData[assetType].smartAssetLogic;
    }

    function getSmartAssetAddress(bytes32 assetType) constant returns(address) {
        return contractsMetaData[assetType].smartAssetAddress;
    }

    function updateAssetLogicAddress(bytes32 assetType, address _assetLogicAddress) onlyOwner() {
        contractsMetaData[assetType].smartAssetLogic = _assetLogicAddress;
    }

    function updateSmartAssetAddress(bytes32 assetType, address _smartAssetAddress) onlyOwner() {
        contractsMetaData[assetType].smartAssetAddress = _smartAssetAddress;
    }
}
