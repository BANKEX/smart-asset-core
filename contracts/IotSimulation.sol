pragma solidity ^0.4.10;

import 'zeppelin-solidity/contracts/lifecycle/Destructible.sol';

/**
 * Interface for SmartAsset contract
 */
contract CarAssetLogicInterface {
    function updatePriceViaIotSimulator(
    uint id,
    uint millage,
    uint damaged,
    bool smokingCar,
    uint longitude,
    uint latitude
    );

    function updateAvailabilityViaIotSimulator(uint id, bool availability);
}

/**
 * @title IotSimulation contract
 */
contract IotSimulation is Destructible{
    address private carAssetLogicAddr;
    uint private hundred = 100;
    uint private thousand = 1000;


    /**
     * @dev Generates IoT data for specified vinId and stores it using SmartAsset interface
     * @param id Vehicle identification number
     * @return result Execution result
     */
    function generateIotOutput(uint id, uint salt) returns (bool result) {
        require(id != 0);
        require(carAssetLogicAddr != address(0));

        uint number = id + salt;
        CarAssetLogicInterface carAssetLogic = CarAssetLogicInterface(carAssetLogicAddr);
        carAssetLogic.updatePriceViaIotSimulator(
            id,
            generateMillageResult(number),
            generateDamageResult(number),
            generateSmokingCarResult(number),
            generateLongitudeResult(number),
            generateLatitudeResult(number)
        );
        return true;
    }

    /**
     * @dev Generates IoT availability for specified vinId and stores it using SmartAsset interface
     * @param id Vehicle identification number
     * @return result Execution result
     */
    function generateIotAvailability(uint id, bool availability) returns (bool result) {
        require(id != 0);
        require(carAssetLogicAddr != address(0));

        CarAssetLogicInterface carAssetLogic = CarAssetLogicInterface(carAssetLogicAddr);
        carAssetLogic.updateAvailabilityViaIotSimulator(
            id,
            availability
        );
        return true;
    }

    /**
     * @dev Generates millage result base on provided number
     * @param num Number that is used for result calculation
     * @return millage Millage value
     */
    function generateMillageResult(uint num) constant private returns (uint millage) {
        if (num < thousand) {
            return num * thousand;
        } else {
            return (num % thousand) * thousand;
        }
    }

    /**
     * @dev Generates damage result base on provided number
     * @param num Number that is used for result calculation
     * @return damage Damage value
     */
    function generateDamageResult(uint num) constant private returns (uint damage) {
        if (num < hundred) {
            return num;
        } else {
            return (num % hundred);
        }
    }

    /**
     * @dev Generates boolean isSmokingCar result base on provided number
     * @param num Number that is used for result calculation
     * @return smokingCar True if smoking was done in car otherwise - false
     */
    function generateSmokingCarResult(uint num) constant private returns (bool smokingCar) {
        if (num % 2 == 1) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Generates latitude result base on provided number
     * @param num Number that is used for result calculation
     * @return latitude Latitude value
     */
    function generateLatitudeResult(uint num) constant private returns (uint latitude) {
        return num * num * num % hundred;
    }

    /**
     * @dev Generates longitude result base on provided number
     * @param num Number that is used for result calculation
     * @return longitude Longitude value
     */
    function generateLongitudeResult(uint num) constant private returns (uint longitude) {
        return num * num % hundred;
    }

    /**
     * @dev Setter for SmartAsset contract address.
     * @param contractAddress address to be set
     * @return result Execution result
     */
    function setCarAssetLogicAddr(address contractAddress) onlyOwner returns (bool result) {
        require(contractAddress != address(0));
        carAssetLogicAddr = contractAddress;
        return true;
    }
}
