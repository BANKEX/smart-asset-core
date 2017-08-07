pragma solidity ^0.4.10;

import "./BaseAssetLogic.sol";


contract RealEstateAssetLogic is BaseAssetLogic {


    function updatePriceViaIotSimulator(uint id, uint u1, uint u2, bool smoker , uint u3, uint u4) {
        SmartAssetInterface asset = SmartAssetInterface(smartAssetAddr);

        asset.updateViaIotSimulator(id, u1, u2, smoker, u3, u4);
    }

    function onAssetSold(uint assetId) {

    }

    function calculateAssetPrice(uint assetId) returns (uint) {
        var(id, b1, b2, b3, u1, u2, u3, u4, bool1, state, owner) = getById(assetId);
        return u1*u2 - u3*u4;
    }

    function getSmartAssetPrice(uint id) constant returns (uint) {
        var(assetId, b1, b2, b3, u1, u2, u3, u4, bool1, state, owner) = getById(id);
        return u1*u2 - u3*u4;
    }

    function checkSmartAssetModification(uint id) constant returns (bool modified) {
        return true;
    }

    function calculateDeliveryPrice(uint id, bytes32 city) constant returns (uint) {
        return 10;
    }

    function getSmartAssetAvailability(uint id) constant returns (bool) {
        return true;
    }

}
