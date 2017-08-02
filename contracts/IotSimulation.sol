pragma solidity ^0.4.10;


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
}

/**
 * Interface for SmartAssetAvailability contract
 */
contract SmartAssetAvailability {
    function updateViaIotSimulator(
        uint id,
        bool availability);
}


/**
 * @title IotSimulation contract
 */
contract IotSimulation {
    address public owner = msg.sender;
    address private carAssetLogicAddr;
    address private smartAssetAvailabilityAddr;
    uint private hundred = 100;
    uint private thousand = 1000;

    /**
     * Check whether contract owner executes method or not
     */
    modifier onlyOwner {
        if (msg.sender != owner) {throw;} else {_;}
    }

    /**
     * @dev Generates IoT data for specified vinId and stores it using SmartAsset interface
     * @param id Vehicle identification number
     * @return result Execution result
     */
    function generateIotOutput(uint id, uint salt) returns (bool result) {
        if (id == 0) {
            throw;
        }
        if (carAssetLogicAddr == address(0)) {
            throw;
        }

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
        if (id == 0) {
            throw;
        }
        if (smartAssetAvailabilityAddr == address(0)) {
            throw;
        }

        SmartAssetAvailability smartAssetAvailability = SmartAssetAvailability(smartAssetAvailabilityAddr);
        smartAssetAvailability.updateViaIotSimulator(
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
        carAssetLogicAddr = contractAddress;
        if (contractAddress == address(0)) {
            throw;
        } else {
            carAssetLogicAddr = contractAddress;
            return true;
        }
    }

    /**
     * @dev Setter for SmartAssetAvailability contract address.
     * @param contractAddress address to be set
     * @return result Execution result
     */
    function setSmartAssetAvailabilityAddr(address contractAddress) onlyOwner returns (bool result) {
        smartAssetAvailabilityAddr = contractAddress;
        if (contractAddress == address(0)) {
            throw;
        } else {
            smartAssetAvailabilityAddr = contractAddress;
            return true;
        }
    }
}
