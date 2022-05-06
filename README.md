# BSC Lottery 

This Repository Contains the Source Code of a Lottery Program which is Programmed by Solidity and Deployed on Binance Smart Chain . 

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

* *Node* v14.18.3
* *NPM* v6.14.10
* *Ganache CLI* v6.12.2 (ganache-core: 2.13.2)
* *Truffle* v5.4.16 (core: 5.4.16)
* *Solidity* v0.8.9 (solc-js)
* *Web3.js* v1.5.3
* *truffle-hdwallet-provider* v2.0.4
* *OpenZeppelin* v4.5.0
* *ChainLink* v0.4.0

### Additional Libraries Used

-  **Truffle**: To compile, test and migrate contracts.
-  **Solidity**: To compile Solidity codes.  
-  **Web3**: To Connect on BlockChain.
-  **truffle-hdwallet-provider**: Used to Manage connection to Wallet from Truffle.
-  **OpenZeppelin**: For Increase Security of Smart Contracts.
-  **ChainLink**: For Generating Random Number with ChainLink VRF v2 Library.
-  **Infura**: For Deploying Smart Contract.


### Installing

Clone this repository:

```
git clone https://github.com/baties/BSCLottery.git
```

Then Install all requisite npm packages (as listed in ```package.json```):

```
npm install
```

Launch Ganache:

```
ganache-cli 
```

In a separate terminal window, Compile smart contracts:

```
truffle compile
```

This will create the smart contract artifacts in folder ```build\contracts```.

Migrate smart contracts to the locally running blockchain, ganache-cli:

```
truffle migrate
```

Test smart contracts:

```
truffle test
```

All tests should pass.


In a separate terminal window, launch the DApp:

```
npm run dev
```

## Built With

* [Ethereum](https://www.ethereum.org/) - Ethereum is a decentralized platform that runs smart contracts
* [Truffle Framework](http://truffleframework.com/) - Truffle is the most popular development framework for Ethereum with a mission to make your life a whole lot easier.

## Acknowledgments

* Solidity  
* Ganache-cli
* Truffle


## Example workflow

* User identifies himself/herself with Metamask wallet.
* User can check his/her Balance in current Pot.
* User press Start to contribute in current Pot.
* User send some BNB(ETH) to the Smart Contract (Multiple of 0.01 BNB(ETH)).
* The Lottery Smart-Contract starts Lottery Process and choses the Winner of current Pot.   
* The Winner Prize will be transfered to the Winner Wallet.
* The result will be shown to the all users.

## Smart Contract Addresses on Rinkeby TestNet :

* *Deploy with Remix :*
    - **LotteryGenerator** : [0xd44e2Beb657cF17a298C1bF2bdDb3e4f1722949A](https://rinkeby.etherscan.io/address/0xd44e2Beb657cF17a298C1bF2bdDb3e4f1722949A)
    - **LotteryCore** : [0xD166681c76AADdc703dF06216159F8035B149d22](https://rinkeby.etherscan.io/address/0xD166681c76AADdc703dF06216159F8035B149d22)
    - **WeeklyLottery** : [0x09df50dC330e4C539864661D2692b835c6eC2070](https://rinkeby.etherscan.io/address/0x09df50dC330e4C539864661D2692b835c6eC2070)
    - **MonthlyLottery** : [0x8e613B525B183576fE13C939115BAf073fd3b73A](https://rinkeby.etherscan.io/address/0x8e613B525B183576fE13C939115BAf073fd3b73A)
    - **LotteryLiquidityPool** : [0x3F9d494C0117b455C8D51B5DA1B9667fbf3459B6](https://rinkeby.etherscan.io/address/0x3F9d494C0117b455C8D51B5DA1B9667fbf3459B6)
    - **LOtteryMultiSigWallet** : [](https://rinkeby.etherscan.io/address/)
* *Deploy with Truffle :*
    - **LotteryGenerator** : [](https://rinkeby.etherscan.io/address/)
    - **LotteryCore** : [](https://rinkeby.etherscan.io/address/)
    - **WeeklyLottery** : [](https://rinkeby.etherscan.io/address/)
    - **MonthlyLottery** : [](https://rinkeby.etherscan.io/address/)
    - **LotteryLiquidityPool** : [](https://rinkeby.etherscan.io/address/)
    - **LOtteryMultiSigWallet** : [](https://rinkeby.etherscan.io/address/)

## Smart Contract Addresses on Binance Smart Chain TestNet :

* *Deploy with Remix :*
    - **LotteryGenerator** : [0x4490bEAF312ec3948016b8ef43528c5ACDF5FDB7](https://rinkeby.etherscan.io/address/0x4490bEAF312ec3948016b8ef43528c5ACDF5FDB7)
    - **LotteryCore** : [0xdE2c8B2f097F13161B9501952097Ef6C10655dE4](https://rinkeby.etherscan.io/address/0xdE2c8B2f097F13161B9501952097Ef6C10655dE4)
    - **WeeklyLottery** : [0xe9F90ff51A50b69c84fF50CC5EE6D08Ce8CFc1bB](https://rinkeby.etherscan.io/address/0xe9F90ff51A50b69c84fF50CC5EE6D08Ce8CFc1bB)
    - **MonthlyLottery** : [0x1D1F2A6ae3E31Ad016a3E969392fCe130A4E4608](https://rinkeby.etherscan.io/address/0x1D1F2A6ae3E31Ad016a3E969392fCe130A4E4608)
    - **LotteryLiquidityPool** : [0x393660C3446Fb05ca9Cf4034568450d47d32a076](https://rinkeby.etherscan.io/address/0x393660C3446Fb05ca9Cf4034568450d47d32a076)
    - **LOtteryMultiSigWallet** : [](https://rinkeby.etherscan.io/address/)
* *Deploy with Truffle :*
    - **LotteryGenerator** : [](https://rinkeby.etherscan.io/address/)
    - **LotteryCore** : [](https://rinkeby.etherscan.io/address/)
    - **WeeklyLottery** : [](https://rinkeby.etherscan.io/address/)
    - **MonthlyLottery** : [](https://rinkeby.etherscan.io/address/)
    - **LotteryLiquidityPool** : [](https://rinkeby.etherscan.io/address/)
    - **LOtteryMultiSigWallet** : [](https://rinkeby.etherscan.io/address/)


