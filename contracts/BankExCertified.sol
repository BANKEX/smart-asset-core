pragma solidity ^0.4.10;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

contract BankExCertified is Ownable {

    mapping(address => bool) private certified;

    function certify(address _address) onlyOwner() {
        certified[_address] = true;
    }

    function unCertify(address _address) onlyOwner() {
        delete certified[_address];
    }

    function isCertified(address _address) constant returns(bool) {
        return certified[_address];
    }

}
