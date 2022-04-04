// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './LotteryCore.sol' ;

contract LotteryGenerator {

    address[] public lotteries;
    struct lottery{
        uint index;
        address creator;
    }
    mapping(address => lottery) lotteryStructs;

    // event
    event LotteryCreated(address newLottery);

    function createLottery(address _VRF) public {

        // require(bytes(name).length > 0);
        address newLottery = address(new LotteryCore(_VRF));
        lotteries.push(newLottery) ;
        lotteryStructs[newLottery].index = lotteries.length - 1;
        lotteryStructs[newLottery].creator = msg.sender;

        emit LotteryCreated( newLottery ) ;

    }

    // function getLotteries() public view returns(address[]) {
    //     return lotteries;
    // }

    function deleteLottery(address lotteryAddress) public {
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

