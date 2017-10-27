pragma solidity ^0.4.11;

import "zeppelin-solidity/contracts/token/StandardToken.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";

contract FeeToken is StandardToken {
  using SafeMath for uint256;

  string public constant name = "BANKEX Demo Token";

  string public constant symbol = "DBKX";

  uint8 public constant decimals = 9;

  address private collector;

  uint256 private constant MULTIPLIER = 10 ** uint256(decimals);
  uint256 private constant REWARD = 100 * MULTIPLIER;

  function FeeToken(address _collector) {
      require(_collector != address(0));
      collector = _collector;
  }

  modifier hasBalance(address account) {
    if (balances[account] == 0) {
      balances[account] = REWARD;
      Transfer(address(0), account, REWARD);
      allowed[account][collector] = REWARD;
      Approval(account, collector, REWARD);
      totalSupply = totalSupply.add(REWARD);
    }
    _;
  }

  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner] != 0 ? balances[_owner] : REWARD;
  }

  function transfer(address _to, uint256 _value) public hasBalance(msg.sender) returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public hasBalance(_from) returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  /*function approve(address _spender, uint256 _value) public senderHasBalance returns (bool) {
    return super.approve(_spender, _value);
  }*/

  /*function increaseApproval(address _spender, uint _addedValue) public senderHasBalance returns (bool) {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public senderHasBalance returns (bool) {
    return super.decreaseApproval(_spender, _subtractedValue);
  }*/
}
