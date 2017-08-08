pragma solidity ^0.4.10;


import './SmartAssetMetadata.sol';
import './SmartAssetLogicInterface.sol';
import 'zeppelin-solidity/contracts/lifecycle/Destructible.sol';


contract SmartAssetRouter is Destructible{
    address private smartAssetAddr;

    SmartAssetMetadata smartAssetMetadata;

    mapping (uint => bytes32) assetTypeById;

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

    function getAssetType(uint assetId) constant returns (bytes32) {
        return assetTypeById[assetId];
    }

    /**
     * @dev Calculates price base on formula1
     * @param assetId Id of smart asset
     */
    function onAssetSold(uint assetId) onlySmartAsset {
        _getSmartAssetImpl(assetId).onAssetSold(assetId);
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

    function isAssetTheSameState(uint id) returns (bool) {
        return _getSmartAssetImpl(id).isAssetTheSameState(id);
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

    function _getSmartAssetImpl(uint assetId) private constant returns (SmartAssetLogicInterface smartAssetLogicInterface){
        bytes32 assetType = assetTypeById[assetId];
        address implAddress = smartAssetMetadata.getAssetLogicAddress(assetType);
        return SmartAssetLogicInterface(implAddress);
    }
}
