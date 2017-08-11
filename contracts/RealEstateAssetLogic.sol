pragma solidity ^0.4.10;

import "./BaseAssetLogic.sol";


contract RealEstateAssetLogic is BaseAssetLogic {


    function updateViaIotSimulator(uint id, uint u1, uint u2, bool smoker , uint u3, uint u4) {
        SmartAssetInterface asset = SmartAssetInterface(smartAssetAddr);

        asset.updateFromExternalSource(id, u1, u2, smoker, u3, u4);
    }

    function forceUpdateFromExternalSource(uint id) onlySmartAssetRouter {
        updateViaIotSimulator(id, id + 1, id + 2, true, id +3, id + 4);
    }

    function onAssetSold(uint assetId) onlySmartAssetRouter {

    }

    function calculateAssetPrice(uint assetId) onlySmartAssetRouter returns (uint) {
        var(b1, b2, b3, u1, u2, u3, u4, bool1, state, owner) = getById(assetId);
        return u1*u2 - u3*u4;
    }

    function getSmartAssetPrice(uint id) constant returns (uint) {
        var(b1, b2, b3, u1, u2, u3, u4, bool1, state, owner) = getById(id);
        return u1*u2 - u3*u4;
    }

    function isAssetTheSameState(uint id) onlySmartAssetRouter constant returns (bool modified) {
        return true;
    }

    function calculateDeliveryPrice(uint id, bytes32 city) onlySmartAssetRouter constant returns (uint) {
        return 10;
    }

    function getSmartAssetAvailability(uint id) constant returns (bool) {
        return true;
    }

}
