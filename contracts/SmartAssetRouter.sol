pragma solidity ^0.4.0;


import './SmartAssetMetadata.sol';


contract SmartAssetInterface {
    function removeAssetPrice(uint assetId);

    function calculateAssetPrice(uint assetId);

    function getSmartAssetPrice(uint id) returns (uint);

    function checkSmartAssetModification(uint id) returns (bool);

    function calculateDeliveryPrice(uint id, bytes32 city) returns (uint);

    function getSmartAssetAvailability(uint id) returns (bool);
}


contract SmartAssetRouter {

    SmartAssetMetadata smartAssetMetadata;

    mapping (uint => bytes32) assetTypeById;

    /**
     * Check whether SmartAsset contract executes method or not
     */
    modifier onlySmartAsset {
        //TODO:
        //        if (msg.sender != smartAssetAddr) {throw;} else {_;}
        _;
    }

    function SmartAssetRouter(address metadataAddress) {
        require(metadataAddress != address(0));
        smartAssetMetadata = SmartAssetMetadata(metadataAddress);
    }

    /**
     * @dev Calculates price base on formula1
     * @param assetId Id of smart asset
     */
    function removeAssetPrice(uint assetId) onlySmartAsset {
        _getSmartAssetImpl(assetId).removeAssetPrice(assetId);
    }

    /**
     * @dev Calculates price base on formula1
     * @param assetId Id of smart asset
     */
    function calculateAssetPrice(uint assetId) onlySmartAsset {
        _getSmartAssetImpl(assetId).calculateAssetPrice(assetId);
    }

    function getSmartAssetPrice(uint id) returns (uint) {
        return _getSmartAssetImpl(id).getSmartAssetPrice(id);
    }

    function checkSmartAssetModification(uint id) returns (bool) {
        return _getSmartAssetImpl(id).checkSmartAssetModification(id);
    }

    function calculateDeliveryPrice(uint id, bytes32 city) returns (uint) {
        return _getSmartAssetImpl(id).calculateDeliveryPrice(id, city);
    }

    function getSmartAssetAvailability(uint id) returns (bool) {
        return _getSmartAssetImpl(id).getSmartAssetAvailability(id);
    }

    function setAssetType(uint assetId, bytes32 assetType) {
        assetTypeById[assetId] = assetType;
    }

    // TODO: visibility
    function _getSmartAssetImpl(uint assetId) constant returns (SmartAssetInterface smartAssetInterface){
        bytes32 assetType = assetTypeById[assetId];
        address implAddress = smartAssetMetadata.getAssetLogicAddress(assetType);
        return SmartAssetInterface(implAddress);
    }
}
