pragma solidity ^0.4.0;

import 'zeppelin-solidity/contracts/lifecycle/Destructible.sol';


contract SmartAssetStorage is Destructible {

    address smartAsset;

    struct SmartAssetData {
        uint24 id;
        bytes32 b1;
        bytes32 b2;
        bytes32 b3;
        uint u1;
        uint u2;
        uint u3;
        uint u4;
        bool bool1;
        uint8 state;
        address owner;
        uint indexInSmartAssetsByOwner;
        uint indexInSmartAssetsOnSale;
    }

    mapping (uint => SmartAssetData) smartAssetById;

    mapping (address => mapping (bytes32 => SmartAssetData[])) smartAssetsByOwner;

    mapping (bytes32 => SmartAssetData[]) smartAssetsOnSale;

    function setSmartAsset(address _smartAsset) onlyOwner {
        smartAsset = _smartAsset;
    }
}
