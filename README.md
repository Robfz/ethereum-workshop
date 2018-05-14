## Ethereum node installation

Add the Geth repository:

```
sudo add-apt-repository -y ppa:ethereum/ethereum

```

Then, install Geth:

```
sudo apt-get update
sudo apt-get install ethereum
```

Create a new folder and `cd` into it:

```
mkdir Ethereum
cd Ethereum
```

Create a new file named `genesis.json`:

```
touch genesis.json
```

Write the following into `genesis.json`:

```
{
    "nonce": "0x0000000000000042",
    "timestamp": "0x00",
    "parentHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
    "extraData": "0x00",
    "gasLimit": "0x8000000",
    "difficulty": "0x400",
    "mixhash": "0x0000000000000000000000000000000000000000000000000000000000000000",
    "coinbase": "0x3333333333333333333333333333333333333333",
    "alloc": {
    },
    "config": {
        "chainId": 987654321,
        "homesteadBlock": 0,
        "eip155Block": 0,
        "eip158Block": 0
    }
}
```

Now lets seed the blockchain:

```
geth --datadir .ethereum_private init genesis.json

```

Now lets run the node and bring up the console interface:

```
geth --identity "Name" --ipcpath ~/Library/Ethereum/geth.ipc --networkid 3631098 --datadir .ethereum_private console --nodiscover --rpc --rpccorsdomain * --rpcaddr 0.0.0.0 --rpcport 8545 --rpcapi "db,eth,net,web3" --maxpeers 100
```
Flags that we are using:

`--indentity` custom node name
 
`--ipcpath` file for IPC (useful for running multiple nodes in the same computer)

`--networkid` network identifier

`--datadir` data directory for the databases and keystore

`console` starts an interactive JavaScript environment

`--nodiscover` disables the peer discovery mechanism (we will be adding peer nodes manually)

`--rpc` enables the HTTP-RPC server

`--rpccorsdomain` list of domains from which to accept cross origin requests (we will be using the * wildcard)

`--rpcaddr` HTTP-RPC server listening interface (we will be using the 0.0.0.0 wildcard)

`--rpcport` HTTP-RPC server listening port

`--rpcapi` API's offered over the HTTP-RPC interface (we will offer `db`, `eth`, `net` and `web3`)

`--maxpeers` Maximum amount of simulatneous network peers (full nodes)

## Transferring Ether

Create an account:

```
personal.newAccount()
```

Check the new account print the `eth.accounts` array:

```
eth.accounts
```

Now, we may start mining:

```
miner.start(<number of threads>)
```

Due to our server constraints, use a single thread:

```
miner.start(1)
```

```
web3.fromWei(eth.getBalance(eth.accounts[0]))
```

Peers are manually added using node address. To get your node address use:

```
admin.nodeInfo
```

Output:

```
{
  enode: "enode://5f370345934fbd4f10234f447840e82ab01cb6db0c2b5c43c527374f23a3b04ca7727875ed51c7f5a34655861eb614bbb37897e6a36f2e5c11df7e20ad8c31e6@[::]:30303?discport=0",
  id: "5f370345934fbd4f10234f447840e82ab01cb6db0c2b5c43c527374f23a3b04ca7727875ed51c7f5a34655861eb614bbb37897e6a36f2e5c11df7e20ad8c31e6",
  ip: "::",
  listenAddr: "[::]:30303",
  name: "Geth/Name/v1.8.7-stable-66432f38/linux-amd64/go1.10",
  ports: {
    discovery: 0,
    listener: 30303
  },
  protocols: {
    eth: {
      config: {
        chainId: 987654321,
        eip150Hash: "0x0000000000000000000000000000000000000000000000000000000000000000",
        eip155Block: 0,
        eip158Block: 0,
        homesteadBlock: 0
      },
      difficulty: 245929658,
      genesis: "0x6650a0ac6c5e805475e7ca48eae5df0e32a2147a154bb2222731c770ddb5c158",
      head: "0x75c50a7fe61c47a49a3cc41cc54170d3bcef6e16c1ec6f3861f3b3266c3eaebe",
      network: 3631098
    }
  }
}
```

We need the `enode` attribute of the returned object. In this case:

```
enode: "enode://5f370345934fbd4f10234f447840e82ab01cb6db0c2b5c43c527374f23a3b04ca7727875ed51c7f5a34655861eb614bbb37897e6a36f2e5c11df7e20ad8c31e6@[::]:30303?discport=0"
```
To add this node as a peer (in another node), we need to delete the `?discport=0` and replace the `[::]` with the public IP of the server:

```
admin.addPeer("enode://0e2b3a42dca53e36b8588a65384c85484c9534409e791ec101ef32be90de2b932e4741894436e55a3895a48bbfd18a466ee51124937b0fd858335565a7e2b382@40.117.248.235:30303")
```

Now we can send ether to other accounts:

```
eth.sendTransaction({  
	from: eth.accounts[0],
	to: "0xb30a296fef21542dbccd87a3a5143d3fb8bc36ca",
	value: web3.toWei(1, "ether"),
	gas: 22000,
	gasPrice: web3.toWei(45,"Shannon"),
	data: web3.toHex('mytransaction')
})
```

We can check that the `to` account will have 1 more ether:

```
web3.fromWei(eth.getBalance("0xb30a296fef21542dbccd87a3a5143d3fb8bc36ca"))
```

## Smart Contracts

First we need a compiler for Solidity, the programming language used to code Smart Contracts.

