contract SmartAssetAvailability {
	address private iotSimulationAddr;

    // Definition of Smart asset price data object
    struct SmartAssetAvailabilityData {
    	bool availability;
    	bytes32 hash;
    }

    // Smart asset by its identifier
    mapping (uint => SmartAssetAvailabilityData) smartAssetAvailabilityById;

	/**
     * Check whether IotSimulator contract executes method or not
     */
    modifier onlyIotSimulator {
        if (msg.sender != iotSimulationAddr) {throw;} else {_;}
    }

    /**
     * @dev Constructor to check and set up IotSimulator contract address
     * @param iotSimulationAddress Address of deployed IotSimulator contract
     */
    function SmartAssetAvailability(address iotSimulationAddress) {
        if (iotSimulationAddress == address(0)) {
            throw;
        } else {
            iotSimulationAddr = iotSimulationAddress;
        }
    }

	/**
     * @dev Function to updates Smart Asset IoT availability
     */
    function updateViaIotSimulator(
        uint id,
        bool availability
    ) onlyIotSimulator()
    {
		smartAssetAvailabilityById[id].availability = availability;
    }

    /**
     * @dev Returns IoT availability of the asset
     * @param id Id of smart asset
     */
    function getSmartAssetAvailability(uint id) constant returns (bool availability) {
        return smartAssetAvailabilityById[id].availability;
    }

}