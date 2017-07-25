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

    mapping(bytes32 => LatLong) countryMapping;
    bytes32[] countries;
    SmartAsset smartAsset;
    address owner;
    uint coefficient;
    uint DEFAULT_COEFFICIENT = 2226389000000000;

    function DeliveryRequirements(address _address) {
        owner = msg.sender;
        smartAsset = SmartAsset(_address);

        countryMapping["Russia, Moscow"] = LatLong(55, 37);
        countries.push("Russia, Moscow");

        countryMapping["Russia, Saint-Petersburg"] = LatLong(59, 30);
        countries.push("Russia, Saint-Petersburg");


        countryMapping["Ukraine, Kiev"] = LatLong(50, 30);
        countries.push("Ukraine, Kiev");

        countryMapping["Ukraine, Kiev"] = LatLong(50, 30);
        countries.push("Ukraine, Kiev");

        countryMapping["Ukraine, Lviv"] = LatLong(49, 24);
        countries.push("Ukraine, Lviv");

        countryMapping["Poland, Lublin"] = LatLong(51, 22);
        countries.push("Poland, Lublin");
    }

    function getAvailableCountries() constant returns(bytes32[]) {
        return countries;
    }

    function calculatePrice(uint id, bytes32 country) constant returns(uint) {
        LatLong latLong = countryMapping[country];

        var (lat2, long2) = smartAsset.getAssetLocationById(id);

        if (coefficient == 0)
        coefficient = DEFAULT_COEFFICIENT;

        return ((getMax(latLong.lat, lat2)) + (getMax(latLong.long, long2))) * coefficient * 1 wei;

    }

    function addCountry(bytes32 country, uint lat, uint long) onlyOwner() {
        countryMapping[country] = LatLong(lat, long);
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
