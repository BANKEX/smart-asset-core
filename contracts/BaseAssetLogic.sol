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


    function onAssetSold(uint assetId) {

    }

    function calculateAssetPrice(uint assetId) returns (uint) {
    }

    function getSmartAssetPrice(uint assetId) constant returns (uint) {
        return 0;
    }

    function getSmartAssetAvailability(uint assetId) constant returns (bool) {
        return true;
    }

    function calculateDeliveryPrice(uint assetId, bytes32 param) constant returns (uint) {
        return 0;
    }

    function isAssetTheSameState(uint assetId) constant returns (bool sameState) {
        return true;
    }

    function setSmartAssetAddr(address contractAddress) onlyOwner returns (bool result) {
        if (contractAddress == address(0)) {
            throw;
        } else {
            smartAssetAddr = contractAddress;
            return true;
        }
    }
}
