pragma solidity ^0.4.15;

import 'zeppelin-solidity/contracts/lifecycle/Destructible.sol';


contract SmartAssetMetadata is Destructible {

    mapping(bytes16 => address) smartAssetLogicAddresses;

    bytes16[] assetTypes;

    function addSmartAssetType(bytes16 newType, address smartAssetLogic) onlyOwner() {
        if (smartAssetLogicAddresses[newType] == address(0)) {
            assetTypes.push(newType);
        }

        smartAssetLogicAddresses[newType] = smartAssetLogic;
    }

    function getAssetTypes() constant returns (bytes16[]) {
        return assetTypes;
    }

    function getAssetLogicAddress(bytes16 assetType) constant returns(address) {
        return smartAssetLogicAddresses[assetType];
    }

    function updateAssetLogicAddress(bytes16 assetType, address _assetLogicAddress) onlyOwner() {
        smartAssetLogicAddresses[assetType] = _assetLogicAddress;
    }
}
