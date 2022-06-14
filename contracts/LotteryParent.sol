// SPDX-License-Identifier: GNU-GPLv3
pragma solidity ^0.8.0;
// pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./VRFv2Consumer.sol";
import "./VRFv2SubscriptionManager.sol";

/**
  * @title Parent SmartContract for BNB Public Lottery 
  * @author Batis 
  * @notice This SmartContract is responsible for implimentation of All Common Functions in one place
  * @dev LotteryParent SmartContract 
*/
contract LotteryParent is Ownable {

  address private _VRF;
  address private generatorLotteryAddr;

  uint constant TICKET_PRICE = 10 * 1e15; // finney (0.01 Ether)
  bool private lPotActive;  /* ToDo: Boolean Controler for Open & Close Lottery  */

  constructor(address VRF) {   // , address lOwner
    _VRF = VRF;
  }

  fallback() external payable {
  }
  receive() external payable {
  }

  function balanceInPot() public view returns(uint){
    return address(this).balance;
  }

  function withdraw() external onlyOwner {
    payable(msg.sender).transfer(address(this).balance);
  }

  /*
  function randomGenerator() private view returns (uint) {
    return uint(
      keccak256(
        abi.encodePacked(
          block.difficulty, block.timestamp, potTickets ))) ;
  }
  */

  /*
  function lrequestRandomWords(address _VRFv2) public {
    VRFv2Consumer(_VRFv2).requestRandomWords(LotteryOwner) ;
  }
  */

  function getRandomValue(address _VRFv2) public view onlyOwner returns (uint256 randomWords) {
    // uint8 zeroOne = uint8(randomGenerator() % 2);
    randomWords = VRFv2Consumer(_VRFv2).getlRandomWords();
  }

  /* ToDo : Replace This function with OpenZeppelin SafeMath */
  /**
    * @notice Function for deviding two Integer Numbers and return the results.
    * @dev Safe Function for Devision Operation.
    * @param numerator : The Integer Number which is being devided on another Integer Number.
    * @param denominator : The Integer Number which another Int NUmber is devided by this.  
    * @return quotient and remainder of the Devision, Both are Integer Numbers. 
  */
  function getDivided(uint numerator, uint denominator) public pure returns(uint quotient, uint remainder) {
    require( denominator >= 0, "Division is Not Possible , Bug in Numbers !");
    require( numerator > 0, "Division is Not Possible , Bug in Numbers !");
    quotient  = numerator / denominator; 
    remainder = numerator - denominator * quotient;
  }

  function generatorLotteryAddress(address _contractAddr) external onlyOwner {
    generatorLotteryAddr = _contractAddr;
  }

}