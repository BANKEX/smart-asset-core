pragma solidity ^0.4.10;


/**
 * Interface for SmartAsset contract
 */
contract SmartAssetInterface {
	function sellAsset(uint id, address newOwner);
	function getAssetOwnerById(uint id) constant
    returns (address);
}

/**
 * Interface for SmartAssetPrice contract
 */
contract SmartAssetPriceInterface {
	function getSmartAssetPrice(uint id) constant returns (uint price);
	function checkSmartAssetModification(uint assetId) constant returns (bool modified);
}

/**
 * Interface for SmartAssetAvailability contract
 */
contract SmartAssetAvailabilityInterface {
	function getSmartAssetAvailability(uint id) constant returns (bool availability);
}

/**
 * Interface for DeliveryRequirements contract
 */
contract DeliveryRequirementsInterface {
	function calculatePrice(uint id, bytes32 cityName) constant returns(uint);
}

/**
 * @title Buy smart asset contract
 */
contract BuySmartAsset {
	address public owner = msg.sender;
	address private smartAssetAddr;
	address private smartAssetPriceAddr;
	address private smartAssetAvailabilityAddr;
	address private deliveryRequirementsAddr;

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
    function BuySmartAsset(address smartAssetPriceAddress, address smartAssetAvailabilityAddress, address deliveryRequirementsAddress, address smartAssetAddress) {
    	if (smartAssetPriceAddress == address(0) || smartAssetAvailabilityAddress == address(0) || deliveryRequirementsAddress == address(0) || smartAssetAddress == address(0)) {
            throw;
        } 

    	smartAssetAddr = smartAssetAddress;
		smartAssetPriceAddr = smartAssetPriceAddress;
		smartAssetAvailabilityAddr = smartAssetAvailabilityAddress;
		deliveryRequirementsAddr = deliveryRequirementsAddress;
	}

    /**
     * @dev Returns total price of the asset
     * @param assetId Id of smart asset
     * @param cityName City name of destination/delivery city
     */
	function getTotalPrice(uint assetId, bytes32 cityName) constant returns (uint totalPrice) {
		SmartAssetPriceInterface smartAssetPriceInterface = SmartAssetPriceInterface(smartAssetPriceAddr);

		if (!smartAssetPriceInterface.checkSmartAssetModification(assetId)) {
			// Formula1 parameters were changed/mutated
			throw;
		}

		DeliveryRequirementsInterface deliveryRequirementsInterface = DeliveryRequirementsInterface(deliveryRequirementsAddr);

		return smartAssetPriceInterface.getSmartAssetPrice(assetId) + deliveryRequirementsInterface.calculatePrice(assetId, cityName);
	}

    /**
     * @dev Performs buying of the asset
     * @param assetId Id of smart asset
     * @param cityName City name of destination/delivery city
     */
	function buyAsset(uint assetId, bytes32 cityName) payable {		
		SmartAssetAvailabilityInterface SmartAssetAvailability = SmartAssetAvailabilityInterface(smartAssetAvailabilityAddr);
		if (!SmartAssetAvailability.getSmartAssetAvailability(assetId)) {
			// Asset is not avaiable via IoT sensor
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
}