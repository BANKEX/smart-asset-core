pragma solidity ^0.4.10;


contract BankExCertified {

    mapping(address => bool) private certified;
    address private owner;

    modifier onlyOwner {
        if (msg.sender != owner)
        throw;
        _;
    }

    function BankExCertified() {
        owner = msg.sender;
    }

    function certify(address _address) onlyOwner() {
        certified[_address] = true;
    }

    function unCertify(address _address) onlyOwner() {
        certified[_address] = false;
    }

    function isCertified(address _address) constant returns(bool) {
        return certified[_address];
    }

}