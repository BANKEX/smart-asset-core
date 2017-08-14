pragma solidity ^0.4.10;

import 'zeppelin-solidity/contracts/lifecycle/Destructible.sol';

/**
 * Interface for SmartAsset contract
 */
contract CarAssetLogicInterface {
    function updateViaIotSimulator(uint24 id, bytes11 latitude, bytes11 longitude, bytes6 imageUrl);

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
    function generateIotOutput(uint24 id, uint salt) returns (bool result) {
        require(id != 0);
        require(carAssetLogicAddr != address(0));

        uint number = id + salt;
        CarAssetLogicInterface carAssetLogic = CarAssetLogicInterface(carAssetLogicAddr);
        carAssetLogic.updateViaIotSimulator(
            id,
            generateLongitudeResult(number),
            generateLatitudeResult(number),
            "/link"
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
     * @dev Generates latitude result base on provided number
     * @param num Number that is used for result calculation
     * @return latitude Latitude value
     */
    function generateLatitudeResult(uint num) constant private returns (bytes11 latitude) {
        return bytes11(num * num * num % hundred);
    }

    /**
     * @dev Generates longitude result base on provided number
     * @param num Number that is used for result calculation
     * @return longitude Longitude value
     */
    function generateLongitudeResult(uint num) constant private returns (bytes11 longitude) {
        return bytes11(num * num % hundred);
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
