pragma solidity ^0.4.10;


contract SmartAssetMetadata {

    address owner = msg.sender;

    mapping(bytes32 => AssetContractsData) contratsMetaData;

    bytes32[] assetTypes;

    struct AssetContractsData {
    address smartAssetAddress;
    address smartAssetLogic;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }

    function addSmartAssetType(bytes32 newType,
    address smartAssetAddress,
    address smartAssetLogic) onlyOwner() {


        contratsMetaData[newType] = AssetContractsData(smartAssetAddress,  smartAssetLogic);

        assetTypes.push(newType);

    }

    function getAssetTypes() returns (bytes32[]) {
        return assetTypes;
    }
}
