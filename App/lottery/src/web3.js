import Web3 from 'web3' ;

// const web3 = new Web3(window.web3.currentProvider);

const web3 = new Web3(window.ethereum.currentProvider);

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
  


export default web3;
