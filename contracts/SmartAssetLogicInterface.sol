pragma solidity ^0.4.10;

contract SmartAssetLogicInterface {
    function onAssetSold(uint assetId);

    function calculateAssetPrice(uint assetId) returns (uint);

    function getSmartAssetPrice(uint id) constant returns (uint);

    function isAssetTheSameState(uint id) constant returns (bool sameState);

    function calculateDeliveryPrice(uint id, bytes32 city) constant returns (uint);

    function getSmartAssetAvailability(uint id) constant returns (bool);
}
