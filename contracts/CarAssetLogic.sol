pragma solidity ^0.4.10;

import "./BaseAssetLogic.sol";


contract IotSimulationInterface {
    function generateIotOutput(uint id, uint salt) returns (bool result);
    function generateIotAvailability(uint id, bool availability) returns (bool result);
}

/**
 * @title Car smart asset logic  contract
 */
contract CarAssetLogic is BaseAssetLogic {
    uint private BASE_CAR_PRICE = 10000;

    uint private MIN_CAR_PRICE = 100;

    address private iotSimulationAddr;


    /**
    * Coefficient to calculate delivery price. E.g price = distance * coefficient
    */
    uint coefficient;

    /**
    * Default coefficient.
    *@see coefficient
    */
    uint DEFAULT_COEFFICIENT = 2226389000000000;

    /**
    * City that have been added to this contract with their lat longs
    */
    bytes32[] cities;

    // Definition of Smart asset price data object
    struct SmartAssetPriceData {
    uint price;
    bytes32 hash;
    }

    // Definition of Smart asset price data object
    struct SmartAssetAvailabilityData {
    bool availability;
    bytes32 hash;
    }

    /**
     * Construct encapsulating latitude and longitude pair
     */
    struct LatLong {
    uint lat;
    uint long;
    }


    // Smart asset by its identifier
    mapping (uint => SmartAssetPriceData) smartAssetPriceById;

    // Smart asset by its identifier
    mapping (uint => SmartAssetAvailabilityData) smartAssetAvailabilityById;

    // Mapping city to its latitude longitude pair
    mapping (bytes32 => LatLong) cityMapping;


    /**
     * Check whether IotSimulator contract executes method or not
     */
    modifier onlyIotSimulator {
        require(msg.sender == iotSimulationAddr);
        _;
    }


    function CarAssetLogic() {
        cityMapping["Moscow"] = LatLong(55, 37);
        cities.push("Moscow");

        cityMapping["Saint-Petersburg"] = LatLong(59, 30);
        cities.push("Saint-Petersburg");


        cityMapping["Kiev"] = LatLong(50, 30);
        cities.push("Kiev");

        cityMapping["Lviv"] = LatLong(49, 24);
        cities.push("Lviv");

        cityMapping["Lublin"] = LatLong(51, 22);
        cities.push("Lublin");
    }

    function onAssetSold(uint assetId)  {
        delete smartAssetPriceById[assetId];
    }

    function calculateAssetPrice(uint assetId)  returns (uint) {
        var(b1, b2, b3, u1, u2, u3, u4, bool1, state, owner) = getById(assetId);
        SmartAssetPriceData memory smartAssetPriceData = SmartAssetPriceData(_calculateAssetPrice(u1, u2, bool1), sha256(b1, b2, b3, u1, u2, u3, u4, bool1));
        smartAssetPriceById[assetId] = smartAssetPriceData;
        return _calculateAssetPrice(u1, u2, bool1);
    }

    function getSmartAssetPrice(uint id) constant returns (uint price) {
        //check scenario when there is no id in map
        return smartAssetPriceById[id].price;
    }

    function isAssetTheSameState(uint assetId) constant returns (bool modified) {
        var(b1, b2, b3, u1, u2, u3, u4, bool1, state, owner) = getById(assetId);
        //check scenario when there is no id in map
        return sha256(b1, b2, b3, u1, u2, u3, u4, bool1) == smartAssetPriceById[assetId].hash;
    }

    /**
        * Gets all cities that have been added to this contract
        *@return cities all cities that have been added to this contract
        */
    function getAvailableCities() constant returns (bytes32[]) {
        return cities;
    }

    function calculateDeliveryPrice(uint id, bytes32 cityName) constant returns (uint) {
        LatLong latLong = cityMapping[cityName];

        var (b1, b2, b3, u1, u2, long, lat, bool1, state, owner) = getById(id);

        if (coefficient == 0)
        coefficient = DEFAULT_COEFFICIENT;

        return ((max(latLong.lat, lat)) + (max(latLong.long, long))) * coefficient * 1 wei;

    }

    /**
     * @dev Function to updates Smart Asset IoT availability
     */
    function updateAvailabilityViaIotSimulator(
    uint id,
    bool availability
    ) onlyIotSimulator()
    {
        smartAssetAvailabilityById[id].availability = availability;
    }

    /**
     * @dev Function to force run update of external params
     */
    function forceUpdateFromExternalSource(uint id) {
        IotSimulationInterface iotSimulation = IotSimulationInterface(iotSimulationAddr);
        iotSimulation.generateIotOutput(id, 0);
        iotSimulation.generateIotAvailability(id, true);
    }

    /**
     * @dev Function to updates Smart Asset IoT params
     */
    function updatePriceViaIotSimulator(
    uint id,
    uint millage,
    uint damaged,
    bool smokingCar,
    uint longitude,
    uint latitude
    ) onlyIotSimulator()
    {
        SmartAssetInterface asset = SmartAssetInterface(smartAssetAddr);
        asset.updateFromExternalSource(id, millage, damaged, smokingCar, longitude, latitude);
    }

    function getSmartAssetAvailability(uint id) constant returns (bool availability) {
        return smartAssetAvailabilityById[id].availability;
    }

    /**
    * Adds city with lat long to this contract. If a city has already been added replaces old
    * lat long with the new one
    *@param cityName name of the city to be added
    *@param lat latitude of the city to be added
    *@param long longitude of the city to be added
    */
    function addCity(bytes32 cityName, uint lat, uint long) onlyOwner() {
        LatLong latLong = cityMapping[cityName];
        if (latLong.lat == 0x0 && latLong.long == 0x0) {
            cities.push(cityName);
        }

        cityMapping[cityName] = LatLong(lat, long);
    }

    /**
    * Sets coefficient for delivery price calculation in wei
    *e.g 2226389000000000 ~ 0,0022 ether ~ 0.5 $
    * @param _wei the coefficient to set
    */
    function setCoefficientInWei(uint _wei) onlyOwner() {
        coefficient = _wei;
    }


    /**
     * @dev Setter for the SmartAsset contract address
     * @param contractAddress Address of the IotSimulation contract
     */
    function setIotSimulationAddr(address contractAddress) onlyOwner returns (bool result) {
        require(contractAddress != address(0));
        iotSimulationAddr = contractAddress;
        return true;
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
