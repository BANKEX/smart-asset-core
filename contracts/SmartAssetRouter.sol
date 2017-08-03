pragma solidity ^0.4.0;


import './SmartAssetMetadata.sol';


contract SmartAssetInterface {
    function removeAssetPrice(uint assetId);

    function calculateAssetPrice(uint assetId);
}


contract SmartAssetRouter {

    SmartAssetMetadata smartAssetMetadata = new SmartAssetMetadata();

    mapping (uint => bytes32) assetTypeById;

    /**
     * Check whether SmartAsset contract executes method or not
     */
    modifier onlySmartAsset {
        //TODO:
        //        if (msg.sender != smartAssetAddr) {throw;} else {_;}
        _;
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
