pragma solidity ^0.4.10;

import './BaseAssetLogic.sol';
import '../oraclize/oraclizeAPI_0.4.sol';
import 'jsmnsol-lib/JsmnSolLib.sol';

contract DhOraclizeBase is BaseAssetLogic, usingOraclize {

    mapping (bytes32 => uint24) oraclizeIdToAssetId;

    string public endpoint = "https://dev-web-prototype-bankex.azurewebsites.net/api/dh/";

    function DhOraclizeBase() {

    }

    function __callback(bytes32 myid, string result) {
        require(msg.sender == oraclize_cbAddress());

        var (status, tokens, numberOfFoundTokens) = JsmnSolLib.parse(result, 10);

        bytes11 lat = bytes11(getFirst32Bytes(JsmnSolLib.getBytes(result, tokens[2].start, tokens[2].end)));
        bytes32 imageUrl = parseHex(JsmnSolLib.getBytes(result, tokens[4].start, tokens[4].end));
        bool shaked = JsmnSolLib.parseBool(JsmnSolLib.getBytes(result, tokens[6].start, tokens[6].end));
        bytes11 long = bytes11(getFirst32Bytes(JsmnSolLib.getBytes(result, tokens[8].start, tokens[8].end)));


        uint24 assetId = oraclizeIdToAssetId[myid];

        updateAvailability(assetId, shaked);

        SmartAssetInterface asset = SmartAssetInterface(smartAssetAddr);
        asset.updateFromExternalSource(assetId, lat, long, imageUrl);
    }

    function updateAvailability(uint24 assetId, bool availability) internal;

    function forceUpdateFromExternalSource(uint24 id, string param) onlySmartAssetRouter {
        string memory url   = strConcat("json(", endpoint , param, ").0.parameters");
        bytes32 oraclizeId = oraclize_query("URL", url, 800000);
        oraclizeIdToAssetId[oraclizeId] = id;
    }

    function getFirst32Bytes(string source) returns (bytes32 result) {
        assembly {
        result := mload(add(source, 32))
        }
    }

    function parseHex(string _a) private returns (bytes32) {
        bytes memory bresult = bytes(_a);
        uint mint = 0;

        for (uint i=0; i<bresult.length; i++){
            if ((bresult[i] >= 48)&&(bresult[i] <= 57)){

                mint *= 16;
                mint += uint(bresult[i]) - 48;
            }
            if ((bresult[i] >= 97)&&(bresult[i] <= 102)){

                mint *= 16;
                mint += uint(bresult[i]) - 97 + 10;
            }
        }
        return bytes32(mint);
    }

    function setEndpoint(string _endpoint) onlyOwner {
        endpoint = _endpoint;
    }

    function () payable {}

}
