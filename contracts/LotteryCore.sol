// SPDX-License-Identifier: GNU-GPLv3
pragma solidity ^0.8.0;
// pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";


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
  * @title Core SmartContract for BNB Game Lottery 
  * @author Batis Abhari (https://github.com/baties - ContactMe: abhari_Batis@hotmail.com)
  * @notice This SmartContract is responsible for implimentation of Lottery Core System and communication with the Players 
  * @dev  
*/
contract LotteryCore is Ownable, VRFConsumerBaseV2 {

  VRFCoordinatorV2Interface COORDINATOR;
  LinkTokenInterface LINKTOKEN;
  uint64 s_subscriptionId;
 
  // Rinkeby coordinator. For other networks,
  // see https://docs.chain.link/docs/vrf-contracts/#configurations
  // address vrfCoordinator = 0x6168499c0cFfCaCD319c818142124B7A15E857ab;  // Rinkeby
  // address vrfCoordinator = 0x6A2AAd07396B36Fe02a22b33cf443582f682c82f;  // BSC TestNet coordinator
  address vrfCoordinator = 0xc587d9053cd1118f25F645F9E08BB98c9712A4EE;  // BSC MainNet coordinator


  // Rinkeby LINK token contract. For other networks,
  // see https://docs.chain.link/docs/vrf-contracts/#configurations
  // address link = 0x01BE23585060835E02B77ef475b0Cc51aA1e0709;  // Rinkeby
  // address link = 0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06;  //  BSC TestNet LINK token
  address link = 0x404460C6A5EdE2D891e8297795264fDe62ADBB75;  // BSC MainNet LINK token

  // The gas lane to use, which specifies the maximum gas price to bump to.
  // For a list of available gas lanes on each network,
  // see https://docs.chain.link/docs/vrf-contracts/#configurations
  // bytes32 keyHash = 0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc;  // Rinkeby
  // bytes32 keyHash = 0xd4bb89654db74673a187bd804519e65e3f71a52bc55f11da7601a13dcf505314;  //  BSC TestNet keyhash
  bytes32 keyHash = 0x114f3da0a805b6a67d6e9cd2ec746f7028f1b7376365af575cfea3550dd1aa04;  //  BSC MAinNet keyhash

  uint32 callbackGasLimit = 100000;
  uint16 requestConfirmations = 3;
  uint32 numWords =  1;

  uint256[] public s_randomWords;
  uint256 public s_requestId;


  // address private _VRF;
  address private generatorLotteryAddr;
  address private LiquidityPoolAddress;
  address private MultiSigWalletAddress;
  address private WeeklyPotAddress;
  address private MonthlyPotAddress;   
  address private LotteryOwner;

  uint constant TICKET_PRICE = 10 * 1e15; // finney (0.01 Ether)

  bool private lPotActive;  
  bool private lReadySelectWinner; 
  uint public potStartTime = 0;
  uint private vrfCalledTime = 0;
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
  event StartSelectngWinner(uint vrfCalledTime);
  event LogDepositReceived(address sender, uint value);

  // constructor(address VRF, address generatorLotteryAddress, address WeeklyLotteryAddress, address MonthlyLotteryAddress, address LiquidityPoolAddr) {
  constructor(uint64 subscriptionId, address generatorLotteryAddress, address WeeklyLotteryAddress, address MonthlyLotteryAddress, address LiquidityPoolAddr, address MultiSigWalletAddr) VRFConsumerBaseV2(vrfCoordinator) {
    COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
    LINKTOKEN = LinkTokenInterface(link);
    s_subscriptionId = subscriptionId;
    LotteryOwner = msg.sender;
    lPotActive = false;
    lReadySelectWinner = false;
    lWinnerSelected = false;
    potStartTime = block.timestamp;
    generatorLotteryAddr = generatorLotteryAddress;
    LiquidityPoolAddress = LiquidityPoolAddr ;
    WeeklyPotAddress = WeeklyLotteryAddress ;
    MonthlyPotAddress = MonthlyLotteryAddress ;   
    MultiSigWalletAddress = MultiSigWalletAddr ;
    // _VRF = VRF;
  }

  /* ToDo : Add & Complete Fallback routine */
  fallback() external payable isGameOn {
  }

  receive() external payable isGameOn {
  }

  // modifier onlyOwner() {
  //   require(msg.sender == LotteryOwner, "Owner Only! . You have not the right Access.");
  //   _;
  // }

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

  function balanceInPot() public view returns(uint){
    return address(this).balance;
  }

  function withdraw() external onlyOwner {
    payable(msg.sender).transfer(address(this).balance);
  }

  function close() public onlyOwner { 
    address payable addr = payable(address(LotteryOwner));  // owner
    selfdestruct(addr); 
  }

  /**
    * @notice Request Random Words From VRF Coordinator
    * @dev For more Details refer to : https://docs.chain.link/docs/chainlink-vrf-best-practices/#getting-multiple-random-numbers
  */
  function requestRandomWords() internal isAllowedManager {    
    // Will revert if subscription is not set and funded.
    s_requestId = COORDINATOR.requestRandomWords(
      keyHash,
      s_subscriptionId,
      requestConfirmations,
      callbackGasLimit,
      numWords
    );
  }

  /**
    * @notice VRF Coordinator Call Back this Function after generating Random Number
    * @dev For more Details refer to : https://docs.chain.link/docs/chainlink-vrf-best-practices/#getting-multiple-random-numbers
  */
  function fulfillRandomWords(
    uint256, /* requestId */
    uint256[] memory randomWords
  ) internal override {
    s_randomWords = randomWords;
    // select_Winner_Continue();
    lWinnerSelected = true;
    emit ReadyForSelectWinner(lWinnerSelected);
  }

  /* ToDo : Replace This function with OpenZeppelin SafeMath */
  /**
    * @notice Function for deviding two Integer Numbers and return the results.
    * @dev Safe Function for Devision Operation.
    * @param numerator : The Integer Number which is being devided on another Integer Number.
    * @param denominator : The Integer Number which another Int NUmber is devided by this.  
    * @return quotient and remainder of the Devision, Both are Integer Numbers. 
  */
  function getDivided(uint numerator, uint denominator) private pure returns(uint quotient, uint remainder) {
    require( denominator >= 0, "Division is Not Possible , Bug in Numbers !");
    require( numerator > 0, "Division is Not Possible , Bug in Numbers !");
    quotient  = numerator / denominator; 
    remainder = numerator - denominator * quotient;
  }

  /**
    * @notice The Local Random Generator Function.
    * @dev The Local Random Generator Function for Local Development and Running the Tests.
    * @return None. 
  */
  function randomGenerator() private view returns (uint) {
    return uint(
      keccak256(
        abi.encodePacked(
          block.difficulty, block.timestamp, potTickets ))) ;
  }
  
  // function getlRandomWords() external view returns (uint256) {
  //    return s_randomWords[0];
  // }

  // function lrequestRandomWords(address _VRFv2) public isAllowedManager {
  //   VRFv2Consumer(_VRFv2).requestRandomWords() ;
  // }

  // function getRandomValue(address _VRFv2) public view onlyOwner returns (uint256 randomWords) {
  //   // uint8 zeroOne = uint8(randomGenerator() % 2);
  //   // randomWords = randomGenerator();
  //   randomWords = VRFv2Consumer(_VRFv2).getlRandomWords();
  // }

  // function rRandomValue() public onlyOwner {
  //   requestRandomWords();
  // }

  /**
    * @notice Hourly Lottery Pot Initialization.
    * @dev AtFirst The Hourly Lottery have been Initialized for Default but after each Pot it Must be Initialized for next Pot .
    * @return success Flag 
  */
  function potInitialize() external isAllowedManager returns(bool success) {
    require(lPotActive == false, "The Pot is started before !");
    lPotActive = true ;
    lReadySelectWinner = false;
    potStartTime = block.timestamp;
    lWinnerSelected = false;
    success = true;
  }

  /**
    * @notice Hourly Lottery Pot is Pausable, This is the Trigger.
    * @dev THis Function just Pauses the current Pot Play and Select Winner Routines and Use only for Emergency .
    * @return success Flag 
  */
  function potPause() external isAllowedManager returns(bool success) {
    lPotActive = false ;
    lReadySelectWinner = false;
    lWinnerSelected = false;
    success = true;
  }

  /**
    * @notice Players' Operation and Calculation after Sending Transaction to the SmartContract. 
    * @dev Payable Function. 
    * @dev This Function is resposible for Accepting new Gamers in Hourly Lottery 
    * @return success Flag
  */
  function play() public payable isGameOn returns(bool success) {
    require(msg.value >= 0.01 ether && msg.value < 10 ether, "Value should be between 0.01 & 10 BNB");

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

  /**
    * @notice Hourly Lottery Pot Winner Selection, This Winner is Selected among Hourly Member List.
    * @dev Hourly Lottery Pot Winner Selection Start Process, This Function Just Called Request Random Number Routine For Communicate with VRF Coordinator.
    * @return success Flag 
  */
  function select_Winner() public isAllowedManager returns(bool success) {  

    require(lReadySelectWinner == true, "The Pot is not ready for Selecting the Winner");
    require(lWinnerSelected == false, "The Winner has Not been Selected Yet !");

    // lPotActive = false;
    vrfCalledTime = block.timestamp;
    emit StartSelectngWinner(vrfCalledTime);
    
    requestRandomWords();  
    // lWinnerSelected = true;   // For local test with Remix

    success = true;

  }

  /**
    * @notice Hourly Lottery Pot Winner Selection Continue, This Function Selects The Winner With Random Number Generated.
    * @dev Hourly Lottery Pot Winner Selection Continue, This Function Only Call after fulfillRandomWords is Called. 
    * @dev This Function is responsible for Updating Lottery Data, Pay the Winner Prize & then clear and Release the Memory
    * @return success Flag 
  */
  function select_Winner_Continue() public isAllowedManager returns(bool success) {  
    
    require(lReadySelectWinner == true, "The Pot is not ready for Selecting the Winner");
    // if (planB_VRFDelay() == false) {
      require(lWinnerSelected == true, "The Winner has been Selected before !!");
    // }

    uint winnerIndex = s_randomWords[0] % potTickets.length;    // l_randomWords
    // uint randomWords = randomGenerator();     // For local test with Remix
    // uint winnerIndex = randomWords % potTickets.length;     // For local test with Remix   

    winnerIndex = potTickets[winnerIndex];
    (uint winnerPrize, uint weeklyPot, uint monthlyPot, uint liquidityAmount, uint multiSigWalletAmount) = Calculation(winnerIndex);
    
    emit SelectWinnerIndex(winnerIndex, address(this).balance, winnerPrize);

    UpdateLotteryData(winnerIndex, address(this).balance, winnerPrize);
    WinnerPrizePayment(winnerIndex, winnerPrize); 
    FinalPayment(weeklyPot, monthlyPot, liquidityAmount, multiSigWalletAmount);
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
    * @return True
  */
  function ClearDataBase() private returns (bool) {
    /* ToDo : Clear The Map Data and RElease the Memory */  
    address playerAddress;
    for (uint256 index = 0; index <= potPlayersArray.length - 1; index++) {
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
    * @dev Findout the 50% of the Total Pot and The Winner payment and Calculation of Weekly & Monthly Pot Prizes.
  */
  function Calculation(uint _winnerIndex) private view returns (uint winnerPrize, uint weeklyPot, uint monthlyPot, uint liquidityAmount, uint multiSigWalletAmount){

    uint totalPot = address(this).balance;
    address WinnerAddress = potPlayersArray[_winnerIndex];
    uint WinnerPotAmount = PotPlayersMap[WinnerAddress].paymentValue;
    uint calcAmount = 0;

    winnerPrize = totalPot - WinnerPotAmount;
    /* ToDo : Replace Calculation Parts with OpenZeppelin SafeMath ) */
    (winnerPrize, ) = getDivided(winnerPrize, 2);
    winnerPrize += WinnerPotAmount; 

    uint otherPots = totalPot - winnerPrize;
    (otherPots, ) = getDivided(otherPots, 20);
    weeklyPot = otherPots;
    monthlyPot = otherPots;
    calcAmount = totalPot - 2 * otherPots - winnerPrize;
    (liquidityAmount, ) = getDivided(calcAmount, 5);
    multiSigWalletAmount = calcAmount - liquidityAmount;

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
    * @dev Transfer remaining Money to the Weekly Pot, Monthly Pot & Liquidity Pool & MultiSigWallet.
  */
  function FinalPayment(uint weeklyPot, uint monthlyPot, uint liquidityAmount, uint multiSigWalletAmount) private {   // onlyOwner 

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

    receiver = payable(MultiSigWalletAddress);
    receiver.transfer(multiSigWalletAmount);
    emit TotalPayment(receiver, multiSigWalletAmount);

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

  /**
    * @notice This Function is Only a PLan B for When The VRF Coordinator does not respond in a short time .
    * @dev Only If after 5 min the VRF Coordinator does not respond This function Change the lWinnerSelected to True so the Last Random Word used instead of a new one .
    * @return isActive Flag 
  */
  function planB_VRFDelay() public isAllowedManager returns(bool isActive){ 
    require(lReadySelectWinner == true, "The Pot is not ready for Selecting the Winner");
    require(lWinnerSelected == false, "The Winner has been Selected before !!");
    uint nowTime = block.timestamp;
    uint waitTime = 0;
    if (nowTime > vrfCalledTime) {
      waitTime = nowTime - vrfCalledTime ;
      if (waitTime > 5 minutes) {
          lWinnerSelected = true;
          isActive = true;
      } else {
        isActive = false;
      }
    } else {
      isActive = false;
    }
  }

  function set_WeeklyPotAddress(address _WeeklyPotAddress) external onlyOwner {
    require(_WeeklyPotAddress != address(0), "Given Address is Empty!");
    WeeklyPotAddress = _WeeklyPotAddress;
  }

  function set_MonthlyPotAddress(address _MonthlyPotAddress) external onlyOwner {
    require(_MonthlyPotAddress != address(0), "Given Address is Empty!");
    MonthlyPotAddress = _MonthlyPotAddress;
  }

  function set_generatorLotteryAddress(address _contractAddr) external onlyOwner {
    require(_contractAddr != address(0), "Given Address is Empty!");
    generatorLotteryAddr = _contractAddr;
  }

  function set_LiquidityPoolAddress(address _LiquidityPoolAddress) external onlyOwner {
    require(_LiquidityPoolAddress != address(0), "Given Address is Empty!");
    LiquidityPoolAddress = _LiquidityPoolAddress;
  }

  function set_MultiSigWalletAddress(address _MultiSigWalletAddress) external onlyOwner {
    require(_MultiSigWalletAddress != address(0), "Given Address is Empty!");
    MultiSigWalletAddress = _MultiSigWalletAddress;
  }

  function setDirector(address _DirectorAddress) external onlyOwner {
    require(_DirectorAddress != address(0), "Given Address is Empty!");
    require(address(_DirectorAddress).balance != 0, "Given Address Balance is Zero!");
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
  function getAllContractAddresses() public view returns(address gAddress, address lAddress, address wAddress, address mAddress, address sAddress) {
    gAddress = generatorLotteryAddr ;
    lAddress = LiquidityPoolAddress ;
    wAddress = WeeklyPotAddress ;
    mAddress = MonthlyPotAddress ;
    sAddress = MultiSigWalletAddress ;
    return (gAddress, lAddress, wAddress, mAddress, sAddress); 
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
