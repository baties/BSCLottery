// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface LotteryInterface {
  function LotteryWinnersArray() external view returns (address[] memory);
  function WeeklyWinnersArray() external view returns (address[] memory);
  function setlotteryStructs(address _lotteryAddress, uint _totalBalance, address _winnerAddress, uint8 _lotteryType) external returns (bool);
  function setlotteryWinnersArrayMap(address _lotteryAddress, address _winnerAddress) external returns (uint);
  function setWeeklyWinnersArrayMap(address _lotteryAddress, address _winnerAddress) external returns (uint);
  function clearlotteryWinnersArrayMap(address _lotteryAddress) external returns (bool);
  function clearWeeklyWinnersArrayMap(address _lotteryAddress) external returns (bool);
}
