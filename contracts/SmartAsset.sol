pragma solidity ^0.4.15;

import './SmartAssetRouter.sol';
import './SmartAssetMetadata.sol';
import './SmartAssetStorage.sol';
import 'zeppelin-solidity/contracts/lifecycle/Destructible.sol';
import 'zeppelin-solidity/contracts/token/ERC20.sol';


/**
 * @title Smart asset contract
 */
contract SmartAsset is Destructible {
    // Workflow stages
    enum State { ManualDataAreEntered, IotDataCollected, PriceCalculated, OnSale, FailedAssetModified }

    address private buyAssetAddr;

    SmartAssetStorage smartAssetStorage;


    // Next identifier
    uint24 nextId;

    event NewSmartAsset(uint24 id);
    event AssetPutOnSale(uint24 id);
    event AssetTakenOffSale(uint24 id);
    event IndexesQuried(uint8 startIndex, uint8 endIndex);


    modifier onlyBuyAsset {
        require(msg.sender == buyAssetAddr);
        _;
    }

    SmartAssetRouter smartAssetRouter;
    SmartAssetMetadata smartAssetMetadata;

    ERC20 public feeToken;
    address public feeWallet;
    uint256 public fee;

    function SmartAsset(address routerAddress, address metadataAddress) {
        require(routerAddress != address(0));
        require(metadataAddress != address(0));
        smartAssetRouter = SmartAssetRouter(routerAddress);
        smartAssetMetadata = SmartAssetMetadata(metadataAddress);
    }

    function setFee(address _feeToken, address _feeWallet, uint256 _fee) public onlyOwner {
       require(_feeToken != address(0));
       require(_feeWallet != address(0));
       require(_fee > 0);
       feeToken = ERC20(_feeToken);
       feeWallet = _feeWallet;
       fee = _fee;
    }

    //    /**
    //     * @dev Creates/stores new Smart asset
    //     * @param b1 Generic byte32 parameter #1
    //     * @param b2 Generic byte32 parameter #2
    //     * @param b3 Generic byte32 parameter #3
    //     */
    function createAsset(
        uint timestamp,
        uint8 year,
        bytes32 docUrl,
        uint8 _type,
        bytes32 email,
        bytes32 b1,
        bytes32 b2,
        bytes32 b3,
        uint u1,
        bytes16 assetType
    ) {
        address owner = msg.sender;
        uint24 id = smartAssetStorage.getId();

        smartAssetStorage.setSmartAssetDataManualById(
            owner,
            id,
            year,
            docUrl,
            _type,
            email,
            b1,
            b2,
            b3,
            u1
        );

        smartAssetStorage.setSmartAssetDataMetaById(
            id,
            smartAssetStorage.getSmartAssetsCountByOwner(owner, assetType),
            0,
            uint8(State.ManualDataAreEntered),
            owner
        );

        smartAssetStorage.setSmartAssetTimestamp(id, timestamp);

        smartAssetStorage.addSmartAssetByOwner(owner, assetType, id);

        NewSmartAsset(id);

        smartAssetRouter.setAssetType(id, assetType);

        smartAssetStorage.setId(++id);
    }

    /**
     * @dev Removes stored Smart asset
     * @param id Smart asset identifier
     */
    function removeAsset(uint24 id) {
        var (indexInSmartAssetsByOwner, indexInSmartAssetsOnSale, state, owner) = smartAssetStorage.getSmartAssetDataMetaById(id);

        require(owner == msg.sender);

        bytes16 assetType = smartAssetRouter.getAssetType(id);
        smartAssetStorage.deleteSmartAssetByOwner(owner, assetType, indexInSmartAssetsByOwner);

        if (State(state) == State.OnSale) {
            smartAssetStorage.deleteSmartAssetOnSale(assetType, indexInSmartAssetsOnSale);
        }
        smartAssetStorage.deleteSmartAssetById(id);
    }

    /**
    *@dev Gets the number of assets on sale by type
    *@param asset type
    *@return the number of assets on sale by type
    */
    function getAssetsOnSaleCount(bytes16 assetType) constant returns (uint) {
        return smartAssetStorage.getSmartAssetsOnSaleCount(assetType);
    }

    /**
    *@dev Gets assets on sale by type
    *@param asset type
    *@return the number of asset on sale by type
    */
    function getAssetsOnSale(bytes16 assetType, uint24 firstIndex, uint24 lastIndex) constant
    returns (
        uint24[],
        uint8[],
        uint8[],
        bytes32[],
        bytes32[],
        bytes32[],
        address[])
    {

        require(lastIndex >= firstIndex);
        require(lastIndex <= getAssetsOnSaleCount(assetType));

        uint24[] memory ids = new uint24[](lastIndex - firstIndex + 1);

        uint24 count = 0;

        for (uint24 k = firstIndex; k <= lastIndex; k++) {

            ids[count] = smartAssetStorage.getAssetOnSaleAtIndex(assetType, k);

            count++;

        }

        return getAssets(ids);
    }

    /**
     * @dev Returns Smart asset owner
     * @param id Smart asset identification number
     * @return Smart asset owner
     */
    function getAssetOwnerById(uint24 id) constant
    returns (address)
    {
        var (indexInSmartAssetsByOwner, indexInSmartAssetsOnSale, state, owner) = smartAssetStorage.getSmartAssetDataMetaById(id);
        return owner;
    }

    /**
     * @dev Returns Smart asset
     * @param id Smart asset identification number
     * @return Smart asset tuple
     */
    function getAssetById(uint24 id) constant
    returns (
        uint timestamp,
        uint8 year,
        bytes32 docUrl,
        uint8 _type,
        bytes32 email,
        bytes32 b1,
        bytes32 b2,
        bytes32 b3,
        uint u1,
        State state,
        address owner,
        bytes32 assetType,
        address tokenAddress
    ) {
        require(!smartAssetStorage.isAssetEmpty(id));

        timestamp = smartAssetStorage.getSmartAssetTimestamp(id);
        year = smartAssetStorage.getSmartAssetYear(id);
        docUrl = smartAssetStorage.getSmartAssetDocURl(id);
        _type = smartAssetStorage.getSmartAssetType(id);
        email = smartAssetStorage.getSmartAssetEmail(id);
        b1 = smartAssetStorage.getSmartAssetb1(id);
        b2 = smartAssetStorage.getSmartAssetb2(id);
        b3 = smartAssetStorage.getSmartAssetb3(id);
        u1 = smartAssetStorage.getSmartAssetu1(id);
        state = State(smartAssetStorage.getSmartAssetState(id));
        owner = smartAssetStorage.getSmartAssetOwner(id);

        assetType = smartAssetRouter.getAssetType(id);
        tokenAddress = smartAssetStorage.getTokenAddress(id);

    }

    /**
     * @dev Returns Smart asset
     * @param id Smart asset identification number
     * @return Smart asset tuple
     */
    function getAssetIotById(uint24 id) constant
    returns (
    bytes11,
    bytes11,
    bytes32,
    bytes32
    ) {
        require(!smartAssetStorage.isAssetEmpty(id));
        var(latitude, longitude, imageUrl) = smartAssetStorage.getSmartAssetDataIotById(id);

        bytes16 assetType = smartAssetRouter.getAssetType(id);

        return (latitude, longitude, imageUrl, assetType);
    }

    /**
     * @dev Returns quantity/count of smart assets owned by invoker/caller
     * @return count value / quantity/count of smart assets
     */
    function getMyAssetsCount(bytes16 assetType) constant returns (uint24) {
        return smartAssetStorage.getSmartAssetsCountByOwner(msg.sender, assetType);
    }

    /**
     * @dev Returns smart assets owned by invoker/caller
     * @param lastIndex Last index/position of returned smart asset
     * @param firstIndex First index/position of returned smart asset
     * @return id Identification numbers
     * @return rest of Smart asset definition/entity
     */
    function getMyAssets(bytes16 assetType, uint8 firstIndex, uint8 lastIndex) constant
     returns (
         uint24[],
         uint8[] ,
         uint8[],
         bytes32[],
         bytes32[],
         bytes32[],
         address[]
     ) {
        require(lastIndex >= firstIndex);
        require(lastIndex <= getMyAssetsCount(assetType));

        uint24[] memory ids = new uint24[](lastIndex - firstIndex + 1);

        uint24 count = 0;

        for (uint24 k = firstIndex ; k <= lastIndex; k++) {
            ids[count] = smartAssetStorage.getAssetByOwnerAtIndex(msg.sender, assetType, k);
            count++;
        }

        return getAssets(ids);
     }

    /**
     * @dev Put smart asset on-sale
     * @param id Smart asset identification number
     */
    function makeOnSale(uint24 id) {
        require(fee == 0 || feeToken.transferFrom(msg.sender, feeWallet, fee));
        var (indexInSmartAssetsByOwner, indexInSmartAssetsOnSale, state, owner) = smartAssetStorage.getSmartAssetDataMetaById(id);

        require(owner == msg.sender && State(state) == State.PriceCalculated);
        bytes16 assetType = smartAssetRouter.getAssetType(id);

        uint24 smartAssetsOnSale = smartAssetStorage.getSmartAssetsOnSaleCount(assetType);

        smartAssetStorage.setSmartAssetDataMetaById(
            id,
            indexInSmartAssetsByOwner,
            smartAssetsOnSale,
            uint8(State.OnSale),
            owner
        );

        smartAssetStorage.addSmartAssetOnSale(assetType, id);

        AssetPutOnSale(id);
    }

    /**
     * @dev Take smart asset off sale
     * @param id Smart asset identification number
     */
    function makeOffSale(uint24 id) {
        var (indexInSmartAssetsByOwner, indexInSmartAssetsOnSale, state, owner) = smartAssetStorage.getSmartAssetDataMetaById(id);

        require(owner == msg.sender && State(state) == State.OnSale);

        smartAssetStorage.setSmartAssetDataMetaById(
            id,
            indexInSmartAssetsByOwner,
            indexInSmartAssetsOnSale,
            uint8(State.PriceCalculated),
            owner
        );
        bytes16 assetType = smartAssetRouter.getAssetType(id);

        smartAssetStorage.deleteSmartAssetOnSale(assetType, indexInSmartAssetsOnSale);

        AssetTakenOffSale(id);
    }

    event IotUpdateEvent(uint24 id, bytes11 latitude, bytes11 longitude, bytes32 imageUrl);
    /**
     * @dev Function to updates Smart Asset params
     */
    function updateFromExternalSource(
        uint24 id,
        bytes11 latitude,
        bytes11 longitude,
        bytes32 imageUrl
    ) {
        //checks that function is executed from correct contract
        require(msg.sender == smartAssetMetadata.getAssetLogicAddress(smartAssetRouter.getAssetType(id)));

        //validates if asset is present
        var (indexInSmartAssetsByOwner, indexInSmartAssetsOnSale, state, owner) = smartAssetStorage.getSmartAssetDataMetaById(id);

        require(State(state) < State.OnSale);

        smartAssetStorage.setSmartAssetDataIotById(
            id,
            latitude,
            longitude,
            imageUrl
        );

        smartAssetStorage.setSmartAssetDataMetaById(
            id,
            indexInSmartAssetsByOwner,
            indexInSmartAssetsOnSale,
            uint8(State.IotDataCollected),
            owner
        );

        IotUpdateEvent(
            id,
            latitude,
            longitude,
            imageUrl
        );
    }

    function forceUpdateFromExternalSource(uint24 assetId, string param) {
        var (indexInSmartAssetsByOwner, indexInSmartAssetsOnSale, state, owner) = smartAssetStorage.getSmartAssetDataMetaById(assetId);
        require(owner == msg.sender && State(state) <= State.OnSale);
        return smartAssetRouter.forceUpdateFromExternalSource(assetId, param);
    }

    function calculateAssetPrice(uint24 assetId) {
        var (indexInSmartAssetsByOwner, indexInSmartAssetsOnSale, state, owner) = smartAssetStorage.getSmartAssetDataMetaById(assetId);
        require(owner == msg.sender && State(state) < State.OnSale);
        smartAssetRouter.calculateAssetPrice(assetId);
        smartAssetStorage.setSmartAssetDataMetaById(
            assetId,
            indexInSmartAssetsByOwner,
            indexInSmartAssetsOnSale,
            uint8(State.PriceCalculated),
            owner
        );
    }

    function getSmartAssetPrice(uint24 assetId) constant returns (uint) {
        return smartAssetRouter.getSmartAssetPrice(assetId);
    }

    function getSmartAssetAvailability(uint24 assetId) constant returns (bool) {
        return smartAssetRouter.getSmartAssetAvailability(assetId);
    }

    function calculateDeliveryPrice(uint24 assetId, bytes11 latitudeTo, bytes11 longitudeTo) constant returns (uint) {
        return smartAssetRouter.calculateDeliveryPrice(assetId, latitudeTo, longitudeTo);
    }

    function isAssetTheSameState(uint24 assetId) constant returns (bool modified) {
        return smartAssetRouter.isAssetTheSameState(assetId);
    }

    function sellAsset(uint24 id, address newOwner) onlyBuyAsset {
        var (indexInSmartAssetsByOwner, indexInSmartAssetsOnSale, state, owner) = smartAssetStorage.getSmartAssetDataMetaById(id);

        require(owner != msg.sender);// Owner cannot buy its own asset
        require(State(state) == State.OnSale);

        bytes16 assetType = smartAssetRouter.getAssetType(id);

        smartAssetStorage.deleteSmartAssetOnSale(assetType, indexInSmartAssetsOnSale);
        smartAssetStorage.deleteSmartAssetByOwner(owner, assetType, indexInSmartAssetsByOwner);

        smartAssetStorage.setSmartAssetDataMetaById(
            id,
            indexInSmartAssetsByOwner,
            indexInSmartAssetsOnSale,
            uint8(State.ManualDataAreEntered),
            newOwner
        );

        smartAssetStorage.addSmartAssetByOwner(newOwner, assetType, id);

        smartAssetRouter.onAssetSold(id);
    }

    /**
     * @dev Setter for the BuyAsset contract address
     * @param contractAddress Address of the BuyAsset contract
     */
    function setBuyAssetAddr(address contractAddress) onlyOwner returns (bool result) {
        require(contractAddress != address(0));
        buyAssetAddr = contractAddress;
        return true;
    }

    function getAssets(uint24[] ids) private constant
    returns(
        uint24[],
        uint8[] memory yearss,
        uint8[] memory _types,
        bytes32[] memory b1s,
        bytes32[] memory b2s,
        bytes32[] memory b3s,
        address[] memory owners
    ){

        uint size = ids.length;

        yearss = new uint8[](size);
        _types = new uint8[](size);
        b1s = new bytes32[](size);
        b2s = new bytes32[](size);
        b3s = new bytes32[](size);
        owners = new address[](size);

        for (uint24 i = 0; i < size; i++) {

            uint24 id = ids[i];

            if(smartAssetStorage.hasTokenAddress(id)) {
                yearss[i] = smartAssetStorage.getSmartAssetYear(id);
                _types[i] = smartAssetStorage.getSmartAssetType(id);
                b1s[i] = smartAssetStorage.getSmartAssetb1(id);
                b2s[i] = smartAssetStorage.getSmartAssetb2(id);
                b3s[i] = smartAssetStorage.getSmartAssetb3(id);
                owners[i] = smartAssetStorage.getSmartAssetOwner(id);
            }
        }

        return (ids, yearss, _types, b1s, b2s, b3s, owners);

    }

    function setSmartAssetStorage (address _smartAssetStorage) onlyOwner {
        smartAssetStorage = SmartAssetStorage(_smartAssetStorage);
    }

    function setSmartAssetMetaData(address metaDataAddress) onlyOwner {
        smartAssetMetadata = SmartAssetMetadata(metaDataAddress);
    }

    function setSmartAssetRouterAddress(address routerAddress) onlyOwner {
        smartAssetRouter = SmartAssetRouter(routerAddress);
    }
}
