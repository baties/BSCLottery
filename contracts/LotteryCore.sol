// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

/* ToDo : Use Ownable OpenZeppelin */
import '@openzeppelin/contracts/access/Ownable.sol';
import './VRFv2Consumer.sol' ;
// import './VRFv2SubscriptionManager.sol';
// import "truffle/Console.sol";

contract LotteryCore {

  address public lottoryOwner;
  address[] public potPlayers;  /* Old Code may be removed soon */

  struct PotPlayerStr{
    uint PaymentCount ;
    uint paymentValue ;
    uint TicketNumbers ;
  }

  PotPlayerStr[] public potPlayersArr ;
  mapping (uint => address) public PotPlayersToAddress ;
  mapping (address => uint) public PotPlayersToPotRate ;

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

  constructor(address VRF) {
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
    quotient  = numerator / denominator ;
    remainder = numerator - denominator * quotient ;
  }

  function play() public payable {
    /* ToDo: Convert Ether to BNB */
    require(msg.value >= 0.01 ether && msg.value < 100 ether, "Value should be between 0.01 & 100 BNB") ;
    // potPlayers.push(msg.sender) ; 
    (uint ticketNumber, ) = getDivided(msg.value, 10000000000000000) ;
    /* ToDo: find Players old Contribution if any , 
             And Calculate Total Value and Contribution Count */
    potPlayersArr.push( PotPlayerStr(1, msg.value, ticketNumber) ) ;
    uint id = potPlayersArr.length - 1 ;
    PotPlayersToAddress[id] = msg.sender ;
    PotPlayersToPotRate[msg.sender] = ticketNumber ;
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

  function getRandomValue(address _VRFv2) public view returns (uint256 randomWords) {
    // uint8 zeroOne = uint8(randomGenerator() % 2) ;
    randomWords = VRFv2Consumer(_VRFv2).getlRandomWords() ;
  }

  function select_Winner() public ownerOnly {
    uint256 l_randomWords = getRandomValue(_VRF) ;
    uint winnerIndex = l_randomWords % potPlayersArr.length ;  // potPlayers.length ;
    uint winnerPrize = Calculation(winnerIndex) ;
    emit SelectWinnerIndex(winnerIndex, address(this).balance, winnerPrize) ;
    WinnerPrizePayment(winnerIndex, winnerPrize) ; 
    // potPlayersArr = new PotPlayerStr[](0) ;   // potPlayers
    delete potPlayersArr ;
  }

  function Calculation(uint winnerIndex) internal returns (uint winnerPrize){
    uint totalPot = address(this).balance ;
    /* ToDo : Complete Winner Prize Calculation */
    winnerPrize = 
  }

  function WinnerPrizePayment(uint winnerIndex, uint winnerPrize) internal {
    address payable potWinner = payable(PotPlayersToAddress[winnerIndex]) ;  // potPlayers 
    potWinner.transfer(winnerPrize) ;
    emit SelectWinnerAddress(potWinner, winnerPrize) ;
    // potWinner.transfer(address(this).balance) ;
    //// potPlayers[winnerIndex].transfer(address(this).balance) ;
  }

  function listPlayers() external view returns (PotPlayerStr[] memory){   // (address[] memory
    return potPlayersArr ;  // potPlayers;
  }

  function withdraw() external ownerOnly {
    payable(msg.sender).transfer(address(this).balance) ;
  }

}
