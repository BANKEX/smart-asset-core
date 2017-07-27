pragma solidity ^0.4.10;


/**
* Smart Asset Contract Interface
*/
contract SmartAsset {
    function getAssetLocationById(uint id) constant returns (uint, uint);
}


/**
* Delivery Requirements Contract (Formula 3)
*/
contract DeliveryRequirements {

    /**
    * Construct encapsulating latitude and longitude pair
    */
    struct LatLong {
        uint lat;
        uint long;
    }

    /**
    * Modifier that allows only owner to perform certain operations
    * e.g function doSomething() onlyOwner() {}
    */
    modifier onlyOwner() {
        if (msg.sender != owner)
        throw;
        else
        _;
    }

    /**
    * Mapping city to its latitude longitude pair
    */
    mapping(bytes32 => LatLong) cityMapping;

    /**
    * City that have been added to this contract with their lat longs
    */
    bytes32[] cities;

    /**
    * Reference to Smart Asset Contract
    */
    SmartAsset smartAsset;

    /**
    * Owner of this contract address. Owner is set during creation of this contract
    *@see function DeliveryRequirements(address _smartAssetAddress)
    */
    address owner;

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
    * Delivery Requirements Contract Constructor that creates an instance of this Smart Contract
    */
    function DeliveryRequirements(address _smartAssetAddress) {
        owner = msg.sender;
        smartAsset = SmartAsset(_smartAssetAddress);

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
    function calculatePrice(uint id, bytes32 cityName) constant returns(uint) {
        LatLong latLong = cityMapping[cityName];

        var (lat2, long2) = smartAsset.getAssetLocationById(id);

        if (coefficient == 0)
        coefficient = DEFAULT_COEFFICIENT;

        return ((getMax(latLong.lat, lat2)) + (getMax(latLong.long, long2))) * coefficient * 1 wei;

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
    * Get max of the two integers passed in
    *@param a first integer
    *@param b second integer
    *@return uint the maximum of the two
    */
    function getMax(uint a, uint b) private constant returns(uint) {
        if (a > b)
        return a;
        else
        return b;
    }

}
