// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface LotteryInterface {
  // function LotteryWinnersArray() external view returns (address[] memory);
  // function WeeklyWinnersArray() external view returns (address[] memory);
  function getWinners() external view returns(address[] memory);
  function getWeeklyWinners() external view returns(address[] memory);
  function getMonthlyWinners() external view returns(address[] memory);
  function setlotteryStructs(address _lotteryAddress, address _commander, uint _totalBalance, address _winnerAddress, uint8 _lotteryType) external returns (bool);
  function setlotteryWinnersArrayMap(address _commander, address _winnerAddress) external returns (uint);
  function setWeeklyWinnersArrayMap(address _commander, address _winnerAddress) external returns (uint);
  function setMonthlyWinnersArrayMap(address _commander, address _winnerAddress) external returns (uint);
  function clearlotteryWinnersArrayMap(address _commander) external returns (bool);
  function clearWeeklyWinnersArrayMap(address _commander) external returns (bool);
  function clearMonthlyWinnersArrayMap(address _commander) external returns (bool);
}
