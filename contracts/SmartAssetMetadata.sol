pragma solidity ^0.4.10;

import 'zeppelin-solidity/contracts/lifecycle/Destructible.sol';


contract SmartAssetMetadata is Destructible {

    mapping(bytes32 => address) smartAssetLogicAddresses;

    bytes32[] assetTypes;

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
