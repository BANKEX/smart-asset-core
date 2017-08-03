pragma solidity ^0.4.10;

import './SmartAssetRouter.sol';

/**
 * Interface for SmartAsset contract
 */
contract SmartAssetI {
    function sellAsset(uint id, address newOwner);
    function getAssetOwnerById(uint id) constant returns (address);
}


/**
 * @title Buy smart asset contract
 */
contract BuySmartAsset {
    address public owner = msg.sender;
    address private smartAssetAddr;

    SmartAssetRouter smartAssetRouter;

    /**
     * Check whether contract owner executes method or not
     */
    modifier onlyOwner {
        if (msg.sender != owner) {throw;} else {_;}
    }

    /**
     * @dev Constructor to check and set up dependencies contract address
     * @param smartAssetAddress Address of deployed SmartAssetAddress contract
     */
    function BuySmartAsset(address smartAssetAddress, address routerAddress) {
        require(smartAssetAddress != address(0));
        require(routerAddress != address(0));
        smartAssetAddr = smartAssetAddress;
        smartAssetRouter = SmartAssetRouter(routerAddress);
    }

    /**
     * @dev Returns total price of the asset
     * @param assetId Id of smart asset
     * @param cityName City name of destination/delivery city
     */
    function getTotalPrice(uint assetId, bytes32 cityName) constant returns (uint totalPrice) {
        if (!smartAssetRouter.checkSmartAssetModification(assetId)) {
            // Formula1 parameters were changed/mutated
            throw;
        }

        return smartAssetRouter.getSmartAssetPrice(assetId) + smartAssetRouter.calculateDeliveryPrice(assetId, cityName);
    }

    /**
     * @dev Performs buying of the asset
     * @param assetId Id of smart asset
     * @param cityName City name of destination/delivery city
     */
    function buyAsset(uint assetId, bytes32 cityName) payable {

        if (!smartAssetRouter.getSmartAssetAvailability(assetId)) {
            throw;
        }

		uint totalPrice = getTotalPrice(assetId, cityName);

		if (msg.value < totalPrice) {
			// Not enough founds to buy the asset
			throw;
		}

		SmartAssetI smartAssetInterface = SmartAssetI(smartAssetAddr);
		smartAssetInterface.getAssetOwnerById(assetId).transfer(totalPrice);

		// Refund buyer if overpaid
		msg.sender.transfer(msg.value - totalPrice);

        smartAssetInterface.sellAsset(assetId, msg.sender);
    }
}
