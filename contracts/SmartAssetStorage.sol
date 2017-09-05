pragma solidity ^0.4.0;

import 'zeppelin-solidity/contracts/lifecycle/Destructible.sol';


contract SmartAssetStorage is Destructible {

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

    struct SmartAssetDataManual {
        uint8 year;
        uint8 _type;
        bytes32 docUrl;
        bytes32 email;
        bytes32 b1;
        bytes32 b2;
        bytes32 b3;
        uint u1;
    }

    struct SmartAssetDataIot {
        bytes11 latitude;
        bytes11 longitude;
        bytes32 imageUrl;
    }

    mapping (uint => SmartAssetDataMeta) smartAssetMetaById;

    mapping (uint => SmartAssetDataManual) smartAssetManualById;

    mapping (uint => SmartAssetDataIot) smartAssetIotById;


    mapping (address => mapping (bytes32 => uint24[])) smartAssetsByOwner;

    mapping (bytes32 => uint24[]) smartAssetsOnSale;

    uint24 id = 1;


    /** ById set*/
    function setSmartAssetDataManualById(uint24 id, uint8 year, bytes32 docUrl, uint8 _type, bytes32 email, bytes32 b1, bytes32 b2, bytes32 b3, uint u1) onlySmartAsset {
        smartAssetManualById[id] = SmartAssetDataManual(year, _type, docUrl,  email, b1, b2, b3, u1);
    }

    function setSmartAssetDataMetaById(uint24 id, uint24 indexInSmartAssetsByOwner, uint24 indexInSmartAssetsOnSale, uint8 state, address owner) onlySmartAsset {
        smartAssetMetaById[id] = SmartAssetDataMeta(id, indexInSmartAssetsByOwner, indexInSmartAssetsOnSale, state, owner);
    }


    function setSmartAssetDataIotById(uint24 id, bytes11 latitude, bytes11 longitude, bytes32 imageUrl) onlySmartAsset {
        smartAssetIotById[id] = SmartAssetDataIot(latitude, longitude, imageUrl);
    }


    /** ById get*/
    function getSmartAssetDataMetaById(uint24 id) constant returns(uint24, uint24, uint8, address) {
        SmartAssetDataMeta data = smartAssetMetaById[id];
        return(data.indexInSmartAssetsByOwner, data.indexInSmartAssetsOnSale, data.state, data.owner);
    }

    function getSmartAssetDataManualById(uint24 id) constant returns(uint8, bytes32, uint8, bytes32, bytes32, bytes32, bytes32, uint) {
        SmartAssetDataManual data = smartAssetManualById[id];
        return(data.year, data.docUrl, data._type, data.email, data.b1, data.b2, data.b3, data.u1);
    }

    function getSmartAssetDataIotById(uint24 id) constant returns (bytes11, bytes11, bytes32) {
        SmartAssetDataIot data = smartAssetIotById[id];
        return (data.latitude, data.longitude, data.imageUrl);
    }


    /** ById delete*/
    function deleteSmartAssetById(uint24 id) onlySmartAsset {
        delete smartAssetManualById[id];
        delete smartAssetMetaById[id];
        delete smartAssetIotById[id];
    }


    /** ByOwner OnSale add*/
    function addSmartAssetByOwner(address owner, bytes16 assetType, uint24 id) onlySmartAsset {
        smartAssetsByOwner[owner][assetType].push(id);
    }

    function addSmartAssetOnSale(bytes16 assetType, uint24 id) onlySmartAsset {
        smartAssetsOnSale[assetType].push(id);
    }


    /** ByOwner OnSale delete*/
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

    /**get counts*/
    function getSmartAssetsOnSaleCount(bytes16 assetType) constant returns (uint24)  {
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
        SmartAssetDataManual data = smartAssetManualById[id];
        return(data.year);
    }

    function getSmartAssetDocURl(uint24 id) constant returns(bytes32) {
        SmartAssetDataManual data = smartAssetManualById[id];
        return(data.docUrl);
    }

    function getSmartAssetType(uint24 id) constant returns(uint8) {
        SmartAssetDataManual data = smartAssetManualById[id];
        return(data._type);
    }

    function getSmartAssetEmail(uint24 id) constant returns(bytes32) {
        SmartAssetDataManual data = smartAssetManualById[id];
        return(data.email);
    }

    function getSmartAssetb1(uint24 id) constant returns(bytes32) {
        SmartAssetDataManual data = smartAssetManualById[id];
        return(data.b1);
    }

    function getSmartAssetb2(uint24 id) constant returns(bytes32) {
        SmartAssetDataManual data = smartAssetManualById[id];
        return(data.b2);
    }

    function getSmartAssetb3(uint24 id) constant returns(bytes32) {
        SmartAssetDataManual data = smartAssetManualById[id];
        return(data.b3);
    }

    function getSmartAssetu1(uint24 id) constant returns(uint) {
        SmartAssetDataManual data = smartAssetManualById[id];
        return(data.u1);
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

    function getSmartAssetLatitude(uint24 id) constant returns(bytes11) {
        SmartAssetDataIot data = smartAssetIotById[id];
        return(data.latitude);
    }

    function getSmartAssetLongitude(uint24 id) constant returns(bytes11) {
        SmartAssetDataIot data = smartAssetIotById[id];
        return(data.longitude);
    }

    function getSmartAssetImageUrl(uint24 id) constant returns(bytes32) {
        SmartAssetDataIot data = smartAssetIotById[id];
        return(data.imageUrl);
    }
////////////////////////////////////////


    function setSmartAssetYear(uint24 id, uint8 year) onlySmartAsset {
        smartAssetManualById[id].year = year;
    }

    function setSmartAssetDocURl(uint24 id, bytes6 docUrl) onlySmartAsset {
        smartAssetManualById[id].docUrl = docUrl;
    }

    function setSmartAssetType(uint24 id, uint8 _type) onlySmartAsset {
        smartAssetManualById[id]._type = _type;
    }

    function setSmartAssetEmail(uint24 id, bytes32 email) onlySmartAsset {
        smartAssetManualById[id].email = email;
    }

    function setSmartAssetb1(uint24 id, bytes32 b1) onlySmartAsset {
        smartAssetManualById[id].b1 = b1;
    }

    function setSmartAssetb2(uint24 id, bytes32 b2) onlySmartAsset {
        smartAssetManualById[id].b2 = b2;
    }

    function setSmartAssetb3(uint24 id, bytes32 b3) onlySmartAsset {
        smartAssetManualById[id].b3 = b3;
    }

    function setSmartAssetu1(uint24 id, uint u1) onlySmartAsset {
        smartAssetManualById[id].u1 = u1;
    }

    function setSmartAssetState(uint24 id, uint8 state) onlySmartAsset {
        smartAssetMetaById[id].state = state;
    }

    function setSmartAssetOwner(uint24 id, address owner) onlySmartAsset {
        smartAssetMetaById[id].owner = owner;
    }

    function setSmartAssetIndexInOnSale(uint24 id, uint24 indexInSmartAssetsOnSale) onlySmartAsset {
        smartAssetMetaById[id].indexInSmartAssetsOnSale = indexInSmartAssetsOnSale;
    }

    function setSmartAssetIndexInAssetsByOwner(uint24 id, uint24 indexInSmartAssetsByOwner) onlySmartAsset {
        smartAssetMetaById[id].indexInSmartAssetsByOwner = indexInSmartAssetsByOwner;
    }

    function setSmartAssetLatitude(uint24 id, bytes11 latitude) onlySmartAsset {
        smartAssetIotById[id].latitude = latitude;
    }

    function setSmartAssetLongitude(uint24 id, bytes11 longitude) onlySmartAsset {
        smartAssetIotById[id].longitude = longitude;
    }

    function setSmartAssetImageUrl(uint24 id, bytes6 imageUrl) onlySmartAsset {
        smartAssetIotById[id].imageUrl = imageUrl;
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
