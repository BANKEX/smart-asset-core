pragma solidity ^0.4.10;


import './SmartAssetLogicInterface.sol';
import 'zeppelin-solidity/contracts/lifecycle/Destructible.sol';

/**
 * Interface for SmartAsset contract
 */
contract SmartAssetInterface {
    function getAssetById(uint id) constant
    returns (
        uint32,
        bytes6,
        uint8,
        bytes32,
        bytes32,
        bytes32,
        bytes32,
        uint,
        uint,
        address);

    function updateFromExternalSource(uint24 id, bytes11 latitude, bytes11 longitude, bytes6 imageUrl);

    function getAssetIotById(uint id) constant returns (bytes11, bytes11, bytes6, bytes32);
}


/**
 * @title Base smart asset logic contract
 */
contract BaseAssetLogic is SmartAssetLogicInterface, Destructible {
    address smartAssetAddr;
    address smartAssetRouterAddr;

    /**
     * Check whether SmartAssetRouter contract executes method or not
     */
    modifier onlySmartAssetRouter {
        require(msg.sender == smartAssetRouterAddr);
        _;
    }

    function getById(uint assetId)
    returns (
        uint32,
        bytes6,
        uint8,
        bytes32,
        bytes32,
        bytes32,
        bytes32,
        uint,
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

    function setSmartAssetRouterAddr(address contractAddress) onlyOwner returns (bool result) {
        if (contractAddress == address(0)) {
            throw;
        } else {
            smartAssetRouterAddr = contractAddress;
            return true;
        }
    }
}
