pragma solidity ^0.4.10;

contract SmartAssetLogicInterface {


    /**
     * @dev Called upon completion of the sell asset process
     * Possible usage for a particular case - trigger event, remove asset price from cache
     * @param assetId Id of smart asset
     */
    function onAssetSold(uint assetId);

    /**
     * @dev Calculates the price of a given smart asset based on its parameters
     * Function is not constant for the idea of some state change
     * e.g price could be stored somewhere like cache
     * @param assetId Id of smart asset
     * @return smart asset price
     */
    function calculateAssetPrice(uint assetId) returns (uint);

    /**
     * @dev Get price of a given smart asset
     * Function is constant
     * Could be used to retrieve price from cache or recalculate it
     * @param id Id of smart asset
     * @return smart asset price
     */
    function getSmartAssetPrice(uint id) constant returns (uint);

    /**
     * @dev Check if smart asset change has not been changed since parameters setup
     * Called upon asset selling process to verify if smart asset still the same
     * @param id Id of smart asset
     * @return boolean if smart asset has the same state
     */
    function isAssetTheSameState(uint id) constant returns (bool sameState);

    /**
     * @dev Calculates delivery price for a given smart asset and given city
     * @param id Id of smart asset
     * @param city city name
     * @return uint delivery price
     */
    function calculateDeliveryPrice(uint id, bytes32 city) constant returns (uint);

    /**
     * @dev Returns smart asset availability (e.g car is still on
     * the parking lot)
     * Called upon asset sale
     * @param id Id of smart asset
     * @return boolean if smart asset available
     */
    function getSmartAssetAvailability(uint id) constant returns (bool);

    /**
     * @dev Function that forces updates of Smart Asset external source params.
     * @param id Id of smart asset
     */
    function forceUpdateFromExternalSource(uint id);
}
