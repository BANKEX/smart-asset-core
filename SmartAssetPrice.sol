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
}


/**
 * @title Smart asset price contract
 */
contract SmartAssetPrice {
    uint private BASE_CAR_PRICE = 10000;
    uint private MIN_CAR_PRICE = 100;
    address public owner = msg.sender;
    address private smartAssetAddr;

    // Definition of Smart asset price data object
    struct SmartAssetPriceData {
    uint price;
    bytes32 hash;
    }

    // Smart asset by its identifier
    mapping (uint => SmartAssetPriceData) smartAssetPriceById;

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

    /**
     * @dev Calculates price base on formula1
     * @param assetId Id of smart asset
     */
    function calculateAssetPrice(uint assetId)  onlySmartAsset {
        SmartAssetInterface asset = SmartAssetInterface(smartAssetAddr);
        var(id, b1, b2, b3, u1, u2, u3, u4, bool1, state, owner) =  asset.getAssetById(assetId);
        SmartAssetPriceData memory smartAssetPriceData = SmartAssetPriceData(_calculateAssetPrice(u1, u2, bool1), sha256(b1, b2, b3, u1, u2, u3, u4, bool1));
        smartAssetPriceById[id] = smartAssetPriceData;
    }

    /**
     * @dev Returns price of the asset
     * @param id Id of smart asset
     */
    function getSmartAssetPrice(uint id) constant returns (uint price) {
        //check scenario when there is no id in map
        return smartAssetPriceById[id].price;
    }

    /**
     * @dev Check whether smart asset was modified without hash modification or not
     * @param assetId Id of smart asset
     */
    function checkSmartAssetModification(uint assetId) constant returns (bool modified) {
        SmartAssetInterface asset = SmartAssetInterface(smartAssetAddr);
        var(id, b1, b2, b3, u1, u2, u3, u4, bool1, state, owner) =  asset.getAssetById(assetId);
        //check scenario when there is no id in map
        return sha256(id, b1, b2, b3, u1, u2, bool1) == smartAssetPriceById[assetId].hash;
    }

    /**
     * @dev Setter for the SmartAsset contract address
     * @param contractAddress Address of the SmartAsset contract
     */
    function setSmartAssetAddr(address contractAddress) onlyOwner returns (bool result) {
        smartAssetAddr = contractAddress;
        if (contractAddress == address(0)) {
            throw;
        } else {
            smartAssetAddr = contractAddress;
            return true;
        }
    }

    /**
     * @dev Setter for the Car base price - parameter for car price calculation
     * @param price Base price of the car
     */
    function setBaseCarPrice(uint price) onlyOwner returns (bool result) {
        BASE_CAR_PRICE = price;
        return true;
    }

    /**
     * @dev Setter for the Car min price - parameter for car price calculation
     * @param price Min price of the car
     */
    function setMinCarPrice(uint price) onlyOwner returns (bool result) {
        MIN_CAR_PRICE = price;
        return true;
    }

    /**
     * @dev Formula for car price calculation
     */
    function _calculateAssetPrice(uint u1, uint u2, bool bool1) constant private returns (uint price) {
        return max(BASE_CAR_PRICE - u1 / 10 - u2 * 100 - boolToInt(bool1) * BASE_CAR_PRICE / 3, MIN_CAR_PRICE);
    }

    /**
     * @dev Max function
     */
    function max(uint a, uint b) private returns (uint) {
        return a > b ? a : b;
    }

    /**
     * @dev Transforms bool value to uint
     */
    function boolToInt(bool input) private returns (uint) {
        return input == true ? 1 : 0;
    }
}