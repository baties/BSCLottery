import App from './App';
import web3 from './web3';

// import detectEthereumProvider from '@metamask/detect-provider';

const lottery_json = require("./contracts/LotteryCore.json");
// const lottery_json = require("./ABI/LotteryCore.js");

const abi = lottery_json["abi"];
const contractAddress = lottery_json["networks"]["4"]["address"];

// console.log(contractAddress);

const MyContract = new web3.eth.Contract(abi, contractAddress);  // , {from: contractAddress}
console.log("Lottery Contract Address is : " + contractAddress);

MyContract.setProvider(`wss://rinkeby.infura.io/ws/v3/${process.env.REACT_APP_INFURA_PROJECT_ID}`);
// MyContract.setProvider(new web3.providers.HttpProvider('http://localhost:7545'));

// const provider = detectEthereumProvider();
// const provider = web3.provider;
// MyContract.setProvider(provider);

// export default web3.eth.contract(abi).at(address);
export default MyContract;

// export default lottery_json; 

