pragma solidity ^0.4.10;

import 'zeppelin-solidity/contracts/lifecycle/Destructible.sol';

contract BankExCertifiedStorage is Destructible {

    address bankExCertifiedAddress;
    mapping(address => bool) private certified;

    modifier onlyBankExCertified() {
        require(msg.sender == bankExCertifiedAddress);
        _;
    }

    function addCertified(address _address) onlyBankExCertified {
        certified[_address] = true;
    }

    function removeCertified(address _address) onlyBankExCertified {
        delete certified[_address];
    }

    function isCertified(address _address) constant returns(bool) {
        return certified[_address];
    }

    function setBankExCertifiedAddress(address _bankExCertifiedAddress) onlyOwner {
        bankExCertifiedAddress = _bankExCertifiedAddress;
    }
}
