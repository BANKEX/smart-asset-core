pragma solidity ^0.4.10;


import './SmartAssetLogicInterface.sol';

/**
 * Interface for SmartAsset contract
 */
contract SmartAssetInterface {
    function getAssetById(uint id) constant
    returns (
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

    function updateFromExternalSource(uint id, uint u1, uint u2, bool bool1, uint u3, uint u4);
}


/**
 * @title Base smart asset logic contract
 */
contract BaseAssetLogic is SmartAssetLogicInterface {
    address smartAssetAddr;
    address public owner = msg.sender;

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

    function getById(uint assetId)
    returns (
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
    function onAssetSold(uint assetId) {

    }

    /**
     * @param assetId Id of smart asset
     */
    function calculateAssetPrice(uint assetId) returns (uint) {
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
    function isAssetTheSameState(uint assetId) constant returns (bool sameState) {
        return true;
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
}
