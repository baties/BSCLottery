// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// pragma experimental ABIEncoderV2;

/* ToDo : Use Ownable OpenZeppelin */
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// import "./LotteryGenerator.sol";

// import "./VRFv2SubscriptionManager.sol";
import "./VRFv2Consumer.sol";

import "./LotteryCore.sol";

// import "truffle/Console.sol";
// import "hardhat/console.sol";

import "./LotteryInterface.sol";


/**
************************************************************************************
************************************************************************************
*/

/**
************************************************************************************
************************************************************************************
**/
contract MonthlyLottery is Ownable {

  address private _VRF;
  address private generatorLotteryAddr;
  // address private LiquidityPoolAddress;
  // address private MultiSigWalletAddress;
  address private LotteryOwner;

  address[] private _WeeklyWinnersArray;
  bool private lPotActive;  
  bool private lReadySelectWinner; 
  address private potDirector;  /* ToDo: All Main Action must be controlled only by Owner or Director */
  address private potWinnerAddress;

  event SelectWinnerIndex(uint winnerIndex, uint potBalance, uint winnerPrize);
  event SelectWinnerAddress(address potWinner, uint winnerPrize);
  event TotalPayment(address receiver, uint TrxValue);

  constructor(address VRF, address generatorLotteryAddress) {  
    LotteryOwner = msg.sender;
    _VRF = VRF;
    lPotActive = false;
    lReadySelectWinner = false;
    generatorLotteryAddr = generatorLotteryAddress;
  }

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

  function balanceInPot() public view returns(uint){
    return address(this).balance;
  }

  function withdraw() external onlyOwner {
    payable(msg.sender).transfer(address(this).balance);
  }

  function randomGenerator() private view returns (uint) {
    return uint(
      keccak256(
        abi.encodePacked(
          block.difficulty, block.timestamp, _WeeklyWinnersArray ))) ;
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

  function potInitialize() external isAllowedManager returns(bool success) {
    require(lPotActive == false, "The Monthly Pot is started before !");
    _WeeklyWinnersArray = getWeeklyWinnersArray();  
    lPotActive = true ;
    lReadySelectWinner = true;
    success = true;
  }

  function getRandomValue(address _VRFv2) public view onlyOwner returns (uint256 randomWords) {
    // uint8 zeroOne = uint8(randomGenerator() % 2);
    // randomWords = randomGenerator();
    randomWords = VRFv2Consumer(_VRFv2).getlRandomWords();
  }

  function select_Winner() public isAllowedManager returns(bool success) {  

    require( lReadySelectWinner == true, "The Pot is not ready for Select the Winner" );

    // _WeeklyWinnersArray = getWeeklyWinnersArray();  
    uint256 l_randomWords = getRandomValue(_VRF);
    uint winnerIndex = l_randomWords % _WeeklyWinnersArray.length;
    uint winnerPrize = address(this).balance; // Calculation();
    
    emit SelectWinnerIndex(winnerIndex, address(this).balance, winnerPrize);
    
    UpdateLotteryData(winnerIndex, address(this).balance, winnerPrize);
    WinnerPrizePayment(winnerIndex, winnerPrize); 
    // FinalPayment();
    ClearDataBase();

    lPotActive = false;
    lReadySelectWinner = false;
    success = true;

  }

  /**
    * @notice Release Smart Contract Memory .
    * @dev Clear All Storages .
  */
  function ClearDataBase() private returns (bool) {
    bool _success;
    _success = LotteryInterface(generatorLotteryAddr).clearWeeklyWinnersArrayMap(msg.sender);
    return true;
  }

  /**
    * @notice Calculation of Pot Winner Prize.
    * @dev Findout the 5% of the Total Pot and The Winner payment.
  */
  // function Calculation() internal view returns (uint winnerPrize){

  //   uint totalPot = address(this).balance;
  //   // _LotteryWinnersArray = getLotteryWinnersArray();  
  //   // address WinnerAddress = _LotteryWinnersArray[_winnerIndex];
  //   (winnerPrize, ) = getDivided(totalPot, 20);  // winnerPrize

  // }

  /**
    * @notice Pay Pot Prize to the Winner.
    * @dev Transfer Pot Prize to the Winner.
  */
  function WinnerPrizePayment(uint _winnerIndex, uint _winnerPrize) private {

    // _LotteryWinnersArray = getLotteryWinnersArray();  
    address payable potWinner = payable(_WeeklyWinnersArray[_winnerIndex]);  
    potWinner.transfer(_winnerPrize);
    emit SelectWinnerAddress(potWinner, _winnerPrize);
    // _LotteryWinnersArray[winnerIndex].transfer(address(this).balance);

  }

  /**
    * @notice Remaining Pot Money Transfer.
    * @dev Transfer remaining Money to the Liquidity Pool.
  */
  // function FinalPayment() internal {   // onlyOwner 

  //   address payable receiver = payable(LiquidityPoolAddress);
  //   uint TrxValue = address(this).balance;
  //   receiver.transfer(TrxValue);
  //   emit TotalPayment(receiver, TrxValue);

  // }

  /**
    * @notice Save The Winner Address for Weekly Lottery
    * @dev Update Generator Smart Contract For Saving Hourly Winner Address
  */
  function UpdateLotteryData(uint _winnerIndex, uint _balance, uint winnerPrize) private returns(bool) {
    bool _success;
    uint _winnerId;
    // _LotteryWinnersArray = getLotteryWinnersArray();  
    // address _winnerAddress = _WeeklyWinnersArray[_winnerIndex];
    potWinnerAddress = _WeeklyWinnersArray[_winnerIndex];
    _success = LotteryInterface(generatorLotteryAddr).setlotteryStructs(address(this), msg.sender, _balance, potWinnerAddress , 3);  
    _winnerId = LotteryInterface(generatorLotteryAddr).setMonthlyWinnersArrayMap(msg.sender, potWinnerAddress, winnerPrize );  
    return true;
  }

  function getWeeklyWinnersArray() public view returns(address[] memory) {
    return LotteryInterface(generatorLotteryAddr).getWeeklyWinners();
  }

  function set_generatorLotteryAddress(address _contractAddr) external onlyOwner {
    generatorLotteryAddr = _contractAddr;
  }

  // function set_LiquidityPoolAddress(address _LiquidityPoolAddress) external onlyOwner {
  //   require(_LiquidityPoolAddress != address(0) );
  //   LiquidityPoolAddress = _LiquidityPoolAddress;
  // }

  // function set_MultiSigWalletAddress(address _MultiSigWalletAddress) external onlyOwner {
  //   require(_MultiSigWalletAddress != address(0) );
  //   MultiSigWalletAddress = _MultiSigWalletAddress;
  // }

  function setDirector(address _DirectorAddress) external onlyOwner {
    require(_DirectorAddress != address(0) );
    potDirector = _DirectorAddress;
  }

  function listPlayers() external view returns (address[] memory){  
    return _WeeklyWinnersArray;  
  }

  function isPotActive() public view returns(bool) {
    return lPotActive;
  }

  function getPlayersNumber() public view returns(uint) {
    return _WeeklyWinnersArray.length;
  }

  function getWinners() public view returns(address, uint) {
    return ( potWinnerAddress, address(this).balance );  
  }  

  function isReadySelectWinner() public view returns(bool) {
    return lReadySelectWinner;
  }

  function getPotDirector() public view returns(address) {
    return potDirector;
  }

  function getVerifier() public view returns(address) {
    return _VRF;
  }

}

/**
************************************************************************************
************************************************************************************
*/


