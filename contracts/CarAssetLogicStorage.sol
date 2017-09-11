pragma solidity ^0.4.15;

import 'zeppelin-solidity/contracts/lifecycle/Destructible.sol';


contract CarAssetLogicStorage is Destructible {

    address carAssetLogic;

    struct SmartAssetPriceData {
        uint price;
        bytes32 hash;
    }

    struct SmartAssetAvailabilityData {
        bool availability;
        bytes32 hash;
    }

    mapping (uint => SmartAssetPriceData) smartAssetPriceById;

    mapping (uint => SmartAssetAvailabilityData) smartAssetAvailabilityById;

    modifier onlyCarAssetLogic() {
        require(msg.sender == carAssetLogic);
        _;
    }

    function deleteAssetPriceById(uint24 assetId) onlyCarAssetLogic {
        delete smartAssetPriceById[assetId];
    }

    function setSmartAssetPriceData(uint24 assetId, uint price, bytes32 hash) onlyCarAssetLogic {
        smartAssetPriceById[assetId] = SmartAssetPriceData(price, hash);
    }

    function getSmartAssetPriceData(uint24 assetId) onlyCarAssetLogic constant returns (uint, bytes32) {
        return (smartAssetPriceById[assetId].price, smartAssetPriceById[assetId].hash);
    }

    function setSmartAssetAvailabilityData(uint24 assetId, bool availability) onlyCarAssetLogic {
        smartAssetAvailabilityById[assetId].availability = availability;
    }

    function getSmartAssetAvailability(uint24 assetId) onlyCarAssetLogic constant returns(bool) {
        return smartAssetAvailabilityById[assetId].availability;
    }

    function setCarAssetLogic(address _carAssetLogic) onlyOwner {
        carAssetLogic = _carAssetLogic;
    }


}
