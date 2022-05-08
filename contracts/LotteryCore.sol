// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// pragma experimental ABIEncoderV2;

/* ToDo : Use Ownable OpenZeppelin */
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// import "./LotteryGenerator.sol";
import "./VRFv2Consumer.sol";
import "./VRFv2SubscriptionManager.sol";

// import "truffle/Console.sol";
// import "hardhat/console.sol";

import "./LotteryInterface.sol";

// interface IlotteryGenerator {
//     function setlotteryStructs(address _lotteryAddress, uint _totalBalance, address _winnerAddress, uint8 _lotteryType) external returns (bool);
//     function setlotteryWinnersArrayMap(address _lotteryAddress, address _winnerAddress) external returns (uint);
// }


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

  address private _VRF;
  address private generatorLotteryAddr;
  address private LiquidityPoolAddress;
  // address private MultiSigWalletAddress;
  address private WeeklyPotAddress;
  address private MonthlyPotAddress;   
  address private LotteryOwner;

  uint constant TICKET_PRICE = 10 * 1e15; // finney (0.01 Ether)

  // address public LotteryOwner; 
  bool private lPotActive;  
  bool private lReadySelectWinner; 
  uint public potStartTime = 0;

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
  uint[3][] private potTicketIds;  /* ToDo: Change Search routine base on the Start and End of Tickets for each Address (ID)  */ 
  address private potWinnerAddress;
  address private potDirector;  /* ToDo: All Main Action must be controlled only by Owner or Director */
   
  /* ToDo : Lottery Pot Generator Structure as a Wrapper for Lottery Core */
  // struct LotteryPot{
  //   string potLabel;
  //   uint entryCount;
  //   uint potSerial;
  //   uint potValue;
  //   // mapping(address => PotPlayer) players;
  // }

  event SelectWinnerIndex(uint winnerIndex, uint potBalance, uint winnerPrize);
  event SelectWinnerAddress(address potWinner, uint winnerPrize);
  event PlayerRegister(address potPlayer, uint playerId, uint PlayerValue, uint ticketNumber);
  event PlayerTotalValue(address potPlayer, uint[] playerId, uint playCount, uint playerValue, uint ticketNumber);
  event TotalPayment(address receiver, uint TrxValue);

  constructor(address VRF) {   // , address lOwner
    LotteryOwner = msg.sender;
    _VRF = VRF;
    lPotActive = true;
    lReadySelectWinner = false;
    potStartTime = block.timestamp;
    // generatorLotteryAddr = 0x4490bEAF312ec3948016b8ef43528c5ACDF5FDB7 ;
    // LiquidityPoolAddress = 0x393660C3446Fb05ca9Cf4034568450d47d32a076 ;
    // WeeklyPotAddress = 0xe9F90ff51A50b69c84fF50CC5EE6D08Ce8CFc1bB ;
    // MonthlyPotAddress = 0x1D1F2A6ae3E31Ad016a3E969392fCe130A4E4608 ;   
    // MultiSigWalletAddress = ;
    // potDirector = 0x4de8d75eF9b48856e708347c4A0bf1BCA338DB53 ;
  }

  // modifier onlyOwner() {
  //   require(msg.sender == LotteryOwner, "Owner Only! . You have not the right Access.");
  //   _;
  // }

  /* ToDo : Add & Complete Fallback routine */
  fallback() external payable {
  }
  receive() external payable {
  }

  modifier isAllowedManager() {
      require( msg.sender == potDirector || msg.sender == LotteryOwner , "Permission Denied !!" );
      _;
  }

  modifier isGameOn() {
      require(lPotActive , "The Pot has not been Ready to Play yet Or The Game is Over!");  // && !lReadySelectWinner 
      _;
  }

  modifier isPotValuable() {
      require( (address(this).balance >= 0.1 ether && potPlayersArray.length >= 5) , "The Pot is not Filled Enough !");
      _;
  }

  /**
    * @notice Show the total Balance of this Pot. 
    * @dev Smart Contract total Balance.
    * @return Balance of This Contract.
  */
  function balanceInPot() public view returns(uint){
    return address(this).balance;
  }

  function withdraw() external onlyOwner {
    payable(msg.sender).transfer(address(this).balance);
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

  function potInitialize() external isAllowedManager {
    require(lPotActive == false, "The Pot is started before !");
    lPotActive = true ;
    lReadySelectWinner = false;
    potStartTime = block.timestamp;
  }

  /**
    * @notice Players' Operation and Calculation after Sending Transaction to the SmartContract. 
    * @dev Payable Function. 
  */
  function play() public payable isGameOn {

    /* ToDo: Convert Ether to BNB */
    require(msg.value >= 0.01 ether && msg.value < 100 ether, "Value should be between 0.01 & 100 BNB");

    uint userPotAmount = PotPlayersMap[msg.sender].paymentValue;
    require(userPotAmount <= 10 ether, "You played too much !!");

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

    if (address(this).balance >= 0.1 ether && potPlayersArray.length >= 5) {
      lReadySelectWinner = true;
    } 

    emit PlayerRegister(msg.sender, id, msg.value, ticketNumber) ;
    if (PotPlayersMap[msg.sender].PaymentCount > 1) {
        emit PlayerTotalValue(msg.sender, PotPlayersMap[msg.sender].PlayersId, PotPlayersMap[msg.sender].PaymentCount, PotPlayersMap[msg.sender].paymentValue, PotPlayersMap[msg.sender].TicketNumbers) ;
    }    

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

  /**
    * @notice Generating Random Number for Finding the Hourly Winner.
    * @dev Call VRFv2 Random Generator Routines.
  */
  function getRandomValue(address _VRFv2) public view onlyOwner returns (uint256 randomWords) {
    // uint8 zeroOne = uint8(randomGenerator() % 2);
    // randomWords = randomGenerator();
    randomWords = VRFv2Consumer(_VRFv2).getlRandomWords();
  }

  /**
    * @notice Select The Hourly Winner Function.
    * @dev Select The Pot Winner.
  */
  function select_Winner() public isAllowedManager {  

    require( lReadySelectWinner == true, "The Pot is not ready for Select the Winner" );

    // uint256 l_randomWords = randomGenerator();
    uint256 l_randomWords = getRandomValue(_VRF);
    uint winnerIndex = l_randomWords % potTickets.length;  
    winnerIndex = potTickets[winnerIndex];
    (uint winnerPrize, uint weeklyPot, uint monthlyPot, uint liquidityAmount) = Calculation(winnerIndex);
    
    emit SelectWinnerIndex(winnerIndex, address(this).balance, winnerPrize);

    UpdateLotteryData(winnerIndex, address(this).balance);
    WinnerPrizePayment(winnerIndex, winnerPrize); 
    FinalPayment(weeklyPot, monthlyPot, liquidityAmount);
    ClearDataBase();
    // console.log("Select Winner Done !");

    lPotActive = false;
    lReadySelectWinner = false;

  }

  /**
    * @notice Release Smart Contract Memory .
    * @dev Clear All Storages .
  */
  function ClearDataBase() private returns (bool) {
    /* ToDo : Clear The Map Data and RElease the Memory */  
    address playerAddress;
    for (uint256 index = 0; index < potPlayersArray.length - 1; index++) {
        playerAddress = potPlayersArray[index];
        // if (PotPlayersMap[playerAddress].PaymentCount > 0) {
        //     PotPlayersMap[playerAddress].PaymentCount = 0;
        //     PotPlayersMap[playerAddress].paymentValue = 0;
        //     PotPlayersMap[playerAddress].TicketNumbers = 0;
        //     delete PotPlayersMap[playerAddress].PlayersId;
        //     delete PotPlayersMap[playerAddress].TicketsId;
        // }
        delete PotPlayersMap[playerAddress];
    }
    delete potPlayersArray;
    delete potTickets;
    return true;
  }

  /**
    * @notice Calculation of Pot Winner Prize.
    * @dev Findout the 50% of the Total Pot and The Winner payment.
  */
  function Calculation(uint _winnerIndex) private view returns (uint winnerPrize, uint weeklyPot, uint monthlyPot, uint liquidityAmount){

    uint totalPot = address(this).balance;
    address WinnerAddress = potPlayersArray[_winnerIndex];
    uint WinnerPotAmount = PotPlayersMap[WinnerAddress].paymentValue;

    winnerPrize = totalPot - WinnerPotAmount;
    /* ToDo : Replace Calculation Parts with OpenZeppelin SafeMath ) */
    (winnerPrize, ) = getDivided(winnerPrize, 2);
    winnerPrize += WinnerPotAmount; 

    uint otherPots = totalPot - winnerPrize;
    (otherPots, ) = getDivided(otherPots, 20);
    weeklyPot = otherPots;
    monthlyPot = otherPots;
    liquidityAmount = totalPot - 2 * otherPots - winnerPrize;

  }

  /**
    * @notice Pay Pot Prize to the Winner.
    * @dev Transfer Pot Prize to the Winner.
  */
  function WinnerPrizePayment(uint _winnerIndex, uint _winnerPrize) private {

    address payable potWinner = payable(potPlayersArray[_winnerIndex]);  
    potWinner.transfer(_winnerPrize);
    emit SelectWinnerAddress(potWinner, _winnerPrize);
    // potPlayers[winnerIndex].transfer(address(this).balance);

  }

  /**
    * @notice Remaining Pot Money Transfer.
    * @dev Transfer remaining Money to the Liquidity Pool.
  */
  function FinalPayment(uint weeklyPot, uint monthlyPot, uint liquidityAmount) private {   // onlyOwner 

    // uint TrxValue = address(this).balance;
    // address payable receiver = payable(WeeklyPotAddress);
    // TrxValue = address(this).balance; 
    // receiver.transfer(TrxValue);
    // emit TotalPayment(receiver, TrxValue);

    address payable receiver = payable(WeeklyPotAddress);
    receiver.transfer(weeklyPot);
    emit TotalPayment(receiver, weeklyPot);

    receiver = payable(MonthlyPotAddress);
    receiver.transfer(monthlyPot);
    emit TotalPayment(receiver, monthlyPot);

    receiver = payable(LiquidityPoolAddress);
    receiver.transfer(liquidityAmount);
    emit TotalPayment(receiver, liquidityAmount);

  }

  /**
    * @notice Save The Winner Address for Weekly Lottery
    * @dev Update Generator Smart Contract For Saving Hourly Winner Address
  */
  function UpdateLotteryData(uint _winnerIndex, uint _balance) private returns(bool) {
    bool _success;
    uint _winnerId;
    // address _winnerAddress = potPlayersArray[_winnerIndex];
    potWinnerAddress = potPlayersArray[_winnerIndex];
    _success = LotteryInterface(generatorLotteryAddr).setlotteryStructs(address(this), _balance, potWinnerAddress, 0);  // _winnerAddress  
    _winnerId = LotteryInterface(generatorLotteryAddr).setlotteryWinnersArrayMap(address(this), potWinnerAddress);  // _winnerAddress
    return true;
  }

  function set_WeeklyPotAddress(address _WeeklyPotAddress) external onlyOwner {
    require(_WeeklyPotAddress != address(0) );
    WeeklyPotAddress = _WeeklyPotAddress;
  }

  function set_MonthlyPotAddress(address _MonthlyPotAddress) external onlyOwner {
    require(_MonthlyPotAddress != address(0) );
    MonthlyPotAddress = _MonthlyPotAddress;
  }

  function generatorLotteryAddress(address _contractAddr) external onlyOwner {
    generatorLotteryAddr = _contractAddr;
  }

  function set_LiquidityPoolAddress(address _LiquidityPoolAddress) external onlyOwner {
    require(_LiquidityPoolAddress != address(0) );
    LiquidityPoolAddress = _LiquidityPoolAddress;
  }

  // function set_MultiSigWalletAddress(address _MultiSigWalletAddress) external onlyOwner {
  //   require(_MultiSigWalletAddress != address(0) );
  //   MultiSigWalletAddress = _MultiSigWalletAddress;
  // }

  function setDirector(address _DirectorAddress) external onlyOwner {
    require(_DirectorAddress != address(0) );
    potDirector = _DirectorAddress;
  }

  function listPlayers() public view returns (address[] memory){  
    return potPlayersArray;  
  }

  function getLotteryTickets() public view returns(uint[] memory) {
    return potTickets;
  }

  function isPotActive() public view returns(bool) {
    return lPotActive;
  }

  function getTicketPrice() public pure returns(uint) {
    return TICKET_PRICE;
  }

  function getTicketAmount() public view returns(uint) {
    return potTickets.length;
  }

  function getPlayersNumber() public view returns(uint) {
    return potPlayersArray.length;
  }

  function getWinners() public view returns(address) {
    return potWinnerAddress;  
  }  

  function isReadySelectWinner() public view returns(bool) {
    return lReadySelectWinner;
  }

  function getStartedTime() public view returns(uint) {
    return block.timestamp - potStartTime;
  }

  function getPotDirector() public view returns(address) {
    return potDirector;
  }

}


/**
************************************************************************************
************************************************************************************
**/
