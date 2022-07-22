// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract LotteryLiquidityPool is Ownable {

  address contractOwner;
  address multiSigAddr;

  constructor(address MultiSigAddress) {
    contractOwner = msg.sender;
    multiSigAddr = MultiSigAddress;
  }

  fallback() external payable {
  }
  receive() external payable {
  }

  function balanceInPot() public view returns(uint){
    return address(this).balance;
  }

  function close() public onlyOwner { 
    address payable addr = payable(address(contractOwner));  // owner
    selfdestruct(addr); 
}

  function withdraw() external onlyOwner {
    payable(msg.sender).transfer(address(this).balance);
  }

  function sendToMultiSig(uint amount) public payable onlyOwner {
    if (amount == 0) {
      amount = address(this).balance;
    }
    require(amount <= address(this).balance);
    (bool sent, ) = multiSigAddr.call{value: amount}("");  // bytes memory data
    require(sent, "Failed to send Ether");
  }

  function set_MultiSigAddress(address _MultiSigAddress) external onlyOwner {
    require(_MultiSigAddress != address(0), "Given Address is Empty!");
    multiSigAddr = _MultiSigAddress;
  }

  function get_MultiSigAddress() external view returns(address) {
    return multiSigAddr;
  }

}