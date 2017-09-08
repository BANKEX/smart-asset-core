pragma solidity ^0.4.15;

import "./DhOraclizeBase.sol";
import "./CarAssetLogicStorage.sol";


contract IotSimulationInterface {
    function generateIotOutput(uint24 id, uint salt) returns (bool result);
    function generateIotAvailability(uint24 id, bool availability) returns (bool result);
}

/**
 * @title Car smart asset logic  contract
 */
contract CarAssetLogic is DhOraclizeBase {
    uint private BASE_CAR_PRICE = 10000;

    uint private MIN_CAR_PRICE = 100;
    uint private MAX_CAR_PRICE = 10000;

    address private iotSimulationAddr;

    CarAssetLogicStorage carAssetLogicStorage;

    /**
    * Coefficient to calculate delivery price. E.g price = distance * coefficient
    */
    uint coefficient = 2226389000000000;

    /**
    * Coefficient to calculate car price.
    */
    uint priceCoefficient = 4452778000000000;

    /**
    * City that have been added to this contract with their lat longs
    */
    bytes32[] cities;

    /**
     * Construct encapsulating latitude and longitude pair
     */
    struct LatLong {
    bytes11 lat;
    bytes11 long;
    bool initialized;
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

    function CarAssetLogic() {
        cityMapping["Moscow"] = LatLong("55", "37", true);
        cities.push("Moscow");

        cityMapping["Saint-Petersburg"] = LatLong("59", "30", true);
        cities.push("Saint-Petersburg");


        cityMapping["Kiev"] = LatLong("50", "30", true);
        cities.push("Kiev");

        cityMapping["Lviv"] = LatLong("49", "24", true);
        cities.push("Lviv");

        cityMapping["Lublin"] = LatLong("51", "22", true);
        cities.push("Lublin");

    }

    function updateAvailability(uint24 assetId, bool availability) internal {
        carAssetLogicStorage.setSmartAssetAvailabilityData(assetId, availability);
    }

    function onAssetSold(uint24 assetId) onlySmartAssetRouter {
        carAssetLogicStorage.deleteAssetPriceById(assetId);
    }

    function calculateAssetPrice(uint24 assetId) onlySmartAssetRouter returns (uint) {
        var(timestamp, docUrl, smoker, email, model, vin, color, millage, state, owner) = getById(assetId);
        uint price = _calculateAssetPrice(millage, smoker);
        carAssetLogicStorage.setSmartAssetPriceData(assetId, price, sha256(timestamp, docUrl, smoker, email, model, vin, color, millage));

        return price;
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

    function calculateDeliveryPrice(uint24 id, bytes11 latitudeTo, bytes11 longitudeTo) onlySmartAssetRouter constant returns (uint) {
        return 10 * coefficient * 1 wei;

    }

    function calculateDeliveryPrice (uint24 id, bytes32 cityName) onlySmartAssetRouter constant returns(uint) {
        LatLong latLong = cityMapping[cityName];
        return calculateDeliveryPrice(id, latLong.lat, latLong.long);
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
    function addCity(bytes32 cityName, bytes11 lat, bytes11 long) onlyOwner() {
        LatLong latLong = cityMapping[cityName];
        if (latLong.initialized == false) {
            cities.push(cityName);
        }

        cityMapping[cityName] = LatLong(lat, long, true);
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
    * Sets coefficient for delivery price calculation in wei
    *e.g 2226389000000000 ~ 0,0022 ether ~ 0.5 $
    * @param _wei the coefficient to set
    */
    function setPriceCoefficientInWei(uint _wei) onlyOwner() {
        priceCoefficient = _wei;
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
     * @dev Setter for the Car max price - parameter for car price calculation
     * @param price Max price of the car
     */
    function setMaxCarPrice(uint price) onlyOwner returns (bool result) {
        MAX_CAR_PRICE = price;
        return true;
    }

    /**
     * @dev Formula for car price calculation
     */
    function _calculateAssetPrice(uint millage, uint8 smoker) constant private returns (uint price) {
        return min(max(BASE_CAR_PRICE - millage / 100 - smoker * BASE_CAR_PRICE / 3, MIN_CAR_PRICE), MAX_CAR_PRICE) * priceCoefficient * 1 wei;
    }

    /**
     * @dev Max function
     */
    function max(uint a, uint b) private returns (uint) {
        return a > b ? a : b;
    }

    /**
     * @dev Min function
     */
    function min(uint a, uint b) private returns (uint) {
        return a < b ? a : b;
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

}
