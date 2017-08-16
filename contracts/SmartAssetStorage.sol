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
        bytes6 docUrl;
        uint8 _type;
        bytes32 email;
        bytes32 b1;
        bytes32 b2;
        bytes32 b3;
        uint u1;
    }

    struct SmartAssetDataIot {
        bytes11 latitude;
        bytes11 longitude;
        bytes6 imageUrl;
    }

    mapping (uint => SmartAssetDataMeta) smartAssetMetaById;

    mapping (uint => SmartAssetDataManual) smartAssetManualById;

    mapping (uint => SmartAssetDataIot) smartAssetIotById;


    mapping (address => mapping (bytes32 => SmartAssetDataMeta[])) smartAssetsMetaByOwner;

    mapping (address => mapping (bytes32 => SmartAssetDataManual[])) smartAssetsManualByOwner;

    mapping (address => mapping (bytes32 => SmartAssetDataIot[])) smartAssetsIotByOwner;


    mapping (bytes32 => SmartAssetDataMeta[]) smartAssetsMetaOnSale;

    mapping (bytes32 => SmartAssetDataManual[]) smartAssetsManualOnSale;

    mapping (bytes32 => SmartAssetDataIot[]) smartAssetsIotOnSale;

    uint24 id = 1;

    /** ByOwner add*/
    function addSmartAssetDataManualByOwner(address owner, bytes16 assetType, uint8 year, bytes6 docUrl, uint8 _type, bytes32 email, bytes32 b1, bytes32 b2, bytes32 b3, uint u1) onlySmartAsset {
        SmartAssetDataManual[] storage manualDatas = smartAssetsManualByOwner[owner][assetType];

        SmartAssetDataManual memory smartAssetDataManual  = SmartAssetDataManual(year, docUrl, _type, email, b1, b2, b3, u1);
        manualDatas.push(smartAssetDataManual);
    }

    function addSmartAssetDataMetaByOwner(address owner, bytes16 assetType, uint24 id, uint24 indexInSmartAssetsByOwner, uint24 indexInSmartAssetsOnSale, uint8 state) onlySmartAsset {
        SmartAssetDataMeta[] storage metaDatas = smartAssetsMetaByOwner[owner][assetType];

        SmartAssetDataMeta memory smartAssetDataMeta  = SmartAssetDataMeta(id, indexInSmartAssetsByOwner, indexInSmartAssetsOnSale, state, owner);
        metaDatas.push(smartAssetDataMeta);
    }

    function addSmartAssetDataIotByOwner(address owner, bytes16 assetType, bytes11 latitude, bytes11 longitude, bytes6 imageUrl) {
        SmartAssetDataIot[] storage iotDatas = smartAssetsIotByOwner[owner][assetType];

        SmartAssetDataIot memory smartAssetDataIot = SmartAssetDataIot(latitude, longitude, imageUrl);
        iotDatas.push(smartAssetDataIot);
    }


    /** ById set*/
    function setSmartAssetDataManualById(uint24 id, uint8 year, bytes6 docUrl, uint8 _type, bytes32 email, bytes32 b1, bytes32 b2, bytes32 b3, uint u1) onlySmartAsset {
        smartAssetManualById[id] = SmartAssetDataManual(year, docUrl, _type, email, b1, b2, b3, u1);
    }

    function setSmartAssetDataMetaById(uint24 id, uint24 indexInSmartAssetsByOwner, uint24 indexInSmartAssetsOnSale, uint8 state, address owner) onlySmartAsset {
        smartAssetMetaById[id] = SmartAssetDataMeta(id, indexInSmartAssetsByOwner, indexInSmartAssetsOnSale, state, owner);
    }

    function setSmartAssetDataIotById(uint24, bytes11 latitude, bytes11 longitude, bytes6 imageUrl) {
        smartAssetIotById[id] = SmartAssetDataIot(latitude, longitude, imageUrl);
    }


    /** OnSale add*/
    function addSmartAssetDataManualOnSale(bytes16 assetType, uint8 year, bytes6 docUrl, uint8 _type, bytes32 email, bytes32 b1, bytes32 b2, bytes32 b3, uint u1) {
        SmartAssetDataManual memory smartAssetDataManual = SmartAssetDataManual(year, docUrl, _type, email, b1, b2, b3, u1);
        smartAssetsManualOnSale[assetType].push(smartAssetDataManual);
    }

    function addSmartAssetDataMetaOnSale(bytes16 assetType, uint24 id, uint24 indexInSmartAssetsByOwner, uint24 indexInSmartAssetsOnSale, uint8 state, address owner) {
        SmartAssetDataMeta memory smartAssetDataMeta = SmartAssetDataMeta(id, indexInSmartAssetsByOwner, indexInSmartAssetsOnSale, state, owner);
        smartAssetsMetaOnSale[assetType].push(smartAssetDataMeta);
    }

    function addSmartAssetDataIotOnSale(bytes16 assetType, bytes11 latitude, bytes11 longitude, bytes6 imageUrl) {
        SmartAssetDataIot memory smartAssetDataIot = SmartAssetDataIot(latitude, longitude, imageUrl);
        smartAssetsIotOnSale[assetType].push(smartAssetDataIot);
    }


    /** ById get*/
    function getSmartAssetDataMetaById(uint24 id) constant returns(uint24, uint24, uint8, address) {
        SmartAssetDataMeta data = smartAssetMetaById[id];
        return(data.indexInSmartAssetsByOwner, data.indexInSmartAssetsOnSale, data.state, data.owner);
    }

    function getSmartAssetDataManualById(uint24 id) constant returns(uint8, bytes6, uint8, bytes32, bytes32, bytes32, bytes32, uint) {
        SmartAssetDataManual data = smartAssetManualById[id];
        return(data.year, data.docUrl, data._type, data.email, data.b1, data.b2, data.b3, data.u1);
    }

    function getSmartAssetDataIotById(uint24 id) constant returns (bytes11, bytes11, bytes6) {
        SmartAssetDataIot data = smartAssetIotById[id];
        return (data.latitude, data.longitude, data.imageUrl);
    }



    function getSmartAssetsOnSaleCount(bytes16 assetType) constant returns (uint)  {
        return smartAssetsManualOnSale[assetType].length;
    }

    function getSmartAssetsCountByOwner(address owner, bytes16 assetType) constant returns(uint24) {
        return uint24(smartAssetsMetaByOwner[owner][assetType].length);
    }

    function getId()constant returns(uint24) {
        return id;
    }

    function setId(uint24 _id) onlySmartAsset {
        id = _id;
    }

    function setSmartAsset(address _smartAsset) onlyOwner {
        smartAsset = _smartAsset;
    }
}
