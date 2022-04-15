// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./LotteryCore.sol";


/**
  * @title Lottery Generator Smart Contract.
  * @author Batis 
  * @notice This SmartContract is responsible for Lottery Generation.
  * @dev Lottery Generator SmartContract - Parent of Core Lottery
*/
contract LotteryGenerator is Ownable {

    address[] public lotteries;
    struct lottery{
        uint index;
        address creator;
        uint totalBalance;
        address winnerAddress; 
    }
    mapping(address => lottery) lotteryStructs;

    struct LotteryWinnerStr{
        uint PlayersId;
        uint winnerCont;
    }
    mapping (address => LotteryWinnerStr) public LotteryWinnersMap;
    address[] public LotteryWinnersArray;

    // event
    event LotteryCreated(address newLottery);

    function createLottery(address _VRF) public onlyOwner {

        // require(bytes(name).length > 0);
        address newLottery = address(new LotteryCore(_VRF));
        lotteries.push(newLottery);
        lotteryStructs[newLottery].index = lotteries.length - 1;
        lotteryStructs[newLottery].creator = msg.sender;
        lotteryStructs[newLottery].totalBalance = 0;
        lotteryStructs[newLottery].winnerAddress = address(0);

        emit LotteryCreated( newLottery );
    }

    // function getLotteries() public view returns(address[]) {
    //     return lotteries;
    // }

    function deleteLottery(address lotteryAddress) public  onlyOwner {
        require(msg.sender == lotteryStructs[lotteryAddress].creator);
        uint indexToDelete = lotteryStructs[lotteryAddress].index;
        address lastAddress = lotteries[lotteries.length - 1];
        lotteries[indexToDelete] = lastAddress;
        // lotteries.length --;
    }

    // Events
    // event LotteryCreated(
    //     address lotteryAddress
    // );
}

