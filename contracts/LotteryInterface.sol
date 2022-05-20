// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface LotteryInterface {
  // function LotteryWinnersArray() external view returns (address[] memory);
  // function WeeklyWinnersArray() external view returns (address[] memory);
  function getWinners() external view returns(address[] memory);
  function getWeeklyWinners() external view returns(address[] memory);
  function getMonthlyWinners() external view returns(address[] memory);
  function setlotteryStructs(address _lotteryAddress, uint _totalBalance, address _winnerAddress, uint8 _lotteryType) external returns (bool);
  function setlotteryWinnersArrayMap(address _winnerAddress) external returns (uint);
  function setWeeklyWinnersArrayMap(address _winnerAddress) external returns (uint);
  function setMonthlyWinnersArrayMap(address _winnerAddress) external returns (uint);
  function clearlotteryWinnersArrayMap() external returns (bool);
  function clearWeeklyWinnersArrayMap() external returns (bool);
  function clearMonthlyWinnersArrayMap() external returns (bool);
}
