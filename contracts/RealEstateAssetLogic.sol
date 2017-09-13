pragma solidity ^0.4.15;

import "./DhOraclizeBase.sol";


contract RealEstateAssetLogic is DhOraclizeBase {

    /**
    * Coefficient to calculate apple device price.
    */
    uint priceCoefficient = 4452778000000000;

    function updateAvailability(uint24 assetId, bool availability) internal {
        //no op
    }


    function onAssetSold(uint24 assetId) onlySmartAssetRouter {

    }

    function calculateAssetPrice(uint24 assetId) onlySmartAssetRouter returns (uint) {
        var(timestamp, year, docUrl, propertyType, email, governmentNumber, _address, _empty, sqm, state, owner, assetType) = getById(assetId);
        return priceCoefficient * sqm;
    }

    function getSmartAssetPrice(uint24 id) constant returns (uint) {
        var(timestamp, year, docUrl, propertyType, email, governmentNumber, _address, _empty,  sqm, state, owner, assetType) = getById(id);
        return priceCoefficient * sqm;
    }

    function isAssetTheSameState(uint24 id) onlySmartAssetRouter constant returns (bool modified) {
        return true;
    }

    function calculateDeliveryPrice(uint24 id, bytes32 city) onlySmartAssetRouter constant returns (uint) {
        return priceCoefficient;
    }

    function calculateDeliveryPrice(uint24 id, bytes11 latitudeTo, bytes11 longitudeTo) onlySmartAssetRouter constant returns (uint) {
        return priceCoefficient;
    }

    function getSmartAssetAvailability(uint24 id) constant returns (bool) {
        return true;
    }

}
