# BSC Lottery 

This Repository Contains the Source Code of a Lottery Program which is Programmed by Solidity and Deployed on Rinkeby and Binance Smart Chain Testnet. 

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

* *Node* v14.18.3
* *NPM* v6.14.10
* *Ganache CLI* v6.12.2 (ganache-core: 2.13.2)
* *Truffle* v5.4.16 (core: 5.4.16)
* *Solidity* v0.8.13 (solc-js)
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
cd App/lottery
npm run dev
```

## Built With

* [Ethereum](https://www.ethereum.org/) - Ethereum is a decentralized platform that runs smart contracts.
* [Truffle Framework](http://truffleframework.com/) - Truffle is the most popular development framework for Ethereum with a mission to make your life a lot easier.
* [ChainLink](https://chain.link/) - Securely connect smart contracts with off-chain data and services.
* [OpenZeppelin](https://www.openzeppelin.com/) - The standard for secure blockchain applications.

## Acknowledgments

* Solidity  
* Ganache-cli
* Truffle

## Building & Running Notes 
* **VRF V2** :
    - In the new Version The Project can not be built under Ganache local Development because of useing VRFv2 Which is not accessible outside Testnet.
    - Please Replace the VRFv2 with randomGenerator to running The Test Module on local Development Platform without any problem. 
    - In the next Version The Test Module will be fully compatible with VRFv2.

## Example workflow

* User identifies himself/herself with Metamask wallet.
* User can check his/her Balance in current Pot.
* User press Start to contribute in current Pot.
* User send some BNB(ETH) to the Smart Contract (Multiple of 0.01 BNB(ETH)).
* The Lottery Smart-Contract starts Lottery Process and choses the Winner of current Pot.   
* The Winner Prize will be transfered to the Winner Wallet.
* The result will be shown to the all users.

## Smart Contract Addresses on Rinkeby TestNet :

* *Deployed The fifth Version with Truffle (Ver 0.52):*
    - **LotteryGenerator** : [0x8Ca9997FeeF619f0CcAf311a11A5cD304685709a](https://rinkeby.etherscan.io/address/0x8Ca9997FeeF619f0CcAf311a11A5cD304685709a)
    - **LotteryCore** : [0x61cBF84dA7494c50626DE9c89A65C59f639E8F22](https://rinkeby.etherscan.io/address/0x61cBF84dA7494c50626DE9c89A65C59f639E8F22)
    - **WeeklyLottery** : [0x9a944147a2f241081991C9ba0A7b01977bD4043a](https://rinkeby.etherscan.io/address/0x9a944147a2f241081991C9ba0A7b01977bD4043a)
    - **MonthlyLottery** : [0xDC2169250638b973C808BFa09D042C3Ab5Eb88d4](https://rinkeby.etherscan.io/address/0xDC2169250638b973C808BFa09D042C3Ab5Eb88d4)
    - **LotteryLiquidityPool** : [0x22515475372968c8536A0439885C99F91F30aE43](https://rinkeby.etherscan.io/address/0x22515475372968c8536A0439885C99F91F30aE43)
    - **LOtteryMultiSigWallet** : [0x82B0f049AD24d10bc88d2dDd621fC8b69f55B778](https://rinkeby.etherscan.io/address/0x82B0f049AD24d10bc88d2dDd621fC8b69f55B778)

* *Deployed The last Version with Truffle (Ver 0.67):*
    - **LotteryGenerator** : [0x431C5F98AAfA8F15d8B94e784E655d718dC2F140](https://rinkeby.etherscan.io/address/0x431C5F98AAfA8F15d8B94e784E655d718dC2F140)
    - **LotteryCore** : [0xCd428fFa0883A0481DCb2208f70262b5F1d28190](https://rinkeby.etherscan.io/address/0xCd428fFa0883A0481DCb2208f70262b5F1d28190)
    - **WeeklyLottery** : [0x6C28637Bd295E4B9437046C8999EB6Ab0d0df004](https://rinkeby.etherscan.io/address/0x6C28637Bd295E4B9437046C8999EB6Ab0d0df004)
    - **MonthlyLottery** : [0xc33050450c9594E66B9Bd9a6a45435377AED3302](https://rinkeby.etherscan.io/address/0xc33050450c9594E66B9Bd9a6a45435377AED3302)
    - **LotteryLiquidityPool** : [0x8fd14c70FacD0f9AF9EfD5Cfd065262891D2538d](https://rinkeby.etherscan.io/address/0x8fd14c70FacD0f9AF9EfD5Cfd065262891D2538d)
    - **LOtteryMultiSigWallet** : [0x45a7Ec234473E4e2237808999dfDb9805d976AfE](https://rinkeby.etherscan.io/address/0x45a7Ec234473E4e2237808999dfDb9805d976AfE)

## Smart Contract Addresses on Binance Smart Chain TestNet :

* *Deployed the fourth Version with Truffle (Ver 0.41):*
    - **LotteryGenerator** : [0xf415f0c24cFA775d566De6B8c8Afe7098448FEfa](https://testnet.bscscan.com/address/0xf415f0c24cFA775d566De6B8c8Afe7098448FEfa)
    - **LotteryCore** : [0xc65d246f01EF7c04a95DD8429BbfA126d8272549](https://testnet.bscscan.com/address/0xc65d246f01EF7c04a95DD8429BbfA126d8272549)
    - **WeeklyLottery** : [0xc6e5ba1D46e7f7a1A674AC6979f9228f9CE9AA1D](https://testnet.bscscan.com/address/0xc6e5ba1D46e7f7a1A674AC6979f9228f9CE9AA1D)
    - **MonthlyLottery** : [0xDc458c1968E40361E46E6FAa0f5E83f985058c3b](https://testnet.bscscan.com/address/0xDc458c1968E40361E46E6FAa0f5E83f985058c3b)
    - **LotteryLiquidityPool** : [0xc52E5BC3D189c2f2621A3432e74787202b42D79A](https://testnet.bscscan.com/address/0xc52E5BC3D189c2f2621A3432e74787202b42D79A)
    - **LOtteryMultiSigWallet** : [0x32b02534dbDf25eF66e53C4c1501eF28aa9274a4](https://testnet.bscscan.com/address/0x32b02534dbDf25eF66e53C4c1501eF28aa9274a4)

* *Deployed the last Version with Truffle (Ver 0.68):*
    - **LotteryGenerator** : [0x68DbB384580A0690b596D529a110b6eae8849E6a](https://testnet.bscscan.com/address/0x68DbB384580A0690b596D529a110b6eae8849E6a)
    - **LotteryCore** : [0xe0929aEF517b6E383e14585Ad39d1d94967ED639](https://testnet.bscscan.com/address/0xe0929aEF517b6E383e14585Ad39d1d94967ED639)
    - **WeeklyLottery** : [0xee9e2cdd2b433B88d6188641C85F87d6D658E794](https://testnet.bscscan.com/address/0xee9e2cdd2b433B88d6188641C85F87d6D658E794)
    - **MonthlyLottery** : [0xE928D1D1fEb0b6Ac8BC93c21a3a2B0A433F8f4b5](https://testnet.bscscan.com/address/0xE928D1D1fEb0b6Ac8BC93c21a3a2B0A433F8f4b5)
    - **LotteryLiquidityPool** : [0xAed4A0BF40F525F3Db93FF0cFf389AE293082300](https://testnet.bscscan.com/address/0xAed4A0BF40F525F3Db93FF0cFf389AE293082300)
    - **LOtteryMultiSigWallet** : [0x7AcA8025E7C6221526f16762eEF147fE79ACb652](https://testnet.bscscan.com/address/0x7AcA8025E7C6221526f16762eEF147fE79ACb652)

## Final word :

* *Supporting :*
    - If you like this repository and find it useful please give it a **star** and **fork** it if you want to develop your own version.
* *Contribution :*
    - Any contribution will be accepted so please just send me a contribution request.
* *ContactMe :*
    - you can send me any suggestion via this Email Address : **abhari.batis@gmail.com** 


