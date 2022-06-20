// SPDX-License-Identifier: GNU-GPLv3
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

// import "truffle/Console.sol";
// import "hardhat/console.sol";

import "./LotteryCore.sol";


/**
  * @title Lottery Generator Smart Contract.
  * @author Batis Abhari (https://github.com/baties - ContactMe: abhari_Batis@hotmail.com)
  * @notice This SmartContract will be responsible for Lottery Generation in next Versions.
  * @dev Lottery Generator SmartContract - Parent of All Lottery MOdules
*/
contract LotteryGenerator is Ownable {

    // uint constant TICKET_PRICE = 10 * 1e15; // finney (0.01 Ether)

    enum LType {
        Hourly,
        Daily,
        Weekly,
        Monthly
    }

    address[] public lotteries;
    struct lottery{
        uint index;
        address creator;
        uint totalBalance;
        address winnerAddress; 
        LType lotteryType;
    }
    mapping(address => lottery) lotteryStructs;

    address private LotteryOwner;
    address private potDirector;  

    address[] public LotteryWinnersArray;
    uint[] public LotteryWinnersArrayPrizes;
    struct LotteryWinnerStr{
        uint playersId;
        uint winnerCount;
    }
    mapping (address => LotteryWinnerStr) public LotteryWinnersMap;

    address[] public WeeklyWinnersArray;
    uint[] public WeeklyWinnersArrayPrizes;
    struct WeeklyWinnerStr{
        uint playersId;
        uint winnerCount;
    }
    mapping (address => WeeklyWinnerStr) public WeeklyWinnersMap;

    address[] public MonthlyWinnersArray;
    uint[] public MonthlyWinnersArrayPrizes;
    struct MonthlyWinnerStr{
        uint playersId;
        uint winnerCount;
    }
    mapping (address => MonthlyWinnerStr) public MonthlyWinnersMap;

    // event
    event LotteryCreated(address newLottery);

    constructor() {   
        LotteryOwner = msg.sender;
    }


  /* ToDo : Add & Complete Fallback routine */
    fallback() external payable {
    }
    receive() external payable {
    }

    modifier isAllowedManager() {
        require( msg.sender == potDirector || msg.sender == LotteryOwner , "(Manager) Permission Denied !!" );
        _;
    }

    modifier isAllowedOwner(address _caller) {
        require( _caller == potDirector || _caller == LotteryOwner , "(Owner) Permission Denied !!" );
        _;
    }

    function balanceInPot() public view returns(uint){
        return address(this).balance;
    }

    function withdraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    /**
        * @notice Get The Total List of Hourly Lottery Winners Wallet Addresses
        * @return Hourly Lottery Winners Array List
    */
    function getWinners() external view returns(address[] memory) {
        return LotteryWinnersArray;
    }

    /**
        * @notice Get the List of Weekly Winners Wallet Addresses
        * @return Weekly Lottery Winners Array List
    */
    function getWeeklyWinners() external view returns(address[] memory) {
        return WeeklyWinnersArray;
    }

    /**
        * @notice Get the List of Monthly Winners Wallet Addresses
        * @return Monthly Lottery Winners Array List
    */
    function getMonthlyWinners() external view returns(address[] memory) {
        return MonthlyWinnersArray;
    }

    /**
        * @notice Get The Address of Current Pot Director (Pot Manager)
        * @return The Current Pot Director 
    */
    function getPotDirector() public view returns(address) {
        return potDirector;
    }

    /**
        * @notice Set or Change The Address of Current Pot Director (Pot Manager)
        * @dev This function is Set a Pot Manager and Only should be called by the Owner
    */
    function setDirector(address _DirectorAddress) external onlyOwner {
        require(_DirectorAddress != address(0) );
        potDirector = _DirectorAddress;
    }

  /**
    * @notice Save All (Hourly, Daily, Weekly & Monthly) Lotteries' Important Data in One Place.
    * @dev A struct with Hourly, Daily, Weekly & Monthly Lotteries Data.
    * @param _lotteryAddress : Address of Lottery .
    * @param _commander : The Address of Owner or Lottery Manager Which are the Only Allowed addresses for Running This Function.  
    * @param _totalBalance : Total Balance in this Lottery .
    * @param _winnerAddress : The Lottery Winner Wallet Address. 
    * @param _lotteryType : Type of Lottery (Hourly - Daily - Weekly - Monthly)
    * @return True
  */
    function setlotteryStructs(address _lotteryAddress, address _commander, uint _totalBalance, address _winnerAddress, uint8 _lotteryType) external isAllowedOwner(_commander) returns (bool) {
        lotteryStructs[_lotteryAddress].totalBalance = _totalBalance;
        lotteryStructs[_lotteryAddress].winnerAddress = _winnerAddress;
        lotteryStructs[_lotteryAddress].lotteryType = LType(_lotteryType);
        return true;
    }

  /**
    * @notice Save All Hourly Lotteries' Important Data 
    * @dev Save Hourly Data into Hourly Lottery Array & Hourly Lottery Map.
    * @param _commander : The Address of Owner or Lottery Manager Which are the Only Allowed addresses for Running This Function.
    * @param _winnerAddress : The Hourly Lottery Winner Wallet Address. 
    * @param _winnerPrize : The Amount of Hourly Lottery Winner's Prize .
    * @return LotteryWinnerArray Lengh
  */
    function setlotteryWinnersArrayMap(address _commander, address _winnerAddress, uint _winnerPrize) external isAllowedOwner(_commander) returns (uint) {
        LotteryWinnersArray.push(_winnerAddress);
        LotteryWinnersArrayPrizes.push(_winnerPrize);
        LotteryWinnersMap[_winnerAddress].playersId = LotteryWinnersArray.length;  // -1
        LotteryWinnersMap[_winnerAddress].winnerCount++;
        return LotteryWinnersArray.length ;  // -1
    }

  /**
    * @notice Save All Weekly Lotteries' Important Data 
    * @dev Save Weekly Data into Weekly Lottery Array & Weekly Lottery Map.
    * @param _commander : The Address of Owner or Lottery Manager Which are the Only Allowed addresses for Running This Function.  
    * @param _winnerAddress : The Weekly Lottery Winner Wallet Address. 
    * @param _winnerPrize : The Amount of Weekly Lottery Winner's Prize .
    * @return WeeklyWinnerArray Lengh
  */
    function setWeeklyWinnersArrayMap(address _commander, address _winnerAddress, uint _winnerPrize) external isAllowedOwner(_commander) returns (uint) {
        WeeklyWinnersArray.push(_winnerAddress);
        WeeklyWinnersArrayPrizes.push(_winnerPrize);
        WeeklyWinnersMap[_winnerAddress].playersId = WeeklyWinnersArray.length;  // -1
        WeeklyWinnersMap[_winnerAddress].winnerCount++;
        return WeeklyWinnersArray.length ;  // -1
    }

  /**
    * @notice Save All Monthly Lotteries' Important Data 
    * @dev Save Monthly Data into Monthly Lottery Array & Monthly Lottery Map.
    * @param _commander : The Address of Owner or Lottery Manager Which are the Only Allowed addresses for Running This Function.  
    * @param _winnerAddress : The Monthly Lottery Winner Wallet Address. 
    * @param _winnerPrize : The Amount of Monthly Lottery Winner's Prize .
    * @return MonthlyWinnerArray Lengh
  */
    function setMonthlyWinnersArrayMap(address _commander, address _winnerAddress, uint _winnerPrize) external isAllowedOwner(_commander) returns (uint) {
        MonthlyWinnersArray.push(_winnerAddress);
        MonthlyWinnersArrayPrizes.push(_winnerPrize);
        MonthlyWinnersMap[_winnerAddress].playersId = MonthlyWinnersArray.length;  // -1
        MonthlyWinnersMap[_winnerAddress].winnerCount++;
        return MonthlyWinnersArray.length ;  // -1
    }

  /**
    * @notice Clear Lottery Winner Array & Map Data 
    * @dev Clear Lottery Winner Array & Map Data and Releasing the Memory.
    * @param _commander : The Address of Owner or Lottery Manager Which are the Only Allowed addresses for Running This Function.  
    * @return True
  */
    function clearlotteryWinnersArrayMap(address _commander) external isAllowedOwner(_commander) returns (bool) {
        address _lotteryWinAddress;
        for (uint256 index = 0; index <= LotteryWinnersArray.length - 1; index++) {
            _lotteryWinAddress = LotteryWinnersArray[index];
            // if (LotteryWinnersMap[_lotteryWinAddress].playersId > 0) {
            //     LotteryWinnersMap[_lotteryWinAddress].playersId = 0;
            //     LotteryWinnersMap[_lotteryWinAddress].winnerCount = 0;
            // }
            delete LotteryWinnersMap[_lotteryWinAddress];
        }
        delete LotteryWinnersArray;
        return true;
    }

  /**
    * @notice Clear Weekly Lottery Winner Array & Map Data 
    * @dev Clear Weekly Lottery Winner Array & Map Data and Releasing the Memory.
    * @param _commander : The Address of Owner or Lottery Manager Which are the Only Allowed addresses for Running This Function.  
    * @return True
  */
    function clearWeeklyWinnersArrayMap(address _commander) external isAllowedOwner(_commander) returns (bool) {
        address _lotteryWinAddress;
        for (uint256 index = 0; index <= WeeklyWinnersArray.length - 1; index++) {
            _lotteryWinAddress = WeeklyWinnersArray[index];
            // if (WeeklyWinnersMap[_lotteryWinAddress].playersId > 0) {
            //     WeeklyWinnersMap[_lotteryWinAddress].playersId = 0;
            //     WeeklyWinnersMap[_lotteryWinAddress].winnerCount = 0;
            // }
            delete WeeklyWinnersMap[_lotteryWinAddress];
        }
        delete WeeklyWinnersArray;
        return true;
    }

  /**
    * @notice Clear Monthly Lottery Winner Array & Map Data 
    * @dev Clear MOnthly Lottery Winner Array & Map Data and Releasing the Memory.
    * @param _commander : The Address of Owner or Lottery Manager Which are the Only Allowed addresses for Running This Function.  
    * @return True
  */
    function clearMonthlyWinnersArrayMap(address _commander) external isAllowedOwner(_commander) returns (bool) {
        address _lotteryWinAddress;
        for (uint256 index = 0; index <= MonthlyWinnersArray.length - 1; index++) {
            _lotteryWinAddress = MonthlyWinnersArray[index];
            // if (MonthlyWinnersMap[_lotteryWinAddress].playersId > 0) {
            //     MonthlyWinnersMap[_lotteryWinAddress].playersId = 0;
            //     MonthlyWinnersMap[_lotteryWinAddress].winnerCount = 0;
            // }
            delete MonthlyWinnersMap[_lotteryWinAddress];
        }
        delete MonthlyWinnersArray;
        return true;
    }


    /*
    function createLottery(address _VRF, address weeklyAddr, address monthlyAddr, address liquidityAddr) public onlyOwner {

        address generatorAddress = address(this);

        // require(bytes(name).length > 0);
        address newLottery = address(new LotteryCore(_VRF, generatorAddress, weeklyAddr, monthlyAddr, liquidityAddr));
        lotteries.push(newLottery);
        lotteryStructs[newLottery].index = lotteries.length - 1;
        lotteryStructs[newLottery].creator = msg.sender;
        lotteryStructs[newLottery].totalBalance = 0;
        lotteryStructs[newLottery].winnerAddress = address(0);

        emit LotteryCreated( newLottery );
    }

    function deleteLottery(address lotteryAddress) public  onlyOwner {
        require(msg.sender == lotteryStructs[lotteryAddress].creator);
        uint indexToDelete = lotteryStructs[lotteryAddress].index;
        address lastAddress = lotteries[lotteries.length - 1];
        lotteries[indexToDelete] = lastAddress;
        // lotteries.length --;
    }
    */

    // function getLotteries() public view returns(address[]) {
    //     return lotteries;
    // }

    // event LotteryCreated(
    //     address lotteryAddress
    // );
}



