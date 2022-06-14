// SPDX-License-Identifier: GNU-GPLv3
pragma solidity ^0.8.0;
// pragma experimental ABIEncoderV2;

/* ToDo : Use Ownable OpenZeppelin */
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";


// import "./LotteryGenerator.sol";

// import "./VRFv2SubscriptionManager.sol";
// import "./VRFv2Consumer.sol";

// import "truffle/Console.sol";
// import "hardhat/console.sol";

import "./LotteryInterface.sol";

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
contract LotteryCore is Ownable, VRFConsumerBaseV2 {

  VRFCoordinatorV2Interface COORDINATOR;
  LinkTokenInterface LINKTOKEN;
  uint64 s_subscriptionId;

  // Rinkeby coordinator. For other networks,
  // see https://docs.chain.link/docs/vrf-contracts/#configurations
  address vrfCoordinator = 0x6168499c0cFfCaCD319c818142124B7A15E857ab;  // Rinkeby
  // address vrfCoordinator = 0x6A2AAd07396B36Fe02a22b33cf443582f682c82f;  // BSC TestNet coordinator

  // Rinkeby LINK token contract. For other networks,
  // see https://docs.chain.link/docs/vrf-contracts/#configurations
  address link = 0x01BE23585060835E02B77ef475b0Cc51aA1e0709;  // Rinkeby
  // address link = 0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06;  //  BSC TestNet LINK token

  // The gas lane to use, which specifies the maximum gas price to bump to.
  // For a list of available gas lanes on each network,
  // see https://docs.chain.link/docs/vrf-contracts/#configurations
  bytes32 keyHash = 0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc;  // Rinkeby
  // bytes32 keyHash = 0xd4bb89654db74673a187bd804519e65e3f71a52bc55f11da7601a13dcf505314;  //  BSC TestNet keyhash
  

  uint32 callbackGasLimit = 100000;
  uint16 requestConfirmations = 3;
  uint32 numWords =  1;

  uint256[] public s_randomWords;
  uint256 public s_requestId;


  // address private _VRF;
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
  uint public realPLayerCount = 0;
  uint public potWinnerPrize = 0;
  bool private lWinnerSelected;

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
  event ReadyForSelectWinner(bool isReadySelectWinner);

  // constructor(address VRF, address generatorLotteryAddress, address WeeklyLotteryAddress, address MonthlyLotteryAddress, address LiquidityPoolAddr) {
  //   LotteryOwner = msg.sender;
  //   _VRF = VRF;
  //   lPotActive = true;
  //   lReadySelectWinner = false;
  //   potStartTime = block.timestamp;
  //   generatorLotteryAddr = generatorLotteryAddress;
  //   LiquidityPoolAddress = LiquidityPoolAddr ;
  //   WeeklyPotAddress = WeeklyLotteryAddress ;
  //   MonthlyPotAddress = MonthlyLotteryAddress ;   
  // }

  constructor(uint64 subscriptionId, address generatorLotteryAddress, address WeeklyLotteryAddress, address MonthlyLotteryAddress, address LiquidityPoolAddr) VRFConsumerBaseV2(vrfCoordinator) {
    COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
    LINKTOKEN = LinkTokenInterface(link);
    s_subscriptionId = subscriptionId;
    LotteryOwner = msg.sender;
    lPotActive = true;
    lReadySelectWinner = false;
    lWinnerSelected = false;
    potStartTime = block.timestamp;
    generatorLotteryAddr = generatorLotteryAddress;
    LiquidityPoolAddress = LiquidityPoolAddr ;
    WeeklyPotAddress = WeeklyLotteryAddress ;
    MonthlyPotAddress = MonthlyLotteryAddress ;   
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

  function requestRandomWords() public isAllowedManager {    // external   onlyOwner
    // Will revert if subscription is not set and funded.
    s_requestId = COORDINATOR.requestRandomWords(
      keyHash,
      s_subscriptionId,
      requestConfirmations,
      callbackGasLimit,
      numWords
    );
  }

  function fulfillRandomWords(
    uint256, /* requestId */
    uint256[] memory randomWords
  ) internal override {
    s_randomWords = randomWords;
    // select_Winner_Continue();
    lWinnerSelected = true;
    emit ReadyForSelectWinner(lWinnerSelected);
  }

  // function getlRandomWords() external view returns (uint256) {
  //    return s_randomWords[0];
  // }

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

  function potInitialize() external isAllowedManager returns(bool success) {
    require(lPotActive == false, "The Pot is started before !");
    lPotActive = true ;
    lReadySelectWinner = false;
    potStartTime = block.timestamp;
    lWinnerSelected = false;
    success = true;
  }

  /**
    * @notice Players' Operation and Calculation after Sending Transaction to the SmartContract. 
    * @dev Payable Function. 
  */
  function play() public payable isGameOn returns(bool success) {

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
    if (PotPlayersMap[msg.sender].PaymentCount == 1) {
      realPLayerCount++;
    }

    if (address(this).balance >= 0.1 ether && realPLayerCount >= 5) {  // // potPlayersArray.length
      lReadySelectWinner = true;
    } 

    emit PlayerRegister(msg.sender, id, msg.value, ticketNumber) ;
    if (PotPlayersMap[msg.sender].PaymentCount > 1) {
        emit PlayerTotalValue(msg.sender, PotPlayersMap[msg.sender].PlayersId, PotPlayersMap[msg.sender].PaymentCount, PotPlayersMap[msg.sender].paymentValue, PotPlayersMap[msg.sender].TicketNumbers) ;
    }    

    return success;

  }

  function randomGenerator() private view returns (uint) {
    return uint(
      keccak256(
        abi.encodePacked(
          block.difficulty, block.timestamp, potTickets ))) ;
  }
  
  // function lrequestRandomWords(address _VRFv2) public isAllowedManager {
  //   VRFv2Consumer(_VRFv2).requestRandomWords() ;
  // }

  /**
    * @notice Generating Random Number for Finding the Hourly Winner.
    * @dev Call VRFv2 Random Generator Routines.
  */
  // function getRandomValue(address _VRFv2) public view onlyOwner returns (uint256 randomWords) {
  //   // uint8 zeroOne = uint8(randomGenerator() % 2);
  //   // randomWords = randomGenerator();
  //   randomWords = VRFv2Consumer(_VRFv2).getlRandomWords();
  // }

  // function rRandomValue() public onlyOwner {
  //   requestRandomWords();
  // }

  /**
    * @notice Select The Hourly Winner Function.
    * @dev Select The Pot Winner.
  */
  function select_Winner() public isAllowedManager returns(bool success) {  

    require( lReadySelectWinner == true, "The Pot is not ready for Select the Winner" );
    require(lWinnerSelected == false, "The Winner has been Selected before !!");

    requestRandomWords();
    success = true;

  }

  function select_Winner_Continue() public isAllowedManager returns(bool success) {  
    
    require(lWinnerSelected == true, "The Winner has Not been Selected Yet !");

    uint winnerIndex = s_randomWords[0] % potTickets.length;    // l_randomWords
    winnerIndex = potTickets[winnerIndex];
    (uint winnerPrize, uint weeklyPot, uint monthlyPot, uint liquidityAmount) = Calculation(winnerIndex);
    
    emit SelectWinnerIndex(winnerIndex, address(this).balance, winnerPrize);

    UpdateLotteryData(winnerIndex, address(this).balance, winnerPrize);
    WinnerPrizePayment(winnerIndex, winnerPrize); 
    FinalPayment(weeklyPot, monthlyPot, liquidityAmount);
    ClearDataBase();
    // console.log("Select Winner Done !");

    lPotActive = false;
    lReadySelectWinner = false;
    lWinnerSelected = false;
    success = true;

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
    realPLayerCount = 0;
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
  function UpdateLotteryData(uint _winnerIndex, uint _balance, uint _winnerPrize) private returns(bool) {
    bool _success;
    uint _winnerId;
    // address _winnerAddress = potPlayersArray[_winnerIndex];
    potWinnerAddress = potPlayersArray[_winnerIndex];
    potWinnerPrize = _winnerPrize;
    _success = LotteryInterface(generatorLotteryAddr).setlotteryStructs(address(this), msg.sender, _balance, potWinnerAddress, 0);  
    _winnerId = LotteryInterface(generatorLotteryAddr).setlotteryWinnersArrayMap(msg.sender, potWinnerAddress, _winnerPrize);  
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

  function set_generatorLotteryAddress(address _contractAddr) external onlyOwner {
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

  function getWinners() public view returns(address, uint) {
    return ( potWinnerAddress, potWinnerPrize ) ;  
  }  

  function isReadySelectWinner() public view returns(bool) {
    return lReadySelectWinner;
  }

  function isWinnerSelected() public view returns(bool) {
    return lWinnerSelected;
  }

  function getStartedTime() public view returns(uint) {
    return block.timestamp - potStartTime;
  }

  function getPotDirector() public view returns(address) {
    return potDirector;
  }

  // function getVerifier() public view returns(address) {
  //   return _VRF;
  // }

  // function getAllContractAddresses() public view returns(address[] memory) {
  //   address[] memory contractAddresses;
  //   contractAddresses[0] = generatorLotteryAddr;
  //   contractAddresses[1] = LiquidityPoolAddress;
  //   contractAddresses[2] = WeeklyPotAddress;
  //   contractAddresses[3] = MonthlyPotAddress;
  //   return contractAddresses;
  // }
  function getAllContractAddresses() public view returns(address gAddress, address lAddress, address wAddress, address mAddress) {
    gAddress = generatorLotteryAddr ;
    lAddress = LiquidityPoolAddress ;
    wAddress = WeeklyPotAddress ;
    mAddress = MonthlyPotAddress ;
    return (gAddress, lAddress, wAddress, mAddress); 
  }

  function getPlayerAmounts(address PlayerAddress) public view returns(uint, uint) {
    uint PaymentCount = PotPlayersMap[PlayerAddress].PaymentCount;
    uint PaymentValue = PotPlayersMap[PlayerAddress].paymentValue;
    return (PaymentCount, PaymentValue);
  }

  function getPlayerValue(address PlayerAddress) public view returns(uint) {
    uint PaymentValue = PotPlayersMap[PlayerAddress].paymentValue;
    return PaymentValue;
  }

}


/**
************************************************************************************
************************************************************************************
**/
