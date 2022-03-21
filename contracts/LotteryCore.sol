// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";


contract LotteryCore is Ownable, VRFConsumerBase {

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

  constructor() public {
    lottoryOwner = msg.sender;
  }

  modifier ownerOnly() {
    require(msg.sender == lottoryOwner);
    _;
  }

  function () public payable {
        // player name will be unknown
  }

  function play() public payable {
    require(msg.value >= 0.01 ether && msg.value < 100 ether);
    potPlayers.push(msg.sender);
  }

  function randomGenerator() private view returns (uint) {
    return uint(
      keccak256(
        abi.encodePacked(
          block.difficulty, now, potPlayers )));
  }

  function sendWinnerPrize() public ownerOnly {
    uint winnerIndex = randomGenerator() % potPlayers.length;
    potPlayers[winnerIndex].transfer(address(this).balance);

    potPlayers = new address[](0);
  }

  function listPlayers() public view returns (address[]){
    return potPlayers;
  }

}
