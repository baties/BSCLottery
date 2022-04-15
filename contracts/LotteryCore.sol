// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// pragma experimental ABIEncoderV2;

/* ToDo : Use Ownable OpenZeppelin */
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./LotteryGenerator.sol";
import "./VRFv2Consumer.sol";
import "./VRFv2SubscriptionManager.sol";

// import "truffle/Console.sol";


/**
************************************************************************************
************************************************************************************
*/

/**
  * @title Core SmartContract for BNB Public Lottery 
  * @author Batis 
  * @notice This SmartContract is responsible for implimentation of Lottery Core System and response to the Players 
  * @dev LotteryGenerator SmartContract Create This for each Pot 
*/
contract LotteryCore is Ownable {

  uint constant TICKET_PRICE = 10 * 1e15; // finney (0.01 Ether)

  address public LotteryOwner; 
  bool private lPotActive;  /* ToDo: Boolean Controler for Open & Close Lottery  */
  address public WeeklyPotAddress;   

  /* ToDo: Save Start and End of Tickets for each Address (ID) and Change Search routine */
  struct PotPlayerStr{
    uint PaymentCount;
    uint paymentValue;
    uint TicketNumbers;
    uint[] TicketsId;
    uint[] PlayersId;
  }

  mapping (address => PotPlayerStr) private PotPlayersMap;  
  address[] private potPlayersArray;  
  uint[] private potTickets;
  uint[3][] private potTicketIds;
   
  /* ToDo : Lottery Pot Generator Structure as a Wrapper for Lottery Core */
  // struct LotteryPot{
  //   string potLabel;
  //   uint entryCount;
  //   uint potSerial;
  //   uint potValue;
  //   // mapping(address => PotPlayer) players;
  // }

  address private _VRF;

  event SelectWinnerIndex(uint winnerIndex, uint potBalance, uint winnerPrize);
  event SelectWinnerAddress(address potWinner, uint winnerPrize);
  event PlayerRegister(address potPlayer, uint playerId, uint PlayerValue, uint ticketNumber);
  event PlayeTotalValue(address potPlayer, uint[] playerId, uint playCount, uint playerValue, uint ticketNumber);
  event TotalPayment(address receiver, uint TrxValue);

  constructor(address VRF) {   // , address lOwner
    LotteryOwner = msg.sender;
    _VRF = VRF;
  }

  // modifier onlyOwner() {
  //   require(msg.sender == LotteryOwner, "Owner Only! . You have not the right Access.");
  //   _;
  // }

  /* ToDo : Add & Complete Fallback routine */
  // fallback() external payable {
  //       // player name will be unknown
  // }

  /**
    * @notice Show the total Balance of this Pot. 
    * @dev Smart Contract total Balance.
    * @return Balance of This Contract.
  */
  function balanceInPot() public view returns(uint){
    return address(this).balance;
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

  /**
    * @notice Players' Operation and Calculation after Sending Transaction to the SmartContract. 
    * @dev Payable Function. 
  */
  function play() public payable {

    /* ToDo: Convert Ether to BNB */
    require(msg.value >= 0.01 ether && msg.value < 100 ether, "Value should be between 0.01 & 100 BNB");

    /* ToDo: Replace with SafeMath */
    (uint ticketNumber, uint remainder ) = getDivided(msg.value, TICKET_PRICE); // 10000000000000000
    require(remainder == 0, "Value should be an Integer mutiple of 0.01 BNB");

    potPlayersArray.push( msg.sender );
    uint id = potPlayersArray.length - 1; 

    uint ticketStart = potTickets.length;
    for (uint jj = 0; jj < ticketNumber; jj++) {
      potTickets.push( id );
    }
    uint ticketEnd = potTickets.length;
    potTicketIds.push([id, ticketStart, ticketEnd]);
    uint id2 = potTicketIds.length;

    PotPlayersMap[msg.sender].PaymentCount += 1;
    PotPlayersMap[msg.sender].paymentValue += msg.value;
    PotPlayersMap[msg.sender].TicketNumbers += ticketNumber;
    PotPlayersMap[msg.sender].PlayersId.push( id );
    PotPlayersMap[msg.sender].TicketsId.push( id2);

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
  //   VRFv2Consumer(_VRFv2).requestRandomWords(LotteryOwner) ;
  // }

  /**
    * @notice Generating Random Number for Finding the Hourly Winner.
    * @dev Call VRFv2 Random Generator Routines.
  */
  function getRandomValue(address _VRFv2) public view onlyOwner returns (uint256 randomWords) {
    // uint8 zeroOne = uint8(randomGenerator() % 2);
    randomWords = VRFv2Consumer(_VRFv2).getlRandomWords();
  }

  /**
    * @notice Select The Hourly Winner Function.
    * @dev Select The Pot Winner.
  */
  function select_Winner() public onlyOwner {  

    uint256 l_randomWords = getRandomValue(_VRF);
    uint winnerIndex = l_randomWords % potTickets.length;  
    winnerIndex = potTickets[winnerIndex];
    uint winnerPrize = Calculation(winnerIndex);
    emit SelectWinnerIndex(winnerIndex, address(this).balance, winnerPrize);
    WinnerPrizePayment(winnerIndex, winnerPrize); 
    FinalPayment();

    /* ToDo : Clear The Map Data and RElease the Memory */  
    address playerAddress;
    for (uint256 index = 0; index < potPlayersArray.length - 1; index++) {
        playerAddress = potPlayersArray[index];
        if (PotPlayersMap[playerAddress].PaymentCount > 0) {
            PotPlayersMap[playerAddress].PaymentCount = 0;
            PotPlayersMap[playerAddress].paymentValue = 0;
            PotPlayersMap[playerAddress].TicketNumbers = 0;
            delete PotPlayersMap[playerAddress].PlayersId;
            delete PotPlayersMap[playerAddress].TicketsId;
        }
    }
    // potPlayersArr = new PotPlayerStr[](0); 
    delete potPlayersArray;
    delete potTickets;
    
  }

  /**
    * @notice Calculation of Pot Winner Prize.
    * @dev Findout the 50% of the Total Pot and The Winner payment.
  */
  function Calculation(uint winnerIndex) internal view returns (uint winnerPrize){

    uint totalPot = address(this).balance;
    address WinnerAddress = potPlayersArray[winnerIndex];
    uint WinnerPotAmount = PotPlayersMap[WinnerAddress].paymentValue;
    winnerPrize = totalPot - WinnerPotAmount;
    /* ToDo : Replace Calculation Parts with OpenZeppelin SafeMath ) */
    (winnerPrize, ) = getDivided(winnerPrize, 2);
    winnerPrize += WinnerPotAmount; 

  }

  /**
    * @notice Pay Pot Prize to the Winner.
    * @dev Transfer Pot Prize to the Winner.
  */
  function WinnerPrizePayment(uint winnerIndex, uint winnerPrize) internal {

    address payable potWinner = payable(potPlayersArray[winnerIndex]);  
    potWinner.transfer(winnerPrize);
    emit SelectWinnerAddress(potWinner, winnerPrize);
    // potPlayers[winnerIndex].transfer(address(this).balance);

  }

  /**
    * @notice Remaining Pot Money Transfer.
    * @dev Transfer remaining Money to the Liquidity Pool.
  */
  function FinalPayment() internal onlyOwner {

    address payable receiver = payable(WeeklyPotAddress);
    uint TrxValue = address(this).balance;
    receiver.transfer(TrxValue);
    emit TotalPayment(receiver, TrxValue);

  }

  function set_WeeklyPotAddress(address _WeeklyPotAddress) external onlyOwner {
    require(_WeeklyPotAddress != address(0) );
    WeeklyPotAddress = _WeeklyPotAddress;
  }

  function listPlayers() external view returns (address[] memory){  
    return potPlayersArray;  
  }

  function withdraw() external onlyOwner {
    payable(msg.sender).transfer(address(this).balance);
  }

  function getLotteryTickets() public view returns(uint[] memory) {
    return potTickets;
  }

}


/**
************************************************************************************
************************************************************************************
**/
contract WeeklyLottery is Ownable {

  address private _VRF;

  event SelectWinnerIndex(uint winnerIndex, uint potBalance, uint winnerPrize);
  event SelectWinnerAddress(address potWinner, uint winnerPrize);
  event TotalPayment(address receiver, uint TrxValue);

  constructor(address VRF) {   // , address lOwner
    _VRF = VRF;
  }

  function balanceInPot() public view returns(uint){
    return address(this).balance;
  }

  function getRandomValue(address _VRFv2) public view onlyOwner returns (uint256 randomWords) {
    // uint8 zeroOne = uint8(randomGenerator() % 2);
    randomWords = VRFv2Consumer(_VRFv2).getlRandomWords();
  }

  function withdraw() external onlyOwner {
    payable(msg.sender).transfer(address(this).balance);
  }

  function select_Winner() public onlyOwner {  

    uint256 l_randomWords = getRandomValue(_VRF) ;
    uint winnerIndex = l_randomWords % LotteryGenerator.LotteryPlayersArray ;
    // winnerIndex = potTickets[winnerIndex] ;
    uint winnerPrize = Calculation(winnerIndex) ;

    emit SelectWinnerIndex(winnerIndex, address(this).balance, winnerPrize) ;

    WinnerPrizePayment(winnerIndex, winnerPrize) ; 

    FinalPayment() ;

    delete LotteryGenerator.LotteryPlayersArray ;
    /* ToDo : Clear The Map Data and RElease the Memory !? */

  }

  function Calculation(uint winnerIndex) internal view returns (uint winnerPrize){

    uint totalPot = address(this).balance ;
    /* ToDo : Complete Winner Prize Calculation */
    address WinnerAddress = LotteryGenerator.LotteryPlayersArray[winnerIndex] ;
    uint WinnerPotAmount = LotteryGenerator.LotteryPlayersMap[WinnerAddress].paymentValue ;
    winnerPrize = totalPot ;

  }

  function WinnerPrizePayment(uint winnerIndex, uint winnerPrize) internal {

    address payable LotteryWinner = payable(LotteryGenerator.LotteryPlayersArray[winnerIndex]) ;  
    LotteryWinner.transfer(winnerPrize) ;
    emit SelectWinnerAddress(LotteryWinner, winnerPrize) ;

  }

  function FinalPayment() internal onlyOwner {

    // address payable receiver = payable(WeeklyPotAddress) ;
    // uint TrxValue = address(this).balance ;

    /* ToDo: Complete Final Payment to Cover Transmission remaining into the Liquidity Pool and Profits of Stake Holders */
    // receiver.transfer(TrxValue) ;

    // emit TotalPayment(receiver, TrxValue) ;

  }


}

/**
************************************************************************************
************************************************************************************
**/
contract MonthlyLottery is Ownable {

  address private _VRF ;

  constructor(address VRF) {   // , address lOwner
    _VRF = VRF ;
  }

  function balanceInPot() public view returns(uint){
    return address(this).balance ;
  }

  function getRandomValue(address _VRFv2) public view onlyOwner returns (uint256 randomWords) {
    // uint8 zeroOne = uint8(randomGenerator() % 2) ;
    randomWords = VRFv2Consumer(_VRFv2).getlRandomWords() ;
  }

  function withdraw() external onlyOwner {
    payable(msg.sender).transfer(address(this).balance) ;
  }

  function select_Winner() public onlyOwner {  

    uint256 l_randomWords = getRandomValue(_VRF) ;
    uint winnerIndex = l_randomWords % LotteryGenerator.LotteryPlayersArray ;

    /* ToDo : Clear The Map Data and RElease the Memory !? */

  }

}


