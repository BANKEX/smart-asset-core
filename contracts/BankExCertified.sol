pragma solidity ^0.4.15;

import 'zeppelin-solidity/contracts/lifecycle/Destructible.sol';
import './BankExCertifiedStorage.sol';


contract BankExCertified is Destructible  {

    BankExCertifiedStorage bankExCertifiedStorage;

    function certify(address _address) onlyOwner() {
        //some other logic  if else
        bankExCertifiedStorage.addCertified(_address);
    }

    function unCertify(address _address) onlyOwner() {
        bankExCertifiedStorage.removeCertified(_address);
    }

    function isCertified(address _address) constant returns(bool) {
        return bankExCertifiedStorage.isCertified(_address);
    }

    function setStorageAddress(address _bankExCertifiedStorage) onlyOwner {
        bankExCertifiedStorage = BankExCertifiedStorage(_bankExCertifiedStorage);
    }

}
