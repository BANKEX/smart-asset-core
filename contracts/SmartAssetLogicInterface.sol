pragma solidity ^0.4.15;

contract SmartAssetLogicInterface {


    /**
     * @dev Called upon completion of the sell asset process
     * Possible usage for a particular case - trigger event, remove asset price from cache
     * @param assetId Id of smart asset
     */
    function onAssetSold(uint24 assetId);

    /**
     * @dev Calculates the price of a given smart asset based on its parameters
     * Function is not constant for the idea of some state change
     * e.g price could be stored somewhere like cache
     * @param assetId Id of smart asset
     * @return smart asset price
     */
    function calculateAssetPrice(uint24 assetId) returns (uint);

    /**
     * @dev Get price of a given smart asset
     * Function is constant
     * Could be used to retrieve price from cache or recalculate it
     * @param id Id of smart asset
     * @return smart asset price
     */
    function getSmartAssetPrice(uint24 id) constant returns (uint);

    /**
     * @dev Check if smart asset change has not been changed since parameters setup
     * Called upon asset selling process to verify if smart asset still the same
     * @param id Id of smart asset
     * @return boolean if smart asset has the same state
     */
    function isAssetTheSameState(uint24 id) constant returns (bool sameState);

    /**
     * @dev Calculates delivery price for a given smart asset and given city
     * @param id Id of smart asset
     * @param city city name
     * @return uint delivery price
     */
    function calculateDeliveryPrice(uint24 id, bytes32 city) constant returns (uint);

    /**
     * @dev Calculates delivery price for a given smart asset
     * @return uint delivery price
     */
    function calculateDeliveryPrice(uint24 id, bytes11 latitudeTo, bytes11 longitudeTo) constant returns (uint);

    /**
     * @dev Returns smart asset availability (e.g car is still on
     * the parking lot)
     * Called upon asset sale
     * @param id Id of smart asset
     * @return boolean if smart asset available
     */
    function getSmartAssetAvailability(uint24 id) constant returns (bool);

    /**
     * @dev Function that forces updates of Smart Asset external source params.
     * @param id Id of smart asset
     */
    function forceUpdateFromExternalSource(uint24 id, string param);
}
