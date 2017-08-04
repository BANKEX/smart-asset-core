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
    address public owner = msg.sender;
    address private smartAssetAddr;

    SmartAssetMetadata smartAssetMetadata;

    mapping (uint => bytes32) assetTypeById;

    /**
     * Check whether contract owner executes method or not
     */
    modifier onlyOwner {
        if (msg.sender != owner) {throw;} else {_;}
    }

    /**
     * Check whether SmartAsset contract executes method or not
     */
    modifier onlySmartAsset {
          if (msg.sender != smartAssetAddr) {throw;} else {_;}
    }

    function SmartAssetRouter(address metadataAddress) {
        require(metadataAddress != address(0));
        smartAssetMetadata = SmartAssetMetadata(metadataAddress);
    }

    function getAssetType(uint assetId) constant returns (bytes32) {
        return assetTypeById[assetId];
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

    function setAssetType(uint assetId, bytes32 assetType) onlySmartAsset {
        assetTypeById[assetId] = assetType;
    }

    /**
     * @dev Setter for the SmartAsset contract address
     * @param contractAddress Address of the SmartAsset contract
     */
    function setSmartAssetAddress(address contractAddress) onlyOwner {
        require(contractAddress != address(0));
        smartAssetAddr = contractAddress;
    }

    function _getSmartAssetImpl(uint assetId) constant private returns (SmartAssetInterface smartAssetInterface){
        bytes32 assetType = assetTypeById[assetId];
        address implAddress = smartAssetMetadata.getAssetLogicAddress(assetType);
        return SmartAssetInterface(implAddress);
    }
}
