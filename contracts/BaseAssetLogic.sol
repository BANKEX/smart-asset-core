pragma solidity ^0.4.10;


/**
 * Interface for SmartAsset contract
 */
contract SmartAssetInterface {
    function getAssetById(uint id) constant
    returns (
    uint,
    bytes32,
    bytes32,
    bytes32,
    uint,
    uint,
    uint,
    uint,
    bool,
    uint,
    address);


    function getAssetLocationById(uint id) constant returns (uint, uint);

    function updateViaIotSimulator(uint id, uint millage, uint damaged, bool smokingCar, uint longitude, uint latitude);
}


/**
 * @title Base smart asset logic contract
 */
contract BaseAssetLogic {
    address smartAssetAddr;
    address smartAssetMetadataAddr;
    address public owner = msg.sender;

    /**
     * Check whether contract owner executes method or not
     */
    modifier onlyOwner {
        if (msg.sender != owner) {throw;} else {_;}
    }

    /**
     * Check whether metadataContract executes method or not
     */
    modifier onlySmartAssetMetadata {
        if (msg.sender != smartAssetMetadataAddr) {throw;} else {_;}
    }

    /**
     * Check whether SmartAsset contract executes method or not
     */
    modifier onlySmartAsset {
        if (msg.sender != smartAssetAddr) {throw;} else {_;}
    }

    function getById(uint assetId)
    returns (
    uint,
    bytes32,
    bytes32,
    bytes32,
    uint,
    uint,
    uint,
    uint,
    bool,
    uint,
    address)
    {
        SmartAssetInterface asset = SmartAssetInterface(smartAssetAddr);
        return asset.getAssetById(assetId);
    }


    /**
     * @dev Calculates price base on formula1
     * @param assetId Id of smart asset
     */
    function removeAssetPrice(uint assetId) onlySmartAsset {

    }

    /**
     * @param assetId Id of smart asset
     */
    function calculateAssetPrice(uint assetId) {
    }

    /**
     * @param assetId Id of smart asset
     */
    function getSmartAssetPrice(uint assetId) constant returns (uint) {
        return 0;
    }

    /**
     * @param assetId Id of smart asset
     */
    function getSmartAssetAvailability(uint assetId) constant returns (bool) {
        return true;
    }

    /**
     * @param assetId Id of smart asset
     */
    function calculateDeliveryPrice(uint assetId, bytes32 param) constant returns (uint) {
        return 0;
    }

    /**
    * @dev Check whether smart asset was modified without hash modification or not
    * @param assetId Id of smart asset
    */
    function checkSmartAssetModification(uint assetId) constant returns (bool modified) {
        return false;
    }

    /**
     * @dev Setter for the SmartAsset contract address
     * @param contractAddress Address of the SmartAsset contract
     */
    function setSmartAssetAddr(address contractAddress) onlyOwner returns (bool result) {
        if (contractAddress == address(0)) {
            throw;
        } else {
            smartAssetAddr = contractAddress;
            return true;
        }
    }

    /**
     * @dev Setter for the SmartAsset contract address
     * @param contractAddress Address of the SmartAssetMetadata contract
     */
    function setSmartAssetMetadataAddr(address contractAddress) onlyOwner returns (bool result) {
        if (contractAddress == address(0)) {
            throw;
        } else {
            smartAssetMetadataAddr = contractAddress;
            return true;
        }
    }
}
