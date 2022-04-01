// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import './VRFv2Consumer.sol' ;
// import './VRFv2SubscriptionManager.sol';
// import "truffle/Console.sol";


contract LotteryCore {

  address public lottoryOwner;
  address[] public potPlayers;

  struct PotPlayer{
    uint index;
    uint pValue;
  }

  struct LotteryPot{
    string potLabel;
    uint entryCount;
    uint potSerial;
    uint potValue;
    // mapping(address => PotPlayer) players;
  }

  address private _VRF;

  event SelectWinner(address potWinner, uint potBalance);

  constructor(address VRF) {
    lottoryOwner = msg.sender;
    _VRF = VRF;
  }

  modifier ownerOnly() {
    require(msg.sender == lottoryOwner, "Owner Only! . You have not the right Access.");
    _;
  }

  // fallback() external payable {
  //       // player name will be unknown
  // }

  function balanceInPot() public view returns(uint){
    return address(this).balance;
  }

  function play() public payable {
    require(msg.value >= 0.01 ether && msg.value < 100 ether, "Value should be between 0.01 & 100 BNB");
    potPlayers.push(msg.sender);
  }

  function randomGenerator() private view returns (uint) {
    return uint(
      keccak256(
        abi.encodePacked(
          block.difficulty, block.timestamp, potPlayers )));
  }

  function getRandomValue(address _VRFv2) public view returns (uint256 randomWords) {
    uint8 zeroOne = uint8(randomGenerator() % 2);
    randomWords = VRFv2Consumer(_VRFv2).getlRandomWords(zeroOne) ;
  }

  function select_Send_WinnerPrize() public ownerOnly {
    uint256 l_randomWords = getRandomValue(_VRF);
    uint winnerIndex = l_randomWords % potPlayers.length;
    address payable potWinner = payable(potPlayers[winnerIndex]);
    potPlayers = new address[](0);
    emit SelectWinner(potWinner, address(this).balance);
    potWinner.transfer(address(this).balance);
    // potPlayers[winnerIndex].transfer(address(this).balance);
    // console.log(potWinner);
  }

  function listPlayers() public view returns (address[] memory){
    return potPlayers;
  }

  function withdraw() external ownerOnly {
    payable(msg.sender).transfer(address(this).balance);
  }

}
