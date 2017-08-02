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

}


/**
 * @title Car smart asset logic  contract
 */
contract CarAssetLogic {
    uint private BASE_CAR_PRICE = 10000;
    uint private MIN_CAR_PRICE = 100;
    address public owner = msg.sender;
    address private smartAssetAddr;
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
    mapping(bytes32 => LatLong) cityMapping;

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
     * Check whether IotSimulator contract executes method or not
     */
    modifier onlyIotSimulator {
        if (msg.sender != iotSimulationAddr) {throw;} else {_;}
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


    /**
     * @dev Calculates price base on formula1
     * @param assetId Id of smart asset
     */
    function removeAssetPrice(uint assetId)  onlySmartAsset {
        delete smartAssetPriceById[assetId];
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
        return sha256(b1, b2, b3, u1, u2, u3, u4, bool1) == smartAssetPriceById[assetId].hash;
    }

    /**
        * Gets all cities that have been added to this contract
        *@return cities all cities that have been added to this contract
        */
    function getAvailableCities() constant returns(bytes32[]) {
        return cities;
    }

    /**
    * Calculates delivery price based the smart asset id and city to which delivery is needed
    *@param id smart asset id
    *@param cityName name of the city where smart asset should be delivered to
    *@return delivery price
    */
    function calculateDeliveryPrice(uint id, bytes32 cityName) constant returns(uint) {
        LatLong latLong = cityMapping[cityName];
        SmartAssetInterface asset = SmartAssetInterface(smartAssetAddr);

        var (lat2, long2) = asset.getAssetLocationById(id);

        if (coefficient == 0)
        coefficient = DEFAULT_COEFFICIENT;

        return ((max(latLong.lat, lat2)) + (max(latLong.long, long2))) * coefficient * 1 wei;

    }

    /**
     * @dev Function to updates Smart Asset IoT availability
     */
    function updateViaIotSimulator(
    uint id,
    bool availability
    ) onlyIotSimulator()
    {
        smartAssetAvailabilityById[id].availability = availability;
    }

    /**
     * @dev Returns IoT availability of the asset
     * @param id Id of smart asset
     */
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
     * @param contractAddress Address of the IotSimulation contract
     */
    function setIotSimulationAddr(address contractAddress) onlyOwner returns (bool result) {
        if (contractAddress == address(0)) {
            throw;
        } else {
            iotSimulationAddr = contractAddress;
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
