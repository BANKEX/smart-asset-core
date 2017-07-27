pragma solidity ^0.4.10;


contract SmartAsset {
    function getAssetLocationById(uint id) constant returns (uint, uint);
}


contract DeliveryRequirements {

    struct LatLong {
        uint lat;
        uint long;
    }

    modifier onlyOwner() {
        if (msg.sender != owner)
        throw;
        else
        _;
    }

    mapping(bytes32 => LatLong) cityMapping;
    bytes32[] cities;
    SmartAsset smartAsset;
    address owner;
    uint coefficient;
    uint DEFAULT_COEFFICIENT = 2226389000000000;

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

    function getAvailableCities() constant returns(bytes32[]) {
        return cities;
    }

    function calculatePrice(uint id, bytes32 cityName) constant returns(uint) {
        LatLong latLong = cityMapping[cityName];

        var (lat2, long2) = smartAsset.getAssetLocationById(id);

        if (coefficient == 0)
        coefficient = DEFAULT_COEFFICIENT;

        return ((getMax(latLong.lat, lat2)) + (getMax(latLong.long, long2))) * coefficient * 1 wei;

    }

    function addCity(bytes32 cityName, uint lat, uint long) onlyOwner() {
        LatLong latLong = cityMapping[cityName];
        if(latLong.lat == 0x0 && latLong.long == 0x0) {
            cities.push(cityName);
        }

        cityMapping[cityName] = LatLong(lat, long);
    }

    function setCoefficientInWei(uint _wei) onlyOwner() {
        coefficient = _wei;
    }

    function getMax(uint a, uint b) private constant returns(uint) {
        if (a > b)
        return a;
        else
        return b;
    }

}
