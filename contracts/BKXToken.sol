pragma solidity ^0.4.10;

import 'zeppelin-solidity/contracts/lifecycle/Destructible.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';

/**
 * @title Interface to confirm/comply with token API (for example via Etherium Wallet)
 */
contract IToken {
    function balanceOf(address _address) constant returns (uint balance);
    function transfer(address _to, uint _value) returns (bool success);
}


/**
 * @title ICO token contract (draft version)
 */
contract BKXToken is Destructible {

    using SafeMath for uint256;

    // Token-related properties/description to display in Wallet client / UI
    string public standard = "BKXToken 0.1";
    string public name = "BKXToken";
    string public symbol = "BKX";


    // Presale token contract which required for granular access while doing Presale -> ICO token exchange from within Presale contract
    address PBKXcontract;
    // Smart Asset Contract address
    address smartAssetContract;

    mapping (address => uint256) balanceFor;

    // Modifiers
    modifier PBKXcontractOnly {
        require(msg.sender == PBKXcontract);
        _;
    }
    modifier smartAssetContractOnly {
        require(msg.sender == smartAssetContract);
        _;
    }

    /**
     * @dev ICO contract constructor
     */
    function BKXToken() {
        owner = msg.sender;
        balanceFor[msg.sender] = 3000000; // TODO: Define total amount of ICO tokens
    }

    /**
     * @dev Set/change presale contract address
     * @param contractAddress Presale contract address
     */
    function setPBKXcontract(address contractAddress) onlyOwner {
        PBKXcontract = contractAddress;
    }

    /**
     * @dev Set/change smart asset contract address
     * @param _smartAssetContract smart asset contract address
     */
    function setSmartAssetContract(address _smartAssetContract) onlyOwner {
        smartAssetContract = _smartAssetContract;
    }

    /**
     * @dev Removes a specified ammount from a specified address
     * @param _address Account address from which the amount will be deducted
     * @param amount the amount to deduct
     */
    function burn(address _address, uint amount) smartAssetContractOnly() {
        require(balanceFor[_address] >= amount);
        balanceFor[_address] -= amount;
    }

    /**
     * @dev Returns balance/token quanity owned by address
     * @param _address Account address to get balance for
     * @return balance value / token quantity
     */
    function balanceOf(address _address) constant returns (uint balance) {
        return balanceFor[_address];
    }

    /**
     * @dev Transfers tokens from owner to specified recipient
     * @param _to Recipient address
     * @param _value Token quantity to transfer
     * @return success/failure of transfer
     */
    function transferFromOwner(address _to, uint256 _value) PBKXcontractOnly returns (bool success) {
        return transfer(owner, _to, _value);
    }

    /**
     * @dev Transfers tokens from caller/method invoker/message sender to specified recipient
     * @param _to Recipient address
     * @param _value Token quantity to transfer
     * @return success/failure of transfer
     */
    function transfer(address _to, uint256 _value) returns (bool success) {
        return transfer(msg.sender, _to, _value);
    }

    /**
     * @dev Transfers tokens from specifed sender to specified recipient
     * @param _from Sender address
     * @param _to Recipient address
     * @param _value Token quantity to transfer
     * @return success/failure of transfer
     */
    function transfer(address _from, address _to, uint256 _value) private returns (bool success) {
        balanceFor[_from] = balanceFor[_from].sub(_value);
        balanceFor[_to] = balanceFor[_to].add(_value);

        return true;
    }
}
