pragma solidity ^0.4.15;

import './SmartAssetToken.sol';
import 'zeppelin-solidity/contracts/lifecycle/Destructible.sol';


contract SmartAssetStorage is Destructible {
    SmartAssetToken token;
    address smartAsset;

    modifier onlySmartAsset() {
        require(msg.sender == smartAsset);
        _;
    }

    struct SmartAssetDataMeta {
        uint24 id;
        uint24 indexInSmartAssetsByOwner;
        uint24 indexInSmartAssetsOnSale;
        uint8 state;
        address owner;
    }

    mapping(uint24 => address) assetsAddresses;
    mapping(uint24 => uint) assetsTimestamp;

    mapping (uint => SmartAssetDataMeta) smartAssetMetaById;

    mapping (address => mapping (bytes32 => uint24[])) smartAssetsByOwner;

    mapping (bytes32 => uint24[]) smartAssetsOnSale;

    uint24 id = 1;

    /** ById set*/
    function setSmartAssetDataManualById(
        address owner,
        uint24 id,
        uint8 year,
        bytes32 docUrl,
        uint8 _type,
        bytes32 email,
        bytes32 b1,
        bytes32 b2,
        bytes32 b3,
        uint u1
    ) onlySmartAsset
    {
        address newAsset = new SmartAssetToken(
        owner,
        year,
        _type,
        docUrl,
        email,
        b1,
        b2,
        b3,
        u1
        );
        assetsAddresses[id] = newAsset;
    }

    function setSmartAssetDataMetaById(
        uint24 id,
        uint24 indexInSmartAssetsByOwner,
        uint24 indexInSmartAssetsOnSale,
        uint8 state,
        address owner
    ) onlySmartAsset
    {
        smartAssetMetaById[id] = SmartAssetDataMeta(
            id,
            indexInSmartAssetsByOwner,
            indexInSmartAssetsOnSale,
            state,
            owner
        );
    }

    function setSmartAssetDataIotById(
        uint24 id,
        bytes11 latitude,
        bytes11 longitude,
        bytes32 imageUrl
    ) onlySmartAsset
    {
        SmartAssetToken token = SmartAssetToken(assetsAddresses[id]);
        token.setSmartAssetDataIot(latitude, longitude, imageUrl);
    }

    function getSmartAssetDataMetaById(uint24 id) constant returns(uint24, uint24, uint8, address) {
        SmartAssetDataMeta data = smartAssetMetaById[id];
        return(data.indexInSmartAssetsByOwner, data.indexInSmartAssetsOnSale, data.state, data.owner);
    }

    function getSmartAssetDataManualById(uint24 id) constant returns(uint8, bytes32, uint8, bytes32, bytes32, bytes32, bytes32, uint) {
        SmartAssetToken token = SmartAssetToken(assetsAddresses[id]);
        return token.getSmartAssetDataManual();
    }

    function getSmartAssetDataIotById(uint24 id) constant returns (bytes11, bytes11, bytes32) {
        SmartAssetToken token = SmartAssetToken(assetsAddresses[id]);
        return token.getSmartAssetDataIot();
    }

    function deleteSmartAssetById(uint24 id) onlySmartAsset {
        delete smartAssetMetaById[id];
    }

    function addSmartAssetByOwner(address owner, bytes16 assetType, uint24 id) onlySmartAsset {
        smartAssetsByOwner[owner][assetType].push(id);
        SmartAssetToken token = SmartAssetToken(assetsAddresses[id]);
        token.transferAssetOwner(owner);
    }

    function addSmartAssetOnSale(bytes16 assetType, uint24 id) onlySmartAsset {
        smartAssetsOnSale[assetType].push(id);
    }

    function deleteSmartAssetByOwner(address owner, bytes16 assetType, uint24 indexInSmartAssetsByOwner) onlySmartAsset {
        delete smartAssetsByOwner[owner][assetType][indexInSmartAssetsByOwner];
    }

    function deleteSmartAssetOnSale(bytes16 assetType, uint24 indexInSmartAssetsOnSale) onlySmartAsset {
        delete smartAssetsOnSale[assetType][indexInSmartAssetsOnSale];
    }

    function isAssetEmpty(uint24 id) constant returns(bool) {
        SmartAssetDataMeta smartAssetDataMeta = smartAssetMetaById[id];
        return smartAssetDataMeta.id == 0;
    }

    function getSmartAssetsOnSaleCount(bytes16 assetType) constant returns (uint24) {
        return uint24(smartAssetsOnSale[assetType].length);
    }

    function getSmartAssetsCountByOwner(address owner, bytes16 assetType) constant returns(uint24) {
        return uint24(smartAssetsByOwner[owner][assetType].length);
    }

    function getId()constant returns(uint24) {
        return id;
    }

    function setId(uint24 _id) onlySmartAsset {
        id = _id;
    }

    function getSmartAssetYear(uint24 id) constant returns(uint8) {
        SmartAssetToken token = SmartAssetToken(assetsAddresses[id]);
        return token.getSmartAssetYear();
    }

    function getSmartAssetDocURl(uint24 id) constant returns(bytes32) {
        SmartAssetToken token = SmartAssetToken(assetsAddresses[id]);
        return token.getSmartAssetDocURl();
    }

    function getSmartAssetType(uint24 id) constant returns(uint8) {
        SmartAssetToken token = SmartAssetToken(assetsAddresses[id]);
        return token.getSmartAssetType();
    }

    function getSmartAssetEmail(uint24 id) constant returns(bytes32) {
        SmartAssetToken token = SmartAssetToken(assetsAddresses[id]);
        return token.getSmartAssetEmail();
    }

    function getSmartAssetb1(uint24 id) constant returns(bytes32) {
        SmartAssetToken token = SmartAssetToken(assetsAddresses[id]);
        return token.getSmartAssetb1();
    }

    function getSmartAssetb2(uint24 id) constant returns(bytes32) {
        SmartAssetToken token = SmartAssetToken(assetsAddresses[id]);
        return token.getSmartAssetb2();
    }

    function getSmartAssetb3(uint24 id) constant returns(bytes32) {
        SmartAssetToken token = SmartAssetToken(assetsAddresses[id]);
        return token.getSmartAssetb3();
    }

    function getSmartAssetu1(uint24 id) constant returns(uint) {
        SmartAssetToken token = SmartAssetToken(assetsAddresses[id]);
        return token.getSmartAssetu1();
    }

    function getSmartAssetState(uint24 id) constant returns(uint8) {
        SmartAssetDataMeta data = smartAssetMetaById[id];
        return(data.state);
    }

    function getSmartAssetOwner(uint24 id) constant returns(address) {
        SmartAssetDataMeta data = smartAssetMetaById[id];
        return(data.owner);
    }

    function getSmartAssetIndexInOnSale(uint24 id) constant returns(uint24) {
        SmartAssetDataMeta data = smartAssetMetaById[id];
        return(data.indexInSmartAssetsOnSale);
    }

    function getSmartAssetIndexInAssetsByOwner(uint24 id) constant returns(uint24) {
        SmartAssetDataMeta data = smartAssetMetaById[id];
        return(data.indexInSmartAssetsByOwner);
    }

    function getSmartAssetTimestamp(uint24 id) constant returns(uint) {
        return assetsTimestamp[id];
    }

    function setSmartAssetTimestamp(uint24 id, uint timestamp) onlySmartAsset {
        assetsTimestamp[id] = timestamp;
    }

    ////////////////////////////////////////
    function getAssetOnSaleAtIndex(bytes16 assetType, uint24 index) constant returns(uint24) {
        return smartAssetsOnSale[assetType][index];
    }

    function getAssetByOwnerAtIndex(address owner, bytes16 assetType, uint24 index) constant returns(uint24) {
        return smartAssetsByOwner[owner][assetType][index];
    }

    function setSmartAsset(address _smartAsset) onlyOwner {
        smartAsset = _smartAsset;
    }
}
