pragma solidity ^0.4.10;

import './SmartAssetRouter.sol';
import 'zeppelin-solidity/contracts/lifecycle/Destructible.sol';
import 'zeppelin-solidity/contracts/payment/PullPayment.sol';

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
contract BuySmartAsset is Destructible, PullPayment {
    address private smartAssetAddr;

    SmartAssetRouter smartAssetRouter;

    event AssetSoldTo(uint id, address newOwner);

    event AsyncSend(address to, uint amount);

    event EnteredMethod(uint name);

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
        return smartAssetRouter.getSmartAssetPrice(assetId) + smartAssetRouter.calculateDeliveryPrice(assetId, cityName);
    }

    /**
     * @dev Performs buying of the asset
     * @param assetId Id of smart asset
     * @param cityName City name of destination/delivery city
     */
    function buyAsset(uint assetId, bytes32 cityName) payable {

        require(smartAssetRouter.getSmartAssetAvailability(assetId));

        require(smartAssetRouter.isAssetTheSameState(assetId));

		uint totalPrice = getTotalPrice(assetId, cityName);

		require(msg.value >= totalPrice);

		SmartAssetI smartAssetInterface = SmartAssetI(smartAssetAddr);
		smartAssetInterface.getAssetOwnerById(assetId).transfer(totalPrice);

        smartAssetInterface.sellAsset(assetId, msg.sender);

        AsyncSend(msg.sender, msg.value - totalPrice);
        asyncSend(msg.sender, msg.value - totalPrice);

        AssetSoldTo(assetId, msg.sender);
    }
}
