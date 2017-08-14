pragma solidity ^0.4.10;

import "./BaseAssetLogic.sol";


contract RealEstateAssetLogic is BaseAssetLogic {


    function updateViaIotSimulator(uint24 id, bytes11 latitude, bytes11 longitude, bytes6 imageUrl) {
        SmartAssetInterface asset = SmartAssetInterface(smartAssetAddr);

        asset.updateFromExternalSource(id, latitude, longitude, imageUrl);
    }

    function forceUpdateFromExternalSource(uint24 id) onlySmartAssetRouter {
        updateViaIotSimulator(id, bytes11(id + 1), bytes11(id + 2), "/link");
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
