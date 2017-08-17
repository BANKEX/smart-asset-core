pragma solidity ^0.4.10;

import './SmartAssetRouter.sol';
import './SmartAssetMetadata.sol';
import './SmartAssetStorage.sol';
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

    SmartAssetStorage smartAssetStorage;

    BKXTokenInterface bkxToken;
    uint bkxPriceForTransaction = 1;

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
        uint8 year,
        bytes6 docUrl,
        uint8 _type,
        bytes32 email,
        bytes32 b1,
        bytes32 b2,
        bytes32 b3,
        uint u1,
        bytes16 assetType
    ) {

        //This piece is commented out due to the fact that not all those using the prototype application
        //will have BKX tokens at their disposal. This logic is to remain here until needed.
        //todo

        /*if(bkxToken == address(0) || bkxToken.balanceOf(msg.sender) < bkxPriceForTransaction) {
            throw;
        }

        bkxToken.burn(msg.sender, bkxPriceForTransaction);*/

        address owner = msg.sender;
        uint24 id = smartAssetStorage.getId();

        smartAssetStorage.setSmartAssetDataManualById(id, year, docUrl, _type, email, b1, b2, b3, u1);

        smartAssetStorage.setSmartAssetDataMetaById(id, smartAssetStorage.getSmartAssetsCountByOwner(owner, assetType), 0, uint8(State.ManualDataAreEntered), owner);

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
    uint[]) {

        require(lastIndex >= firstIndex);

        uint24[] memory ids = new uint24[](lastIndex - firstIndex + 1);

        uint24 count = 0;

        for(uint24 k = firstIndex; k <= lastIndex; k++) {

            ids[count] = smartAssetStorage.getAssetOnSaleAtIndex(assetType, k);

            count++;

        }

        return getAssets(ids);
    }

     function searchAssetsOnSaleByKeyWord(bytes16 assetType, bytes32 keyWord) constant
     returns (
         uint24[] memory id,
         uint8[] memory year,
         uint8[] memory _type,
         bytes32[] memory b1,
         bytes32[] memory b2,
         bytes32[] memory b3,
         uint[] memory u1) {

         uint lastIndex = getAssetsOnSaleCount(assetType) - 1;

         uint count = getCountOfMatchingItems(lastIndex, assetType, keyWord);

         uint24[] memory foundItemsArray = getFoundItemsArray(count, lastIndex, assetType, keyWord);

         return getFoundItems(count, foundItemsArray);
     }

    function getFoundItems(uint count, uint24[] smartAssetIds) private constant
    returns(
        uint24[] memory ids,
        uint8[] memory yearss,
        uint8[] memory _types,
        bytes32[] memory b1s,
        bytes32[] memory b2s,
        bytes32[] memory b3s,
        uint[] memory u1s) {

        ids = new uint24[](count);
        yearss = new uint8[](count);
        _types = new uint8[](count);
        b1s = new bytes32[](count);
        b2s = new bytes32[](count);
        b3s = new bytes32[](count);
        u1s = new uint[](count);

        for (uint i = 0; i < count; i++) {
            uint24 id = smartAssetIds[i];

            ids[i] = id;
            yearss[i] = smartAssetStorage.getSmartAssetYear(id);
            _types[i] = smartAssetStorage.getSmartAssetType(id);
            b1s[i] = smartAssetStorage.getSmartAssetb1(id);
            b2s[i] = smartAssetStorage.getSmartAssetb2(id);
            b3s[i] = smartAssetStorage.getSmartAssetb3(id);
            u1s[i] = smartAssetStorage.getSmartAssetu1(id);
        }

        return (ids, yearss, _types, b1s, b2s, b3s, u1s);
    }


    function getCountOfMatchingItems(uint lastIndex, bytes16 assetType, bytes32 keyWord) private constant returns(uint) {
        uint count = 0;
        for (uint24 i = 0; i <= lastIndex; i++) {
            uint24 id = smartAssetStorage.getAssetOnSaleAtIndex(assetType, i);

            if(smartAssetStorage.getSmartAssetb1(id) == keyWord) {
                count++;
            }
        }
        return count;
    }

    function getFoundItemsArray(uint count, uint lastIndex, bytes16 assetType, bytes32 keyWord) private constant returns(uint24[]) {
        uint24[] memory foundItems = new uint24[](count);
        uint indexInFound = 0;

        for (uint24 i = 0; i <= lastIndex; i++) {
            uint24 id = smartAssetStorage.getAssetOnSaleAtIndex(assetType, i);

            if(smartAssetStorage.getSmartAssetb1(id) == keyWord) {
                foundItems[indexInFound++] = id;
            }
        }
        return foundItems;
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
        uint8 year,
        bytes6 docUrl,
        uint8 _type,
        bytes32 email,
        bytes32 b1,
        bytes32 b2,
        bytes32 b3,
        uint u1,
        State state,
        address owner,
        bytes32 assetType
    )
    {
        require(!smartAssetStorage.isAssetEmpty(id));

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
    bytes6,
    bytes32
    )
    {
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
     function getMyAssets(bytes16 assetType , uint8 firstIndex, uint8 lastIndex) constant
     returns (
         uint24[],
         uint8[] ,
         uint8[],
         bytes32[],
         bytes32[],
         bytes32[],
         uint[]
     )
     {
         require(lastIndex >= firstIndex);

         uint24[] memory ids = new uint24[](lastIndex - firstIndex + 1);

         uint24 count = 0;

         for(uint24 k = firstIndex; k <= lastIndex; k++) {

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
        var (indexInSmartAssetsByOwner, indexInSmartAssetsOnSale, state, owner) = smartAssetStorage.getSmartAssetDataMetaById(id);

        require(owner == msg.sender && State(state) == State.PriceCalculated);
        bytes16 assetType = smartAssetRouter.getAssetType(id);

        uint24 smartAssetsOnSale = smartAssetStorage.getSmartAssetsOnSaleCount(assetType);

        smartAssetStorage.setSmartAssetDataMetaById(id, indexInSmartAssetsByOwner, smartAssetsOnSale, uint8(State.OnSale), owner);

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

        smartAssetStorage.setSmartAssetDataMetaById(id, indexInSmartAssetsByOwner, indexInSmartAssetsOnSale, uint8(State.PriceCalculated), owner);
        bytes16 assetType = smartAssetRouter.getAssetType(id);

        smartAssetStorage.deleteSmartAssetOnSale(assetType, indexInSmartAssetsOnSale);

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
        var (indexInSmartAssetsByOwner, indexInSmartAssetsOnSale, state, owner) = smartAssetStorage.getSmartAssetDataMetaById(id);

        require(State(state) < State.OnSale);

        smartAssetStorage.setSmartAssetDataIotById(id, latitude, longitude, imageUrl);

        smartAssetStorage.setSmartAssetDataMetaById(id, indexInSmartAssetsByOwner, indexInSmartAssetsOnSale, uint8(State.IotDataCollected), owner);
    }

    function forceUpdateFromExternalSource(uint24 assetId) {
        var (indexInSmartAssetsByOwner, indexInSmartAssetsOnSale, state, owner) = smartAssetStorage.getSmartAssetDataMetaById(assetId);
        require(owner == msg.sender && State(state) <= State.OnSale);
        return smartAssetRouter.forceUpdateFromExternalSource(assetId);
    }

    function calculateAssetPrice(uint24 assetId) {
        var (indexInSmartAssetsByOwner, indexInSmartAssetsOnSale, state, owner) = smartAssetStorage.getSmartAssetDataMetaById(assetId);
        require(owner == msg.sender && State(state) < State.OnSale);
        smartAssetRouter.calculateAssetPrice(assetId);
        smartAssetStorage.setSmartAssetDataMetaById(assetId, indexInSmartAssetsByOwner, indexInSmartAssetsOnSale, uint8(State.PriceCalculated), owner);
    }

    function getSmartAssetPrice(uint24 assetId) constant returns (uint) {
        return smartAssetRouter.getSmartAssetPrice(assetId);
    }

    function getSmartAssetAvailability(uint24 assetId) constant returns (bool) {
        return smartAssetRouter.getSmartAssetAvailability(assetId);
    }

    function calculateDeliveryPrice(uint24 assetId, bytes32 param) constant returns (uint) {
        return smartAssetRouter.calculateDeliveryPrice(assetId, param);
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

        smartAssetStorage.setSmartAssetDataMetaById(id, indexInSmartAssetsByOwner, indexInSmartAssetsOnSale, uint8(State.ManualDataAreEntered), newOwner);

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
        uint[] memory u1s) {

        uint size = ids.length;

        yearss = new uint8[](size);
        _types = new uint8[](size);
        b1s = new bytes32[](size);
        b2s = new bytes32[](size);
        b3s = new bytes32[](size);
        u1s = new uint[](size);

        //requireIndexInBound(data, lastIndex);

        for (uint24 i = 0; i < size; i++) {

            uint24 id = ids[i];

            yearss[i] = smartAssetStorage.getSmartAssetYear(id);
            _types[i] = smartAssetStorage.getSmartAssetType(id);
            b1s[i] = smartAssetStorage.getSmartAssetb1(id);
            b2s[i] = smartAssetStorage.getSmartAssetb2(id);
            b3s[i] = smartAssetStorage.getSmartAssetb3(id);
            u1s[i] = smartAssetStorage.getSmartAssetu1(id);
        }

        return (ids, yearss, _types, b1s, b2s, b3s, u1s);

    }

   /* function requireIndexInBound(SmartAssetData[] storage data, uint8 index) internal constant {
        require(data.length - 1 >= index);
    }*/

    function setSmartAssetStorage (address _smartAssetStorage) {
        smartAssetStorage = SmartAssetStorage(_smartAssetStorage);
    }
}
