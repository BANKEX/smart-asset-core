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
    uint nextId;

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
        uint id;
        bytes32 b1;
        bytes32 b2;
        bytes32 b3;
        uint u1;
        uint u2;
        uint u3;
        uint u4;
        bool bool1;
        State state;
        address owner;
        uint indexInSmartAssetsByOwner;
        uint indexInSmartAssetsOnSale;
    }

    struct SmartAssetsMappingByType {
        mapping (bytes32 => SmartAssetData[]) map;
    }

    mapping (uint => SmartAssetData) smartAssetById;

    mapping (address => SmartAssetsMappingByType) smartAssetsByOwner;

    SmartAssetsMappingByType smartAssetsOnSale;

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

    /**
     * @dev Creates/stores new Smart asset
     * @param b1 Generic byte32 parameter #1
     * @param b2 Generic byte32 parameter #2
     * @param b3 Generic byte32 parameter #3
     */
    function createAsset(
        bytes32 b1,
        bytes32 b2,
        bytes32 b3,
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
        uint id = ++nextId;

        SmartAssetData[] storage smartAssetDatasOfOwner = smartAssetsByOwner[owner].map[assetType];

        SmartAssetData memory smartAssetData = SmartAssetData(
            id,
            b1,
            b2,
            b3,
            0,
            0,
            0,
            0,
            false,
            State.ManualDataAreEntered,
            owner,
            smartAssetDatasOfOwner.length,
            0
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
        delete smartAssetsByOwner[owner].map[assetType][smartAssetData.indexInSmartAssetsByOwner];

        if (smartAssetData.state == State.OnSale) {
            delete smartAssetsOnSale.map[assetType][smartAssetData.indexInSmartAssetsOnSale];
        }
        delete smartAssetById[id];
    }


    /**
    *@dev Gets the number of assets on sale by type
    *@param asset type
    *@return the number of assets on sale by type
    */
    function getAssetsOnSaleCount(bytes32 assetType) constant returns (uint) {
        return smartAssetsOnSale.map[assetType].length;
    }


    /**
    *@dev Gets assets on sale by type
    *@param asset type
    *@return the number of asset on sale by type
    */
    function getAssetsOnSale(bytes32 assetType, uint8 firstIndex, uint8 lastIndex) constant
    returns (
        uint[] memory id,
        bytes32[] memory b1,
        bytes32[] memory b2,
        bytes32[] memory b3,
        uint[] memory u1,
        uint[] memory u2,
        bool[] memory bool1) {

        return getAssets(assetType, firstIndex, lastIndex, smartAssetsOnSale);
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
            bytes32,
            bytes32,
            bytes32,
            uint,
            uint,
            uint,
            uint,
            bool,
            State,
            address,
            bytes32)
    {
        SmartAssetData memory a = smartAssetById[id];
        require(!isAssetEmpty(a));
        bytes32 assetType = smartAssetRouter.getAssetType(id);

        return (a.b1, a.b2, a.b3, a.u1, a.u2, a.u3, a.u4, a.bool1, a.state, a.owner, assetType);
    }

    /**
     * @dev Returns quantity/count of smart assets owned by invoker/caller
     * @return count value / quantity/count of smart assets
     */
    function getMyAssetsCount(bytes32 assetType) constant returns (uint) {
        return smartAssetsByOwner[msg.sender].map[assetType].length;
    }

    /**
     * @dev Returns smart assets owned by invoker/caller
     * @param lastIndex Last index/position of returned smart asset
     * @param firstIndex First index/position of returned smart asset
     * @return id Identification numbers
     * @return rest of Smart asset definition/entity
     */
    function getMyAssets(bytes32 assetType , uint8 firstIndex, uint8 lastIndex) constant
    returns (uint[] memory id,
            bytes32[] memory b1,
            bytes32[] memory b2,
            bytes32[] memory b3,
            uint[] memory u1,
            uint[] memory u2,
            bool[] memory bool1)
    {
        return getAssets(assetType, firstIndex, lastIndex, smartAssetsByOwner[msg.sender]);
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
        smartAssetById[id].indexInSmartAssetsOnSale = smartAssetsOnSale.map[assetType].length;

        smartAssetsOnSale.map[assetType].push(smartAssetById[id]);

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
        delete smartAssetsOnSale.map[assetType][smartAssetData.indexInSmartAssetsOnSale];

        AssetTakenOffSale(id);
    }

    /**
     * @dev Function to updates Smart Asset params and generate asset price
     */
    function updateFromExternalSource(
        uint id,
        uint u1,
        uint u2,
        bool bool1,
        uint u3,
        uint u4
    )
    {
        //checks that function is executed from correct contract
        require(msg.sender == smartAssetMetadata.getAssetLogicAddress(smartAssetRouter.getAssetType(id)));

        //validates if asset is present
        SmartAssetData memory asset = _getAssetById(id);

        require(asset.state < State.OnSale);

        smartAssetById[id].u1 = u1;
        smartAssetById[id].u2 = u2;
        smartAssetById[id].bool1 = bool1;
        smartAssetById[id].u3 = u3;
        smartAssetById[id].u4 = u4;

        smartAssetById[id].state = State.IotDataCollected;
    }

    function calculateAssetPrice(uint assetId) {
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


        delete smartAssetsOnSale.map[assetType][asset.indexInSmartAssetsOnSale];
        delete smartAssetsByOwner[asset.owner].map[assetType][asset.indexInSmartAssetsByOwner];

        smartAssetById[id].owner = newOwner;
        smartAssetById[id].state = State.ManualDataAreEntered;

        SmartAssetData[] storage smartAssetDatasOfOwner = smartAssetsByOwner[newOwner].map[assetType];
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

    function getAssets(bytes32 assetType, uint8 firstIndex, uint8 lastIndex, SmartAssetsMappingByType storage mapByType) internal constant
    returns(
        uint[] memory id,
        bytes32[] memory b1,
        bytes32[] memory b2,
        bytes32[] memory b3,
        uint[] memory u1,
        uint[] memory u2,
        bool[] memory bool1) {

        IndexesQuried(firstIndex, lastIndex);

        require(lastIndex >= firstIndex);

        uint size = lastIndex - firstIndex + 1;

        id = new uint[](size);
        b1 = new bytes32[](size);
        b2 = new bytes32[](size);
        b3 = new bytes32[](size);
        u1 = new uint[](size);
        u2 = new uint[](size);
        bool1 = new bool[](size);

        requireIndexInBound(mapByType, assetType, lastIndex);

        for (uint i = firstIndex; i <= lastIndex; i++) {
            SmartAssetData memory smartAssetData = mapByType.map[assetType][i];

            id[i] = smartAssetData.id;
            b1[i] = smartAssetData.b1;
            b2[i] = smartAssetData.b2;
            b3[i] = smartAssetData.b3;
            u1[i] = smartAssetData.u1;
            u2[i] = smartAssetData.u2;
            bool1[i] = smartAssetData.bool1;
        }

        return (id, b1, b2, b3, u1, u2, bool1);

    }

    function requireIndexInBound(SmartAssetsMappingByType storage mapByType, bytes32 assetType, uint8 index) internal constant {
        require(mapByType.map[assetType].length - 1 >= index);
    }

}
