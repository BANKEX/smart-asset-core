pragma solidity ^0.4.10;


contract SmartAssetMetadata {

    address owner = msg.sender;

    mapping(bytes32 => address) smartAssetLogicAddresses;

    bytes32[] assetTypes;

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }

    function addSmartAssetType(bytes32 newType, address smartAssetLogic) onlyOwner() {

        smartAssetLogicAddresses[newType] = smartAssetLogic;

        assetTypes.push(newType);

    }

    function getAssetTypes() constant returns (bytes32[]) {
        return assetTypes;
    }

    function getAssetLogicAddress(bytes32 assetType) constant returns(address) {
        return smartAssetLogicAddresses[assetType];
    }

    function updateAssetLogicAddress(bytes32 assetType, address _assetLogicAddress) onlyOwner() {
        smartAssetLogicAddresses[assetType] = _assetLogicAddress;
    }
}
