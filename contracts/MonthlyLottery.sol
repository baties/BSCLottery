// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// pragma experimental ABIEncoderV2;

/* ToDo : Use Ownable OpenZeppelin */
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// import "./LotteryGenerator.sol";
import "./VRFv2Consumer.sol";
import "./VRFv2SubscriptionManager.sol";

import "./LotteryCore.sol";

// import "truffle/Console.sol";
// import "hardhat/console.sol";

import "./LotteryInterface.sol";

// interface IiilotteryGenerator {
//     function WeeklyWinnersArray() external view returns (address[] memory);
//     function setlotteryStructs(address _lotteryAddress, uint _totalBalance, address _winnerAddress, uint8 _lotteryType) external returns (bool);
//     function clearWeeklyWinnersArrayMap(address _lotteryAddress) external returns (bool);
// }


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

  address[] private _WeeklyWinnersArray;

  event SelectWinnerIndex(uint winnerIndex, uint potBalance, uint winnerPrize);
  event SelectWinnerAddress(address potWinner, uint winnerPrize);
  event TotalPayment(address receiver, uint TrxValue);

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

  function select_Winner() public onlyOwner {  

    _WeeklyWinnersArray = getWeeklyWinnersArray();  
    uint256 l_randomWords = getRandomValue(_VRF);
    uint winnerIndex = l_randomWords % _WeeklyWinnersArray.length;
    uint winnerPrize = address(this).balance; // Calculation();
    
    emit SelectWinnerIndex(winnerIndex, address(this).balance, winnerPrize);
    
    UpdateLotteryData(winnerIndex, address(this).balance);
    WinnerPrizePayment(winnerIndex, winnerPrize); 
    // FinalPayment();
    ClearDataBase();

  }

  /**
    * @notice Release Smart Contract Memory .
    * @dev Clear All Storages .
  */
  function ClearDataBase() internal returns (bool) {
    bool _success;
    _success = LotteryInterface(generatorLotteryAddr).clearWeeklyWinnersArrayMap(address(this));
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
  //   /* ToDo : Replace Calculation Parts with OpenZeppelin SafeMath ) */
  //   (winnerPrize, ) = getDivided(totalPot, 20);  // winnerPrize

  // }

  /**
    * @notice Pay Pot Prize to the Winner.
    * @dev Transfer Pot Prize to the Winner.
  */
  function WinnerPrizePayment(uint _winnerIndex, uint _winnerPrize) internal {

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
  function UpdateLotteryData(uint _winnerIndex, uint _balance) internal returns(bool) {
    bool _success;
    // uint _winnerId;
    // _LotteryWinnersArray = getLotteryWinnersArray();  
    address _winnerAddress = _WeeklyWinnersArray[_winnerIndex];
    _success = LotteryInterface(generatorLotteryAddr).setlotteryStructs(address(this), _balance, _winnerAddress, 3);
    // _winnerId = IiilotteryGenerator(generatorLotteryAddr).setWeeklyWinnersArrayMap(address(this), _winnerAddress);
    return true;
  }

  function getWeeklyWinnersArray() internal view returns(address[] memory) {
    return LotteryInterface(generatorLotteryAddr).WeeklyWinnersArray();
  }

  function generatorLotteryAddress(address _contractAddr) external onlyOwner {
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

  function listPlayers() external view returns (address[] memory){  
    return _WeeklyWinnersArray;  
  }

}

/**
************************************************************************************
************************************************************************************
*/


