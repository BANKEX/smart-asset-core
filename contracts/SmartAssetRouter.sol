pragma solidity ^0.4.10;


import './SmartAssetMetadata.sol';
import './SmartAssetLogicInterface.sol';
import './SmartAssetRouterStorage.sol';
import 'zeppelin-solidity/contracts/lifecycle/Destructible.sol';


contract SmartAssetRouter is Destructible{
    address private smartAssetAddr;

    SmartAssetMetadata smartAssetMetadata;
    SmartAssetRouterStorage smartAssetRouterStorage;

    /**
     * Check whether SmartAsset contract executes method or not
     */
    modifier onlySmartAsset {
        require(msg.sender == smartAssetAddr);
        _;
    }

    function SmartAssetRouter(address metadataAddress) {
        require(metadataAddress != address(0));
        smartAssetMetadata = SmartAssetMetadata(metadataAddress);
    }

    function getAssetType(uint24 assetId) constant returns (bytes16) {
        return smartAssetRouterStorage.getAssetType(assetId);
    }

    function onAssetSold(uint24 assetId) onlySmartAsset {
        _getSmartAssetImpl(assetId).onAssetSold(assetId);
    }

    function calculateAssetPrice(uint24 assetId) onlySmartAsset {
        _getSmartAssetImpl(assetId).calculateAssetPrice(assetId);
    }

    function getSmartAssetPrice(uint24 id) constant returns (uint) {
        return _getSmartAssetImpl(id).getSmartAssetPrice(id);
    }

    function isAssetTheSameState(uint24 id) returns (bool) {
        return _getSmartAssetImpl(id).isAssetTheSameState(id);
    }

    function calculateDeliveryPrice(uint24 id, bytes32 city) returns (uint) {
        return _getSmartAssetImpl(id).calculateDeliveryPrice(id, city);
    }

    function calculateDeliveryPrice(uint24 id, bytes11 latitudeTo, bytes11 longitudeTo) returns (uint) {
        return _getSmartAssetImpl(id).calculateDeliveryPrice(id, longitudeTo, latitudeTo);
    }

    function getSmartAssetAvailability(uint24 id) returns (bool) {
        return _getSmartAssetImpl(id).getSmartAssetAvailability(id);
    }

    function forceUpdateFromExternalSource(uint24 id, string param) onlySmartAsset {
        return _getSmartAssetImpl(id).forceUpdateFromExternalSource(id, param);
    }

    function setAssetType(uint24 assetId, bytes16 assetType) onlySmartAsset {
        smartAssetRouterStorage.setAssetType(assetId, assetType);
    }

    /**
       * @dev Setter for the SmartAsset contract address
       * @param contractAddress Address of the SmartAsset contract
       */
    function setSmartAssetAddress(address contractAddress) onlyOwner {
        require(contractAddress != address(0));
        smartAssetAddr = contractAddress;
    }

    function setSmartAssetMetaAddress(address _metaDataAddress) onlyOwner {
        smartAssetMetadata = SmartAssetMetadata(_metaDataAddress);
    }

    function setSmartAssetRouterStorage(address _smartAssetRouterStorageAddress) onlyOwner {
        smartAssetRouterStorage = SmartAssetRouterStorage(_smartAssetRouterStorageAddress);
    }

    function _getSmartAssetImpl(uint24 assetId) private constant returns (SmartAssetLogicInterface smartAssetLogicInterface){
        bytes16 assetType = smartAssetRouterStorage.getAssetType(assetId);
        address implAddress = smartAssetMetadata.getAssetLogicAddress(assetType);
        return SmartAssetLogicInterface(implAddress);
    }
}
