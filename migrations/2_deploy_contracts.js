var LotteryCore=artifacts.require ("./LotteryCore.sol");
var WeeklyLottery=artifacts.require ("./WeeklyLottery.sol");
var MonthlyLottery=artifacts.require ("./MonthlyLottery.sol");
var LotteryGenerator=artifacts.require ("./LotteryGenerator.sol");
var LotteryLiquidityPool=artifacts.require ("./LotteryLiquidityPool.sol");
var LotteryMultiSigWallet= artifacts.require("./LotteryMultiSigWallet.sol");
const VRFv2ConsumerAddress = "0xE535CB9554C86c78fCf9ef1EaE9862ed4A8afA46";
module.exports = function(deployer) {
   deployer.deploy(LotteryCore, VRFv2ConsumerAddress);
   deployer.deploy(LotteryGenerator);
   deployer.deploy(WeeklyLottery, VRFv2ConsumerAddress);
   deployer.deploy(MonthlyLottery, VRFv2ConsumerAddress);
   deployer.deploy(LotteryLiquidityPool);
   deployer.deploy(LotteryMultiSigWallet);
}
