pragma solidity ^0.4.10;


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
contract BKXToken {
    // Token-related properties/description to display in Wallet client / UI
    string public standard = 'BKXToken 0.1';
    string public name = 'BKXToken';
    string public symbol = 'BKX';

    // Contract creator/author/person who's deployed it
    address owner;

    // Presale token contract which required for granular access while doing Presale -> ICO token exchange from within Presale contract
    address PBKXcontract;
    // Smart Asset Contract address
    address smartAssetContract;

    mapping (address => uint256) balanceFor;

    // Modifiers
    modifier owneronly { if (msg.sender == owner) _; }
    modifier PBKXcontractOnly { if (msg.sender == PBKXcontract) _; }
    modifier smartAssetContractOnly { if (msg.sender == smartAssetContract) _; }

    /**
     * @dev ICO contract constructor
     */
    function BKXToken() {
        owner = msg.sender;
        balanceFor[msg.sender] = 3000000; // TODO: Define total amount of ICO tokens
    }

    /**
     * @dev Set/change contract owner
     * @param _owner owner address
     */
    function setOwner(address _owner) owneronly {
        owner = _owner;
    }

    /**
     * @dev Set/change presale contract address
     * @param _PBKXcontract Presale contract address
     */
    function setPBKXcontract(address _PBKXcontract) owneronly {
        PBKXcontract = _PBKXcontract;
    }

    /**
     * @dev Set/change smart asset contract address
     * @param _smartAssetContract smart asset contract address
     */
    function setSmartAssetContract(address _smartAssetContract) owneronly {
        smartAssetContract = _smartAssetContract;
    }

    /**
     * @dev Removes a specified ammount from a specified address
     * @param _address Account address from which the amount will be deducted
     * @param amount the amount to deduct
     */
    function burn(address _address, uint amount) smartAssetContractOnly() {
        if(balanceFor[_address] < amount) {
            throw;
        }
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
     * @dev Removes/deletes contract
     */
    function kill() owneronly {
        suicide(msg.sender);
    }

    /**
     * @dev Transfers tokens from specifed sender to specified recipient
     * @param _from Sender address
     * @param _to Recipient address
     * @param _value Token quantity to transfer
     * @return success/failure of transfer
     */
    function transfer(address _from, address _to, uint256 _value) private returns (bool success) {
        if (balanceFor[_from] < _value) throw;           // Check if the sender has enough
        if (balanceFor[_to] + _value < balanceFor[_to]) throw; // Check for overflows
        balanceFor[_from] -= _value;                     // Subtract from the sender
        balanceFor[_to] += _value;                            // Add the same to the recipient
        return true;
    }
}
