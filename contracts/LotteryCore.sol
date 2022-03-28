// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
// import "truffle/Console.sol";


contract LotteryCore is VRFConsumerBaseV2 {

  VRFCoordinatorV2Interface COORDINATOR;
  LinkTokenInterface LINKTOKEN;

  address vrfCoordinator = 0x6168499c0cFfCaCD319c818142124B7A15E857ab;   // Rinkeby
  address link = 0x01BE23585060835E02B77ef475b0Cc51aA1e0709;   // Rinkeby
  bytes32 keyHash = 0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc;   // Rinkeby

  uint32 callbackGasLimit = 100000;
  uint16 requestConfirmations = 3;
  uint32 numWords =  1;

  address public lottoryOwner;
  address[] public potPlayers;

  uint64 lSubscriptionId;
  // bytes32 public reqId;
  // uint256 public randomNumber;
  uint256[] public lRandomWords;
  uint256 public lRequestId;

  struct PotPlayer{
    uint index;
    uint pValue;
  }

  struct LotteryPot{
    string potLabel;
    uint entryCount;
    uint potSerial;
    uint potValue;
    // mapping(address => PotPlayer) players;
  }

  // constructor(address _vrfCoordinator, address _link) VRFConsumerBase(_vrfCoordinator, _link) public {  }
  constructor(uint64 subscriptionId) VRFConsumerBaseV2(vrfCoordinator) {
    COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
    LINKTOKEN = LinkTokenInterface(link);
    lottoryOwner = msg.sender;
    lSubscriptionId = subscriptionId;
  }

  event SelectWinner(address potWinner, uint potBalance);

  modifier ownerOnly() {
    require(msg.sender == lottoryOwner, "Owner Only! . You have not the right Access.");
    _;
  }

  // fallback() external payable {
  //       // player name will be unknown
  // }

  function requestRandomWords() external ownerOnly {
    lRequestId = COORDINATOR.requestRandomWords(
      keyHash,
      lSubscriptionId,
      requestConfirmations,
      callbackGasLimit,
      numWords
    );
  }

  // function fulfillRandomness(bytes32 requestId, uint256 randomness) external override {
  //     reqId = requestId;
  //     randomNumber = randomness;
  // }
  function fulfillRandomWords(
    uint256, /* requestId */
    uint256[] memory randomWords
  ) internal override {
    lRandomWords = randomWords;
  }

  function balanceInPot() public view returns(uint){
    return address(this).balance;
  }

  function play() public payable {
    require(msg.value >= 0.01 ether && msg.value < 100 ether, "Value should be between 0.01 & 100 BNB");
    potPlayers.push(msg.sender);
  }

  // function randomGenerator() private view returns (uint) {
  //   return uint(
  //     keccak256(
  //       abi.encodePacked(
  //         block.difficulty, block.timestamp, potPlayers )));
  // }

  function select_Send_WinnerPrize() public ownerOnly {
    // uint winnerIndex = randomGenerator() % potPlayers.length;
    uint winnerIndex = lRandomWords[0] % potPlayers.length;
    address payable potWinner = payable(potPlayers[winnerIndex]);
    potPlayers = new address[](0);
    emit SelectWinner(potWinner, address(this).balance);
    potWinner.transfer(address(this).balance);
    // potPlayers[winnerIndex].transfer(address(this).balance);
    // console.log(potWinner);
  }

  function listPlayers() public view returns (address[] memory){
    return potPlayers;
  }

  function withdraw() external ownerOnly {
    payable(msg.sender).transfer(address(this).balance);
  }

}

