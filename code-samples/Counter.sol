pragma solidity ^0.4.23;

contract Counter {
  // Events
  event IncreasedCount(address indexed from);
  event MaxCountAchieved(address indexed from);

  // State variables
  // These are stored in the Blockchain!
  uint counter;
  uint maxCalls;

  // Contructor (called when the contract is instantiated)
  constructor(uint _maxCalls) public {
    maxCalls = _maxCalls;
    counter = 0;
  }

  function increase() public {
    if (maxCalls == counter) {
      emit MaxCountAchieved(msg.sender);
    } else {
      counter = counter + 1;
      emit IncreasedCount(msg.sender);
    }
  }

  function getCount() constant public returns(uint) {
    return counter;
  }

  function getMaxCalls() constant public returns(uint) {
    return maxCalls;
  }
}