First install `nvm` (so we can install `node` easily):

```
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
```
Source `.bashrc` to make `nvm` available in the command line:

```
source ~/.bashrc
```
Install `node` using `nvm`:

```
nvm install v8.11
```
Finally install `solcjs` (a compiler of Solidity written in Javascript):

```
npm install -g solc
```

### Our first contract

Create a file named `Greeter.sol` and copy this code into it:

```
pragma solidity ^0.4.23;

contract Mortal {
    /* Define variable owner of the type address */
    address owner;

    /* This function is executed at initialization and sets the owner of the contract */
    constructor() public { owner = msg.sender; }

    /* Function to recover the funds on the contract */
    function kill() public { if (msg.sender == owner) selfdestruct(owner); }
}

contract Greeter is Mortal {
    /* Define variable greeting of the type string */
    string greeting;

    /* This runs when the contract is executed */
    constructor(string _greeting) public {
        greeting = _greeting;
    }

    /* Main function */
    function greet() public constant returns (string) {
        return greeting;
    }
}
```

To load the contract into the Ethereum Blockchain:

```
var greeterFactory = eth.contract(<contents of the file Greeter.abi>)

var greeterCompiled = "0x" + "<contents of the file Greeter.bin>"
```
To instanciate the contract:

```
var greetMessage = "Test string"

var greeter = greeterFactory.new(greetMessage, {
  from: eth.accounts[0],
  data: greeterCompiled, 
  gas: 47000
}, function(e, contract) {
  if (e) {
    console.error(e);
    return;
  } 
  if(!contract.address) {
    console.log("Contract transaction send: TransactionHash: " + contract.transactionHash + " waiting to be mined...");
  } else {
    console.log("Contract mined! Address: " + contract.address);
    console.log(contract);
  }
});

// One line version
var greeter = greeterFactory.new(greetMessage,{from:eth.accounts[0],data:greeterCompiled,gas:47000}, function(e, contract){ if(e) { console.error(e); return; } if(!contract.address) { console.log("Contract transaction send: TransactionHash: " + contract.transactionHash + " waiting to be mined..."); } else { console.log("Contract mined! Address: " + contract.address); console.log(contract); }});
```

To interact with the contract:

```
greeter.greet().call();
```

This will output:

```
"Test string"
```

To kill the contract (and clean the blockchain), we use:

```
greeter.kill.sendTransaction({
	from: eth.accounts[0]
});
```

Too verify that the contracts has been terminated, we check the following command returns `0`.

```
eth.getCode(greeter.contractAddress);
```

### A more complex contract

Create a file named `Counter.sol` and copy this code into it:

```
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

```

Instantiate the contract the same way as the first example:

```
var factory = eth.contract(<contents of ABI file>);

var compiled = "0x" + "<contents of BIN file>";

var maxCount = 120;

var contract = factory.new(maxCount, {
  from: eth.accounts[0],
  data: compiled,
  gas: 47000
}, function(e, contract) {
  if(e) {
    console.error(e);
    return;
  } 
  if (!contract.address) {
    console.log("Contract transaction send: TransactionHash: " + contract.transactionHash + " waiting to be mined...");
  } else {
    console.log("Contract mined! Address: " + contract.address);
    console.log(contract);
  }
});

// One line version
var contract = factory.new(120, {from:eth.accounts[0],data:compiled,gas:47000}, function(e, contract){ if(e) { console.error(e); return; } if(!contract.address) { console.log("Contract transaction send: TransactionHash: " + contract.transactionHash + " waiting to be mined..."); } else { console.log("Contract mined! Address: " + contract.address); console.log(contract); }});

```

Since this contract actually writes data to the blockchain, we need to interact with it using `sendTransaction`:

```
var txnHash = contract.increase.sendTransaction({  
	from: eth.accounts[0]
});
```

`txnHash` now contains the TXN id. We need to wait for the transaction to be mined.

When can check the `count` value using:

```
contract.getCount.call();
```

Once the TXN has been included in the Blockchain, we can inspect it using:

```
web3.eth.getTransactionReceipt(txnHash);
```
#### Events

We can add watchers to the events we defined in the contract:

```
// Instantiate the event
var event = contract.IncreasedCount({});

event.watch(function(err, result) {
  if (err) {
    console.log(err);
    return;
  }
  console.log('Increased by address: ' + result.args.from);
});
```
Now each time a `IncreasedCount` event happens, we will be notified.

### Simple Coin

Code:

```
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
```

Once instantiated, create a watcher for the `CoinTransfer` event:

```
var transferEvent = coins.CoinTransfer({});

transferEvent.watch(function(err, result) {
  if (err) {
    console.log(err)
    return;
  }
  var sender = result.args.sender;
  var receiver = result.args.receiver;
  var amount = result.args.amount
  console.log('Coin tranfer from: ' + sender + ' to: ' + receiver + ', amount: ' + amount);
});
```
Since the `coinBalanceOf` mapping of the contract is public, we can access it from the console:

```
coins.coinBalanceOf(<address>);
```

To send some coins to other addresses (in this example, 20 coins):

```
coins.sendCoin.sendTransaction("<address>", 20, {
  from: eth.accounts[0]
});
```

## Tips

- `debug.verbosity(x);` use this if you are uncomfortable with all the mining logs when using the `geth` console. Accepts values from 1 to 5 (1 being less logs).

- `personal.unlock('address', null, 0);` use this command to unlock an address until you exit `geth`.