pragma solidity ^0.4.10;


import './SmartAssetLogicInterface.sol';
import 'zeppelin-solidity/contracts/lifecycle/Destructible.sol';

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
contract BaseAssetLogic is SmartAssetLogicInterface, Destructible {
    address smartAssetAddr;

    /**
     * Check whether SmartAsset contract executes method or not
     */
    modifier onlySmartAsset {
        require(msg.sender == smartAssetAddr);
        _;
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

    function forceUpdateFromExternalSource(uint id) {
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
