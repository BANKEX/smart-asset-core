pragma solidity ^0.4.10;


/**
 * Interface for SmartAsset contract
 */
contract SmartAssetInterface {
    function sellAsset(uint id, address newOwner);
    function getAssetOwnerById(uint id) constant returns (address);
    function getAssetTypeById(uint id) constant returns (bytes32);
}


contract BaseSmartAssetLogic {
    function getSmartAssetPrice(uint id) returns(uint);
    function checkSmartAssetModification(uint id) returns (bool);
    function calculateDeliveryPrice(uint id, bytes32 city) returns(uint);
    function getSmartAssetAvailability(uint id) returns (bool);
}


contract SmartAssetMetaInterface {
    function getAssetLogicAddress(bytes32 assetType) constant returns(address);
}


/**
 * @title Buy smart asset contract
 */
contract BuySmartAsset {
    address public owner = msg.sender;
    address private smartAssetAddr;
    address private smartAssetMetaAddr;

    /**
     * Check whether contract owner executes method or not
     */
    modifier onlyOwner {
        if (msg.sender != owner) {throw;} else {_;}
    }

    /**
     * @dev Constructor to check and set up dependencies contract address
     * @param smartAssetPriceAddress Address of deployed SmartAssetPriceAddress contract
     * @param smartAssetAvailabilityAddress Address of deployed SmartAssetAvailabilityAddress contract
     * @param deliveryRequirementsAddress Address of deployed DeliveryRequirementsAddress contract
     * @param smartAssetAddress Address of deployed SmartAssetAddress contract
     */
    function BuySmartAsset(address smartAssetAddress, address _smartAssetMetaAddr) {
        if (smartAssetAddress == address(0) || _smartAssetMetaAddr == address(0)) {
            throw;
        }

        smartAssetMetaAddr = _smartAssetMetaAddr;
        smartAssetAddr = smartAssetAddress;
    }

    /**
     * @dev Returns total price of the asset
     * @param assetId Id of smart asset
     * @param cityName City name of destination/delivery city
     */
    function getTotalPrice(uint assetId, bytes32 cityName) constant returns (uint totalPrice) {

        BaseSmartAssetLogic baseSmartAssetLogic = getBaseAssetLogic(assetId);


        if (!baseSmartAssetLogic.checkSmartAssetModification(assetId)) {
            // Formula1 parameters were changed/mutated
            throw;
        }

        return baseSmartAssetLogic.getSmartAssetPrice(assetId) + baseSmartAssetLogic.calculateDeliveryPrice(assetId, cityName);
    }

    /**
     * @dev Performs buying of the asset
     * @param assetId Id of smart asset
     * @param cityName City name of destination/delivery city
     */
    function buyAsset(uint assetId, bytes32 cityName) payable {

        BaseSmartAssetLogic baseSmartAssetLogic = getBaseAssetLogic(assetId);

        if (!baseSmartAssetLogic.getSmartAssetAvailability(assetId)) {
            throw;
        }

		uint totalPrice = getTotalPrice(assetId, cityName);

		if (msg.value < totalPrice) {
			// Not enough founds to buy the asset
			throw;
		}

		SmartAssetInterface smartAssetInterface = SmartAssetInterface(smartAssetAddr);
		smartAssetInterface.getAssetOwnerById(assetId).transfer(totalPrice);

		// Refund buyer if overpaid
		msg.sender.transfer(msg.value - totalPrice);

        smartAssetInterface.sellAsset(assetId, msg.sender);
    }

    function getBaseAssetLogic(uint assetId) private returns(BaseSmartAssetLogic) {

        SmartAssetInterface smartAssetInterface = SmartAssetInterface(smartAssetAddr);

        bytes32 assetType = smartAssetInterface.getAssetTypeById(assetId);

        SmartAssetMetaInterface smartAssetMetaInterface = SmartAssetMetaInterface(smartAssetMetaAddr);

        address assetLogicAddress = smartAssetMetaInterface.getAssetLogicAddress(assetType);

        BaseSmartAssetLogic baseSmartAssetLogic = BaseSmartAssetLogic(assetLogicAddress);

        return baseSmartAssetLogic;
    }
}
