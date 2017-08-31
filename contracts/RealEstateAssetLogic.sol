pragma solidity ^0.4.10;

import "./DhOraclizeBase.sol";

contract RealEstateAssetLogic is DhOraclizeBase {


    function updateAvailability(uint24 assetId, bool availability) internal {
        //no op
    }

    function updateViaIotSimulator(uint24 id, bytes11 latitude, bytes11 longitude, bytes32 imageUrl) {
        SmartAssetInterface asset = SmartAssetInterface(smartAssetAddr);

        asset.updateFromExternalSource(id, latitude, longitude, imageUrl);
    }

    function onAssetSold(uint24 assetId) onlySmartAssetRouter {

    }

    function calculateAssetPrice(uint24 assetId) onlySmartAssetRouter returns (uint) {
        var(timestamp, docUrl, propertyType, email, governmentNumber, _address, _empty, sqm, state, owner) = getById(assetId);
        return 1000 * sqm;
    }

    function getSmartAssetPrice(uint24 id) constant returns (uint) {
        var(timestamp, docUrl, propertyType, email, governmentNumber, _address, _empty,  sqm, state, owner) = getById(id);
        return 1000 * sqm;
    }

    function isAssetTheSameState(uint24 id) onlySmartAssetRouter constant returns (bool modified) {
        return true;
    }

    function calculateDeliveryPrice(uint24 id, bytes32 city) onlySmartAssetRouter constant returns (uint) {
        return 10;
    }

    function getSmartAssetAvailability(uint24 id) constant returns (bool) {
        return true;
    }

}
