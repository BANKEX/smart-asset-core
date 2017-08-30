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
    uint private MAX_CAR_PRICE = 10000;

    address private iotSimulationAddr;

    CarAssetLogicStorage carAssetLogicStorage;

    string public endpoint = "https://dev-web-prototype-bankex.azurewebsites.net/api/dh/";

    /**
    * Coefficient to calculate delivery price. E.g price = distance * coefficient
    */
    uint coefficient;

    /**
    * Coefficient to calculate car price.
    */
    uint priceCoefficient = 4452778000000000;

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

        var (status, tokens, numberOfFoundTokens) = JsmnSolLib.parse(result, 10);

        bytes11 lat = bytes11(getFirst32Bytes(JsmnSolLib.getBytes(result, tokens[2].start, tokens[2].end)));
        bytes32 imageUrl = parseHex(JsmnSolLib.getBytes(result, tokens[4].start, tokens[4].end));
        bool shaked = JsmnSolLib.parseBool(JsmnSolLib.getBytes(result, tokens[6].start, tokens[6].end));
        bytes11 long = bytes11(getFirst32Bytes(JsmnSolLib.getBytes(result, tokens[8].start, tokens[8].end)));


        uint24 assetId = carAssetLogicStorage.getAssetIdViaOraclizeId(myid);

        carAssetLogicStorage.setSmartAssetAvailabilityData(assetId, shaked);

        SmartAssetInterface asset = SmartAssetInterface(smartAssetAddr);
        asset.updateFromExternalSource(assetId, lat, long, imageUrl);
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

    function calculateDeliveryPrice(uint24 id, bytes32 cityName) onlySmartAssetRouter constant returns (uint) {
        LatLong latLong = cityMapping[cityName];
        SmartAssetInterface asset = SmartAssetInterface(smartAssetAddr);

        var (latitude, longitude, imageUrl, assetType) = asset.getAssetIotById(id);

        if (coefficient == 0)
        coefficient = DEFAULT_COEFFICIENT;

        return ((max(latLong.lat, uint(latitude))) + (max(latLong.long, uint(longitude)))) * coefficient * 1 wei;

    }

    /**
     * @dev Function to force run update of external params
     */
    function forceUpdateFromExternalSource(uint24 id, string param) onlySmartAssetRouter {
        string memory url   = strConcat("json(", endpoint , param, ").0.parameters");
        bytes32 oraclizeId = oraclize_query("URL", url, 800000);
        carAssetLogicStorage.setOraclizeIdToAssetId(oraclizeId, id);
    }

    function getSmartAssetAvailability(uint24 id) constant returns (bool availability) {
        return carAssetLogicStorage.getSmartAssetAvailability(id);
    }

    function setEndpoint(string _endpoint) onlyOwner {
        endpoint = _endpoint;
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

    function getFirst32Bytes(string source) returns (bytes32 result) {
        assembly {
            result := mload(add(source, 32))
        }
    }

    function parseHex(string _a) private returns (bytes32) {
        bytes memory bresult = bytes(_a);
        uint mint = 0;

        for (uint i=0; i<bresult.length; i++){
            if ((bresult[i] >= 48)&&(bresult[i] <= 57)){

                mint *= 16;
                mint += uint(bresult[i]) - 48;
            }
            if ((bresult[i] >= 97)&&(bresult[i] <= 102)){

                mint *= 16;
                mint += uint(bresult[i]) - 97 + 10;
            }
        }
        return bytes32(mint);
    }

    function () payable {}
}
