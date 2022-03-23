// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

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
    require(msg.sender == lottoryOwner, "Owner Only! . You have not the right Access.");
    _;
  }

  fallback() external payable {
        // player name will be unknown
  }

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

  function select_Send_WinnerPrize() public ownerOnly {
    uint winnerIndex = randomGenerator() % potPlayers.length;
    address payable potWinner = payable(potPlayers[winnerIndex]);
    potPlayers = new address[](0);
    potWinner.transfer(address(this).balance);
    // potPlayers[winnerIndex].transfer(address(this).balance);
  }

  function listPlayers() public view returns (address[] memory){
    return potPlayers;
  }

}
