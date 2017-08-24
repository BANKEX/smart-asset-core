pragma solidity ^0.4.10;

import "./BaseAssetLogic.sol";
import "./CarAssetLogicStorage.sol";
import '../oraclize/oraclizeAPI_0.4.sol';
import 'jsmnsol-lib/JsmnSolLib.sol';


contract IotSimulationInterface {
    function generateIotOutput(uint24 id, uint salt) returns (bool result);
    function generateIotAvailability(uint24 id, bool availability) returns (bool result);
}

/**
 * @title Car smart asset logic  contract
 */
contract CarAssetLogic is BaseAssetLogic, usingOraclize {
    uint private BASE_CAR_PRICE = 10000;

    uint private MIN_CAR_PRICE = 100;

    address private iotSimulationAddr;

    CarAssetLogicStorage carAssetLogicStorage;


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

    /**
     * Construct encapsulating latitude and longitude pair
     */
    struct LatLong {
    uint lat;
    uint long;
    }

    // Mapping city to its latitude longitude pair
    mapping (bytes32 => LatLong) cityMapping;


    /**
     * Check whether IotSimulator contract executes method or not
     */
    modifier onlyIotSimulator {
        require(msg.sender == iotSimulationAddr);
        _;
    }

    function __callback(bytes32 myid, string result) {
        require(msg.sender == oraclize_cbAddress());

        bytes32 imageUrl = stringToBytes32(result);

        uint24 assetId = carAssetLogicStorage.getAssetIdViaOraclizeId(myid);

        updateViaIotSimulator(assetId, "65.1111", "56.2324", imageUrl);
        updateAvailabilityViaIotSimulator(assetId, true);
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

    function onAssetSold(uint24 assetId) onlySmartAssetRouter {
        carAssetLogicStorage.deleteAssetPriceById(assetId);
    }

    function calculateAssetPrice(uint24 assetId) onlySmartAssetRouter returns (uint) {
        var(timestamp, docUrl, smoker, email, model, vin, color, millage, state, owner) = getById(assetId);
        carAssetLogicStorage.setSmartAssetPriceData(assetId, _calculateAssetPrice(millage, smoker), sha256(timestamp, docUrl, smoker, email, model, vin, color, millage));

        return _calculateAssetPrice(millage, smoker);
    }

    function getSmartAssetPrice(uint24 id) constant returns (uint) {
        var (price, hash) = carAssetLogicStorage.getSmartAssetPriceData(id);

        return price;
    }

    function isAssetTheSameState(uint24 assetId) onlySmartAssetRouter constant returns (bool modified) {
        var(timestamp, docUrl, smoker, email, model, vin, color, millage, state, owner) = getById(assetId);
        var (price, hash) = carAssetLogicStorage.getSmartAssetPriceData(assetId);

        return sha256(timestamp, docUrl, smoker, email, model, vin, color, millage) == hash;
    }

    /**
        * Gets all cities that have been added to this contract
        *@return cities all cities that have been added to this contract
        */
    function getAvailableCities() constant returns (bytes32[]) {
        return cities;
    }

    function calculateDeliveryPrice(uint24 id, bytes32 cityName) onlySmartAssetRouter constant returns (uint) {
        LatLong latLong = cityMapping[cityName];
        SmartAssetInterface asset = SmartAssetInterface(smartAssetAddr);

        var (latitude, longitude, imageUrl, assetType) = asset.getAssetIotById(id);

        if (coefficient == 0)
        coefficient = DEFAULT_COEFFICIENT;

        return ((max(latLong.lat, uint(latitude))) + (max(latLong.long, uint(longitude)))) * coefficient * 1 wei;

    }

    /**
     * @dev Function to updates Smart Asset IoT availability
     */
    function updateAvailabilityViaIotSimulator(uint24 id, bool availability) private {
        carAssetLogicStorage.setSmartAssetAvailabilityData(id, availability);
    }

    /**
     * @dev Function to force run update of external params
     */
    function forceUpdateFromExternalSource(uint24 id, string param) onlySmartAssetRouter {
        string memory url   = strConcat("json(http://dev-web-prototype-bankex.azurewebsites.net/api/dh/", param, ").0.parameters.imageUrl");
        bytes32 oraclizeId = oraclize_query("URL", url);
        carAssetLogicStorage.setOraclizeIdToAssetId(oraclizeId, id);
    }

    /**
     * @dev Function to updates Smart Asset IoT params
     */
    function updateViaIotSimulator(uint24 id, bytes11 latitude, bytes11 longitude, bytes32 imageUrl) private {
        SmartAssetInterface asset = SmartAssetInterface(smartAssetAddr);
        asset.updateFromExternalSource(id, latitude, longitude, imageUrl);
    }

    function getSmartAssetAvailability(uint24 id) constant returns (bool availability) {
        return carAssetLogicStorage.getSmartAssetAvailability(id);
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
    function _calculateAssetPrice(uint millage, uint8 smoker) constant private returns (uint price) {
        return max(BASE_CAR_PRICE - millage / 10 - smoker * BASE_CAR_PRICE / 3, MIN_CAR_PRICE);
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

    function setCarAssetLogicStorage(address _carAssetLogicStorage) onlyOwner {
        carAssetLogicStorage = CarAssetLogicStorage(_carAssetLogicStorage);
    }

    function stringToBytes32(string source) returns (bytes32 result) {
        assembly {
            result := mload(add(source, 32))
        }
    }
}
