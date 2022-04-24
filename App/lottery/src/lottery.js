import App from './App';
import web3 from './web3';
const lottery_json = require("./contracts/LotteryCore.json");
// const lottery_json = require("./ABI/LotteryCore.js");

const abi = lottery_json["abi"];
const contractAddress = lottery_json["networks"]["4"]["address"];

console.log(contractAddress);

const MyContract = new web3.eth.Contract(abi, contractAddress);  // , {from: contractAddress}

// export default web3.eth.contract(abi).at(address);
export default MyContract;

// export default lottery_json; 

