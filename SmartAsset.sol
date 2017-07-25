pragma solidity ^0.4.10;


/**
 * @title Smart asset contract
 */
contract SmartAsset {
    // Workflow stages
    enum State { ManualDataAreEntered,  SensorDataAreCollected, PriceFromFormula1IsCalculated, OnSale, FailedAssetModified }

    address iotSimulationAddr;

    // Next identifier
    uint nextId;

    event NewSmartAsset(uint id);

    /**
     * Check whether IotSimulator contract executes method or not
     */
    modifier onlyIotSimulator {
        if (msg.sender != iotSimulationAddr) {throw;} else {_;}
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

    // Smart asset by its identifier
    mapping (uint => SmartAssetData) smartAssetById;
    // All smart assets by their owner
    mapping (address => SmartAssetData[]) smartAssetsByOwner;

    // Smart assets which are on-sale
    SmartAssetData[] smartAssetsOnSale;

    /**
     * @dev Constructor to check and set up IotSimulator contract address
     * @param iotSimulationAddress Address of deployed IotSimulator contract
     */
    function SmartAsset(address iotSimulationAddress) {
        if (iotSimulationAddress == address(0)) {
            throw;
        } else {
            iotSimulationAddr = iotSimulationAddress;
        }
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
        bytes32 b3
    ) {
        address owner = msg.sender;
        uint id = ++nextId;

        SmartAssetData[] storage smartAssetDatasOfOwner = smartAssetsByOwner[owner];

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
        NewSmartAsset(id);
    }

    /**
     * @dev Removes stored Smart asset
     * @param id Smart asset identifier
     */
    function removeAsset(uint id) {
        address owner = msg.sender;

        SmartAssetData memory smartAssetData = _getAssetById(id);

        if (smartAssetData.owner != owner) {
            // Asset doesn't belong to sender
            throw;
        }

        delete smartAssetsByOwner[owner][smartAssetData.indexInSmartAssetsByOwner];

        if (smartAssetData.state == State.OnSale) {
            delete smartAssetsOnSale[smartAssetData.indexInSmartAssetsOnSale];
        }

        delete smartAssetsByOwner[owner];
        delete smartAssetById[id];
    }

    /**
     * @dev Returns Smart asset
     * @param id Smart asset identification number
     * @return Smart asset tuple
     */
    function getAssetById(uint id) constant
    returns (uint,
            bytes32,
            bytes32,
            bytes32,
            uint,
            uint,
            uint,
            uint,
            bool,
            State state,
            address)
    {
        SmartAssetData memory a = smartAssetById[id];

        if (isAssetEmpty(a)) {
            // Owner doesn't have specified smart asset
            throw;
        }

        return (a.id, a.b1, a.b2, a.b3, a.u1, a.u2, a.u3, a.u4, a.bool1, a.state, a.owner);
    }

    /**
     * @dev Returns quantity/count of smart assets owned by invoker/caller
     * @return count value / quantity/count of smart assets
     */
    function getMyAssetsCount() returns (uint) {
        return smartAssetsByOwner[msg.sender].length;
    }

    /**
     * @dev Returns smart assets owned by invoker/caller
     * @param lastIndex Last index/position of returned smart asset
     * @param firstIndex First index/position of returned smart asset
     * @return id Identification numbers
     * @return rest of Smart asset definition/entity
     */
    function getMyAssets(uint lastIndex, uint firstIndex) constant
    returns (uint[] memory id,
            bytes32[] memory b1,
            bytes32[] memory b2,
            bytes32[] memory b3,
            uint[] memory u1,
            uint[] memory u2,
            bool[] memory bool1)
    {
        uint size = lastIndex - firstIndex + 1;

        id = new uint[](size);
        b1 = new bytes32[](size);
        b2 = new bytes32[](size);
        b3 = new bytes32[](size);
        u1 = new uint[](size);
        u2 = new uint[](size);
        bool1 = new bool[](size);

        for (uint i = firstIndex; i <= lastIndex; i++) {
            SmartAssetData memory smartAssetData = smartAssetsByOwner[msg.sender][i];

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

    /**
     * @dev Put smart asset on-sale
     * @param id Smart asset identification number
     */
    function makeOnSale(uint id) {
        SmartAssetData memory smartAssetData = _getAssetById(id);

        if (smartAssetData.owner != msg.sender || smartAssetData.state != State.PriceFromFormula1IsCalculated) {
            // Asset doesn't belong to sender or is partially filled or is already On Sale
            throw;
        }

        smartAssetData.state = State.OnSale;
        smartAssetData.indexInSmartAssetsOnSale = smartAssetsOnSale.length;

        smartAssetsOnSale.push(smartAssetData);
    }

    /**
     * @dev Take smart asset off sale
     * @param id Smart asset identification number
     */
    function makeOffSale(uint id) {
        SmartAssetData memory smartAssetData = _getAssetById(id);

        if (smartAssetData.owner != msg.sender || smartAssetData.state != State.OnSale) {
            // Asset doesn't belong to sender or is not On Sale
            throw;
        }

        smartAssetData.state = State.PriceFromFormula1IsCalculated;

        delete smartAssetsOnSale[smartAssetData.indexInSmartAssetsOnSale];
    }

    function updateViaIotSimulator(
        uint id,
        uint millage,
        uint damaged,
        bool smokingCar,
        uint longitude,
        uint latitude
    ) onlyIotSimulator()
    {
        //validates if asset is present
        SmartAssetData memory asset = _getAssetById(id);

        if (asset.state == State.ManualDataAreEntered) {
            smartAssetById[id].u1 = millage;
            smartAssetById[id].u2 = damaged;
            smartAssetById[id].bool1 = smokingCar;
            smartAssetById[id].u3 = longitude;
            smartAssetById[id].u4 = latitude;
            smartAssetById[id].state = State.SensorDataAreCollected;
        } else if (asset.u1 != millage || asset.u2 != damaged || asset.bool1 != smokingCar || asset.u3 != longitude || asset.u4 != latitude) {
            smartAssetById[id].state = State.FailedAssetModified;
            //delete from available for sale
            if (asset.state == State.OnSale) {
                delete smartAssetsOnSale[asset.indexInSmartAssetsOnSale];
            }
        }
    }

    /**
     * @dev Returns Smart asset
     * @param smartAsset Smart asset structure/entity
     */
    function _getAssetById(uint id) constant private returns (SmartAssetData smartAsset) {
        SmartAssetData memory smartAssetData = smartAssetById[id];

        if (isAssetEmpty(smartAssetData)) {
            // Owner doesn't have specified smart asset
            throw;
        }

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
}
