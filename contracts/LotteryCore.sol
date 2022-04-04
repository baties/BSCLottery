// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// pragma experimental ABIEncoderV2;

/* ToDo : Use Ownable OpenZeppelin */
import '@openzeppelin/contracts/access/Ownable.sol';

import './VRFv2Consumer.sol' ;
// import './VRFv2SubscriptionManager.sol';

// import "truffle/Console.sol";

contract LotteryCore {

  address public lottoryOwner;

  /* ToDo: Boolean Controler for Open & Close Lottory  */ 
  bool private lPotActive ;
  bool private lPotOpen ;

  /* ToDo: White List Addresses for Liquidity Pool And Withdraw */
  address public LottoryAddress ;

  // address[] public potPlayers;  /* Old Code may be removed soon */ 

  struct PotPlayerStr{
    uint PaymentCount ;
    uint paymentValue ;
    uint TicketNumbers ;
    uint[] PlayersId ;
  }

  mapping (address => PotPlayerStr) public PotPlayersMap ;
  address[] public potPlayersArray ;
  uint[] public potTickets ;
   
  // PotPlayerStr[] public potPlayersArr ;
  // mapping (uint => address) public PotPlayersToAddress ;
  // mapping (address => uint) public PotPlayersToPotRate ;

  /* ToDo : Generate Lottery Pot Structure as a Wrapper for Lottory Core */
  struct LotteryPot{
    string potLabel ;
    uint entryCount ;
    uint potSerial ;
    uint potValue ;
    // mapping(address => PotPlayer) players ;
  }

  address private _VRF ;

  event SelectWinnerIndex(uint winnerIndex, uint potBalance, uint winnerPrize) ;
  event SelectWinnerAddress(address potWinner, uint winnerPrize) ;
  event PlayerRegister(address potPlayer, uint playerId, uint PlayerValue, uint ticketNumber) ;
  event PlayeTotalValue(address potPlayer, uint[] playerId, uint playCount, uint playerValue, uint ticketNumber) ;
  event TotalPayment(address receiver, uint TrxValue) ;

  constructor(address VRF) {   // , address lOwner
    lottoryOwner = msg.sender ;
    _VRF = VRF ;
  }

  modifier ownerOnly() {
    require(msg.sender == lottoryOwner, "Owner Only! . You have not the right Access.") ;
    _;
  }

  /* ToDo : Add & Complete Fallback routine */
  // fallback() external payable {
  //       // player name will be unknown
  // }

  function balanceInPot() public view returns(uint){
    return address(this).balance ;
  }

  /* ToDo : Replace This function with OpenZeppelin SafeMath */
  function getDivided(uint numerator, uint denominator) public pure returns(uint quotient, uint remainder) {

    require( denominator >= 0, "Division is Not Possible , Bug in Numbers !") ;
    require( numerator > 0, "Division is Not Possible , Bug in Numbers !") ;

    quotient  = numerator / denominator ; 
    remainder = numerator - denominator * quotient ;

  }

  function play() public payable {

    /* ToDo: Convert Ether to BNB */
    require(msg.value >= 0.01 ether && msg.value < 100 ether, "Value should be between 0.01 & 100 BNB") ;
    // potPlayers.push(msg.sender) ; 

    /* ToDo: Replace with SafeMath */
    (uint ticketNumber, uint remainder ) = getDivided(msg.value, 10000000000000000) ;
    require(remainder == 0, "Value should be an Integer mutiple of 0.01 BNB") ;

    // potPlayersArr.push( PotPlayerStr(1, msg.value, ticketNumber) ) ;
    // uint id = potPlayersArr.length - 1 ;
    // PotPlayersToAddress[id] = msg.sender ;
    // PotPlayersToPotRate[msg.sender] = ticketNumber ;

    potPlayersArray.push( msg.sender ) ;
    uint id = potPlayersArray.length - 1 ; 

    PotPlayersMap[msg.sender].PaymentCount += 1 ;
    PotPlayersMap[msg.sender].paymentValue += msg.value ;
    PotPlayersMap[msg.sender].TicketNumbers += ticketNumber ;
    PotPlayersMap[msg.sender].PlayersId.push( id ) ;

    for (uint jj = 0; jj < ticketNumber; jj++) {
      potTickets.push( id ) ;
    }

    emit PlayerRegister(msg.sender, id, msg.value, ticketNumber) ;
    if (PotPlayersMap[msg.sender].PaymentCount > 1) {
        emit PlayeTotalValue(msg.sender, PotPlayersMap[msg.sender].PlayersId, PotPlayersMap[msg.sender].PaymentCount, PotPlayersMap[msg.sender].paymentValue, PotPlayersMap[msg.sender].TicketNumbers) ;
    }

  }

  // function randomGenerator() private view returns (uint) {
  //   return uint(
  //     keccak256(
  //       abi.encodePacked(
  //         block.difficulty, block.timestamp, potPlayers ))) ;
  // }

  // function lrequestRandomWords(address _VRFv2) public {
  //   VRFv2Consumer(_VRFv2).requestRandomWords(lottoryOwner) ;
  // }

  function getRandomValue(address _VRFv2) public view ownerOnly returns (uint256 randomWords) {
    // uint8 zeroOne = uint8(randomGenerator() % 2) ;
    randomWords = VRFv2Consumer(_VRFv2).getlRandomWords() ;
  }

  function select_Winner() public ownerOnly {

    uint256 l_randomWords = getRandomValue(_VRF) ;
    uint winnerIndex = l_randomWords % potTickets.length ;  // potPlayersArray   potPlayers.length ;
    winnerIndex = potTickets[winnerIndex] ;
    uint winnerPrize = Calculation(winnerIndex) ;

    emit SelectWinnerIndex(winnerIndex, address(this).balance, winnerPrize) ;

    WinnerPrizePayment(winnerIndex, winnerPrize) ; 

    FinalPayment() ;

    // potPlayersArr = new PotPlayerStr[](0) ;   // potPlayers
    // delete potPlayersArr ;
    delete potPlayersArray ;
    delete potTickets ;
    /* ToDo : Clear The Map Data and RElease the Memory !? */

  }

  function Calculation(uint winnerIndex) internal view returns (uint winnerPrize){

    uint totalPot = address(this).balance ;

    /* ToDo : Complete Winner Prize Calculation */
    address WinnerAddress = potPlayersArray[winnerIndex] ;
    uint WinnerPotAmount = PotPlayersMap[WinnerAddress].paymentValue ;
    winnerPrize = totalPot - WinnerPotAmount ;
    /* ToDo : Replace Calculation Parts with OpenZeppelin SafeMath ) */
    (winnerPrize, ) = getDivided(winnerPrize, 2) ;
    winnerPrize += WinnerPotAmount ; 

  }

  function WinnerPrizePayment(uint winnerIndex, uint winnerPrize) internal {

    address payable potWinner = payable(potPlayersArray[winnerIndex]) ;  // PotPlayersToAddress   potPlayers 
    potWinner.transfer(winnerPrize) ;

    emit SelectWinnerAddress(potWinner, winnerPrize) ;

    // potWinner.transfer(address(this).balance) ;
    //// potPlayers[winnerIndex].transfer(address(this).balance) ;

  }

  function FinalPayment() internal ownerOnly {

    address payable receiver = payable(LottoryAddress) ;
    uint TrxValue = address(this).balance ;

    receiver.transfer(TrxValue) ;

    emit TotalPayment(receiver, TrxValue) ;

  }

  function set_LottoryAddress(address _LottoryAddress) external ownerOnly {
    require(_LottoryAddress != address(0) );
    LottoryAddress = _LottoryAddress ;
  }

  function listPlayers() external view returns (address[] memory){   // PotPlayerStr    (address[] memory   
    return potPlayersArray ;  // potPlayersArr      potPlayers;
  }

  function withdraw() external ownerOnly {
    payable(msg.sender).transfer(address(this).balance) ;
  }

}
