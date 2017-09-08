pragma solidity ^0.4.15;

import './CarAssetLogicStorage.sol';

contract CarAssetLogicStorageMock is CarAssetLogicStorage {

    function getSmartAssetAvailability(uint24 assetId) onlyCarAssetLogic constant returns(bool) {
        return true;
    }
}
