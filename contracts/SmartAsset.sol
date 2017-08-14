pragma solidity ^0.4.10;

import './SmartAssetRouter.sol';
import './SmartAssetMetadata.sol';
import 'zeppelin-solidity/contracts/lifecycle/Destructible.sol';

/**
*Interface for BKXToken contract
*/
contract BKXTokenInterface {
    function balanceOf(address _address) constant returns (uint balance);
    function burn(address _address, uint amount);
}


/**
 * @title Smart asset contract
 */
contract SmartAsset is Destructible{
    // Workflow stages
    enum State { ManualDataAreEntered, IotDataCollected, PriceCalculated, OnSale, FailedAssetModified }

    address private buyAssetAddr;

    BKXTokenInterface bkxToken;
    uint bkxPriceForTransaction = 1;

    // Next identifier
    uint24 nextId;

    event NewSmartAsset(uint id);
    event AssetPutOnSale(uint id);
    event AssetTakenOffSale(uint id);
    event IndexesQuried(uint8 startIndex, uint8 endIndex);

    /**
     * Check whether BuyAsset contract executes method or not
     */
    modifier onlyBuyAsset {
        require(msg.sender == buyAssetAddr);
        _;
    }

    // Definition of Smart asset
    struct SmartAssetData {
    uint24 id;
    uint56 timestamp;
    bytes11 latitude;
    bytes11 longitude;

    uint24 indexInSmartAssetsByOwner;
    uint24 indexInSmartAssetsOnSale;

    bytes6 docUrl;
    bytes6 imageUrl;
    uint8 _type;
    bytes32 email;

    bytes32 b1;
    bytes32 b2;
    bytes32 b3;
    uint u1;

    State state;
    address owner;
    }

    mapping (uint => SmartAssetData) smartAssetById;

    mapping (address => mapping (bytes32 => SmartAssetData[])) smartAssetsByOwner;

    mapping (bytes32 => SmartAssetData[]) smartAssetsOnSale;

    SmartAssetRouter smartAssetRouter;
    SmartAssetMetadata smartAssetMetadata;

    function SmartAsset(address routerAddress, address metadataAddress) {
        require(routerAddress != address(0));
        require(metadataAddress != address(0));
        smartAssetRouter = SmartAssetRouter(routerAddress);
        smartAssetMetadata = SmartAssetMetadata(metadataAddress);
    }

    /**
    *@dev Sets BKXToken contract address for this contract
    *@param _bkxTokenAddress BKXToken contract address
    */
    function setBKXTokenAddress(address _bkxTokenAddress) onlyOwner() {
        bkxToken = BKXTokenInterface(_bkxTokenAddress);
    }

    /**
   *@dev Sets amount BKX tokens to be paid for transactions
   *@param _bkxTokenAddress BKXToken contract address
   */
    function setBKXPriceForTransaction(uint _bkxPriceForTransaction) onlyOwner() {
        bkxPriceForTransaction = _bkxPriceForTransaction;
    }

    //    /**
    //     * @dev Creates/stores new Smart asset
    //     * @param b1 Generic byte32 parameter #1
    //     * @param b2 Generic byte32 parameter #2
    //     * @param b3 Generic byte32 parameter #3
    //     */
    function createAsset(
        uint56 timestamp,
        bytes6 docUrl,
        uint8 _type,
        bytes32 email,
        bytes32 b1,
        bytes32 b2,
        bytes32 b3,
        uint u1,
        bytes32 assetType
    ) {

        //This piece is commented out due to the fact that not all those using the prototype application
        //will have BKX tokens at their disposal. This logic is to remain here until needed.
        //todo

        /*if(bkxToken == address(0) || bkxToken.balanceOf(msg.sender) < bkxPriceForTransaction) {
            throw;
        }

        bkxToken.burn(msg.sender, bkxPriceForTransaction);*/

        address owner = msg.sender;
        uint24 id = ++nextId;

        SmartAssetData[] storage smartAssetDatasOfOwner = smartAssetsByOwner[owner][assetType];

        SmartAssetData memory smartAssetData = SmartAssetData(
        id,
        timestamp,
        "",
        "",
        uint24(smartAssetDatasOfOwner.length),
        0,
        docUrl,
        "",
        _type,
        email,
        b1,
        b2,
        b3,
        u1,
        State.ManualDataAreEntered,
        owner
        );

        smartAssetById[id] = smartAssetData;

        smartAssetDatasOfOwner.push(smartAssetData);
        smartAssetRouter.setAssetType(id, assetType);
        NewSmartAsset(id);
    }

    /**
     * @dev Removes stored Smart asset
     * @param id Smart asset identifier
     */
    function removeAsset(uint id) {
        address owner = msg.sender;
        SmartAssetData memory smartAssetData = _getAssetById(id);

        require(smartAssetData.owner == owner);

        bytes32 assetType = smartAssetRouter.getAssetType(id);
        delete smartAssetsByOwner[owner][assetType][smartAssetData.indexInSmartAssetsByOwner];

        if (smartAssetData.state == State.OnSale) {
            delete smartAssetsOnSale[assetType][smartAssetData.indexInSmartAssetsOnSale];
        }
        delete smartAssetById[id];
    }


    /**
    *@dev Gets the number of assets on sale by type
    *@param asset type
    *@return the number of assets on sale by type
    */
    function getAssetsOnSaleCount(bytes32 assetType) constant returns (uint) {
        return smartAssetsOnSale[assetType].length;
    }


    /**
    *@dev Gets assets on sale by type
    *@param asset type
    *@return the number of asset on sale by type
    */
    function getAssetsOnSale(bytes32 assetType, uint8 firstIndex, uint8 lastIndex) constant
    returns (
    uint24[] memory id,
    uint56[] memory timestamp,
    uint8[] memory _type,
    bytes32[] memory b1,
    bytes32[] memory b2,
    bytes32[] memory b3,
    uint[] memory u1) {

        return getAssets(firstIndex, lastIndex, smartAssetsOnSale[assetType]);
    }

     function searchAssetsOnSaleByKeyWord(bytes32 assetType, bytes32 keyWord) constant
     returns (
         uint24[] memory id,
         uint56[] memory timestamp,
         uint8[] memory _type,
         bytes32[] memory b1,
         bytes32[] memory b2,
         bytes32[] memory b3,
         uint[] memory u1) {

         uint lastIndex = getAssetsOnSaleCount(assetType) - 1;

         SmartAssetData[] memory assetDatas = smartAssetsOnSale[assetType];

         uint count = getCountOfMatchingItems(lastIndex, assetDatas, keyWord);

         SmartAssetData[] memory foundItemsArray = getFoundItemsArray(count, lastIndex, assetDatas, keyWord);

         return getFoundItems(count, foundItemsArray);
     }

    function getFoundItems(uint count, SmartAssetData[] smartAssetDatas) private constant
    returns(
        uint24[] memory id,
        uint56[] memory timestamp,
        uint8[] memory _type,
        bytes32[] memory b1,
        bytes32[] memory b2,
        bytes32[] memory b3,
        uint[] memory u1) {

        id = new uint24[](count);
        timestamp = new uint56[](count);
        _type = new uint8[](count);
        b1 = new bytes32[](count);
        b2 = new bytes32[](count);
        b3 = new bytes32[](count);
        u1 = new uint[](count);

        for (uint i = 0; i < count; i++) {
            SmartAssetData memory smartAssetData = smartAssetDatas[i];

            id[i] = smartAssetData.id;
            timestamp[i] = smartAssetData.timestamp;
            _type[i] = smartAssetData._type;
            b1[i] = smartAssetData.b1;
            b2[i] = smartAssetData.b2;
            b3[i] = smartAssetData.b3;
            u1[i] = smartAssetData.u1;
        }

        return (id, timestamp, _type, b1, b2, b3, u1);
    }


    function getCountOfMatchingItems(uint lastIndex, SmartAssetData[] smartAssetDatas, bytes32 keyWord) private constant returns(uint) {
        uint count = 0;
        for (uint i = 0; i <= lastIndex; i++) {
            SmartAssetData memory smartAssetData = smartAssetDatas[i];

            if(smartAssetData.b1 == keyWord) {
                count++;
            }
        }
        return count;
    }

    function getFoundItemsArray(uint count, uint lastIndex, SmartAssetData[] smartAssetDatas, bytes32 keyWord) private constant returns(SmartAssetData[]) {
        SmartAssetData[] memory foundItems = new SmartAssetData[](count);
        uint indexInFound = 0;

        for (uint i = 0; i <= lastIndex; i++) {
            SmartAssetData memory smartAssetData = smartAssetDatas[i];

            if(smartAssetData.b1 == keyWord) {
                foundItems[indexInFound++] = smartAssetData;
            }
        }
        return foundItems;
    }

    /**
     * @dev Returns Smart asset owner
     * @param id Smart asset identification number
     * @return Smart asset owner
     */
    function getAssetOwnerById(uint id) constant
    returns (address)
    {
        SmartAssetData memory a = smartAssetById[id];
        require(!isAssetEmpty(a));
        return a.owner;
    }

    /**
     * @dev Returns Smart asset
     * @param id Smart asset identification number
     * @return Smart asset tuple
     */
    function getAssetById(uint id) constant
    returns (
    uint56,
    bytes6,
    uint8,
    bytes32,
    bytes32,
    bytes32,
    bytes32,
    uint,
    State,
    address,
    bytes32
    )
    {
        SmartAssetData memory a = smartAssetById[id];
        require(!isAssetEmpty(a));
        bytes32 assetType = smartAssetRouter.getAssetType(id);

        return (a.timestamp, a.docUrl, a._type, a.email, a.b1, a.b2, a.b3, a.u1, a.state, a.owner, assetType);
    }

    /**
     * @dev Returns Smart asset
     * @param id Smart asset identification number
     * @return Smart asset tuple
     */
    function getAssetIotById(uint id) constant
    returns (
    bytes11,
    bytes11,
    bytes6,
    bytes32
    )
    {
        SmartAssetData memory a = smartAssetById[id];
        require(!isAssetEmpty(a));
        bytes32 assetType = smartAssetRouter.getAssetType(id);

        return (a.latitude, a.longitude, a.imageUrl, assetType);
    }

    /**
     * @dev Returns quantity/count of smart assets owned by invoker/caller
     * @return count value / quantity/count of smart assets
     */
    function getMyAssetsCount(bytes32 assetType) constant returns (uint) {
        return smartAssetsByOwner[msg.sender][assetType].length;
    }

    /**
     * @dev Returns smart assets owned by invoker/caller
     * @param lastIndex Last index/position of returned smart asset
     * @param firstIndex First index/position of returned smart asset
     * @return id Identification numbers
     * @return rest of Smart asset definition/entity
     */
     function getMyAssets(bytes32 assetType , uint8 firstIndex, uint8 lastIndex) constant
     returns (
         uint24[] memory id,
         uint56[] memory timestamp,
         uint8[] memory _type,
         bytes32[] memory b1,
         bytes32[] memory b2,
         bytes32[] memory b3,
         uint[] memory u1
     )
     {
         return getAssets(firstIndex, lastIndex, smartAssetsByOwner[msg.sender][assetType]);
     }

    /**
     * @dev Put smart asset on-sale
     * @param id Smart asset identification number
     */
    function makeOnSale(uint id) {
        SmartAssetData memory smartAssetData = _getAssetById(id);

        require(smartAssetData.owner == msg.sender && smartAssetData.state == State.PriceCalculated);
        bytes32 assetType = smartAssetRouter.getAssetType(id);

        smartAssetById[id].state = State.OnSale;
        smartAssetById[id].indexInSmartAssetsOnSale = uint24(smartAssetsOnSale[assetType].length);

        smartAssetsOnSale[assetType].push(smartAssetById[id]);

        AssetPutOnSale(id);
    }

    /**
     * @dev Take smart asset off sale
     * @param id Smart asset identification number
     */
    function makeOffSale(uint id) {
        SmartAssetData memory smartAssetData = _getAssetById(id);

        require(smartAssetData.owner == msg.sender && smartAssetData.state == State.OnSale);

        smartAssetById[id].state = State.PriceCalculated;
        bytes32 assetType = smartAssetRouter.getAssetType(id);
        delete smartAssetsOnSale[assetType][smartAssetData.indexInSmartAssetsOnSale];

        AssetTakenOffSale(id);
    }

    /**
     * @dev Function to updates Smart Asset params
     */
    function updateFromExternalSource(
        uint24 id,
        bytes11 latitude,
        bytes11 longitude,
        bytes6 imageUrl
    )
    {
        //checks that function is executed from correct contract
        require(msg.sender == smartAssetMetadata.getAssetLogicAddress(smartAssetRouter.getAssetType(id)));

        //validates if asset is present
        SmartAssetData memory asset = _getAssetById(id);

        require(asset.state < State.OnSale);

        smartAssetById[id].latitude = latitude;
        smartAssetById[id].longitude = longitude;
        smartAssetById[id].imageUrl = imageUrl;

        smartAssetById[id].state = State.IotDataCollected;
    }

    function forceUpdateFromExternalSource(uint assetId) {
        SmartAssetData memory smartAssetData = _getAssetById(assetId);
        require(smartAssetData.owner == msg.sender && smartAssetData.state <= State.OnSale);
        return smartAssetRouter.forceUpdateFromExternalSource(assetId);
    }

    function calculateAssetPrice(uint assetId) {
        SmartAssetData memory smartAssetData = _getAssetById(assetId);
        require(smartAssetData.owner == msg.sender && smartAssetData.state < State.OnSale);
        smartAssetRouter.calculateAssetPrice(assetId);
        smartAssetById[assetId].state = State.PriceCalculated;
    }

    function getSmartAssetPrice(uint assetId) constant returns (uint) {
        return smartAssetRouter.getSmartAssetPrice(assetId);
    }

    function getSmartAssetAvailability(uint assetId) constant returns (bool) {
        return smartAssetRouter.getSmartAssetAvailability(assetId);
    }

    function calculateDeliveryPrice(uint assetId, bytes32 param) constant returns (uint) {
        return smartAssetRouter.calculateDeliveryPrice(assetId, param);
    }

    function isAssetTheSameState(uint assetId) constant returns (bool modified) {
        return smartAssetRouter.isAssetTheSameState(assetId);
    }

    /**
     * @dev Returns Smart asset
     * @param smartAsset Smart asset structure/entity
     */
    function _getAssetById(uint id) constant private returns (SmartAssetData smartAsset) {
        SmartAssetData memory smartAssetData = smartAssetById[id];

        require(!isAssetEmpty(smartAssetData));
        return smartAssetData;
    }

    /**
     * @dev Returns whether Smart asset is empty/null
     * @param smartAssetData Smart asset structure/entity
     * @return isEmpty Returns whether smart asset is empty or not
     */
    function isAssetEmpty(SmartAssetData smartAssetData) constant private returns (bool isEmpty) {
        return smartAssetData.id == 0;
    }

    function sellAsset(uint id, address newOwner) onlyBuyAsset {
        SmartAssetData memory asset = _getAssetById(id);

        require(asset.owner != msg.sender);// Owner cannot buy its own asset
        require(asset.state == State.OnSale);

        bytes32 assetType = smartAssetRouter.getAssetType(id);


        delete smartAssetsOnSale[assetType][asset.indexInSmartAssetsOnSale];
        delete smartAssetsByOwner[asset.owner][assetType][asset.indexInSmartAssetsByOwner];

        smartAssetById[id].owner = newOwner;
        smartAssetById[id].state = State.ManualDataAreEntered;

        SmartAssetData[] storage smartAssetDatasOfOwner = smartAssetsByOwner[newOwner][assetType];
        smartAssetDatasOfOwner.push(asset);

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

    function getAssets(uint8 firstIndex, uint8 lastIndex, SmartAssetData[] storage data) private constant
    returns(
    uint24[] memory id,
    uint56[] memory timestamp,
    uint8[] memory _type,
    bytes32[] memory b1,
    bytes32[] memory b2,
    bytes32[] memory b3,
    uint[] memory u1) {

        IndexesQuried(firstIndex, lastIndex);

        require(lastIndex >= firstIndex);

        uint size = lastIndex - firstIndex + 1;

        id = new uint24[](size);
        timestamp = new uint56[](size);
        _type = new uint8[](size);
        b1 = new bytes32[](size);
        b2 = new bytes32[](size);
        b3 = new bytes32[](size);
        u1 = new uint[](size);

        requireIndexInBound(data, lastIndex);

        for (uint i = firstIndex; i <= lastIndex; i++) {
            SmartAssetData memory smartAssetData = data[i];

            id[i] = smartAssetData.id;
            timestamp[i] = smartAssetData.timestamp;
            _type[i] = smartAssetData._type;
            b1[i] = smartAssetData.b1;
            b2[i] = smartAssetData.b2;
            b3[i] = smartAssetData.b3;
            u1[i] = smartAssetData.u1;
        }

        return (id, timestamp, _type, b1, b2, b3, u1);

    }

    function requireIndexInBound(SmartAssetData[] storage data, uint8 index) internal constant {
        require(data.length - 1 >= index);
    }
}
