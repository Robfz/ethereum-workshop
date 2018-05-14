pragma solidity ^0.4.23;

contract Coin { 
  // Events
  event CoinTransfer(address sender, address receiver, uint amount);
  
  // State data
  mapping(address => uint) public coinBalanceOf;
  
  constructor(uint supply) public {
    coinBalanceOf[msg.sender] = supply;
  }
  
  /* Very simple trade function */
  function sendCoin(address receiver, uint amount) public returns(bool sufficient) {
    if (coinBalanceOf[msg.sender] < amount) {
      return false;
    }

    coinBalanceOf[msg.sender] -= amount;
    coinBalanceOf[receiver] += amount;

    emit CoinTransfer(msg.sender, receiver, amount);

    return true;
  }
}

