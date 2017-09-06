pragma solidity ^0.4.10;

import 'zeppelin-solidity/contracts/lifecycle/Destructible.sol';


contract SmartAssetRouterStorage is Destructible {

    address smartAssetRouterAddress;
    mapping (uint24 => bytes16) assetTypeById;

    modifier onlySmartAssetRouter() {
        require(msg.sender == smartAssetRouterAddress);
        _;
    }

    function getAssetType(uint24 assetId) constant returns (bytes16) {
        return assetTypeById[assetId];
    }

    function setAssetType(uint24 assetId, bytes16 assetType) onlySmartAssetRouter {
        assetTypeById[assetId] = assetType;
    }

    function setSmartAssetRouterAddress(address _smartAssetRouterAddress) onlyOwner {
        smartAssetRouterAddress = _smartAssetRouterAddress;
    }

}
