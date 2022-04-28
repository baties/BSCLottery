import Web3 from 'web3' ;

// const web3 = new Web3(window.web3.currentProvider);

const web3 = new Web3(window.ethereum.currentProvider);
// web3.setProvider(new web3.providers.HttpProvider('http://localhost:8545'));

// if (window.ethereum) {
//     App.web3Provider = window.ethereum;
//     try {
//       // Request account access
//       await window.ethereum.enable();
//     } catch (error) {
//       // User denied account access...
//       console.error("User denied account access")
//     }
//   }
//   // Legacy dapp browsers...
//   else if (window.web3) {
//     App.web3Provider = window.web3.currentProvider;
//   }
//   // If no injected web3 instance is detected, fall back to Ganache
//   else {
//     App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
//   }
//   web3 = new Web3(App.web3Provider);
  

// var Web3 = require('web3');
// var provider = 'http://localhost:7545';
// var web3Provider = new Web3.providers.HttpProvider(provider);
// var web3 = new Web3(web3Provider);
// web3.eth.getBlockNumber().then((result) => {
//   console.log("Latest Ethereum Block is ",result);
// });


export default web3;
