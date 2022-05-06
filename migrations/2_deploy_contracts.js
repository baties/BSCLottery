var LotteryCore=artifacts.require ("./LotteryCore.sol");
var WeeklyLottery=artifacts.require ("./WeeklyLottery.sol");
var MonthlyLottery=artifacts.require ("./MonthlyLottery.sol");
var LotteryGenerator=artifacts.require ("./LotteryGenerator.sol");
var LotteryLiquidityPool=artifacts.require ("./LotteryLiquidityPool.sol");
var LotteryMultiSigWallet= artifacts.require("./LotteryMultiSigWallet.sol");
// const VRFv2ConsumerAddress = "0xE535CB9554C86c78fCf9ef1EaE9862ed4A8afA46";  // Rinkeby TestNet
const VRFv2ConsumerAddress = "0x904C3029603a58e499197Ce4315D6185d8D5012A";  // BSC Testnet
module.exports = function(deployer) {
   deployer.deploy(LotteryCore, VRFv2ConsumerAddress);
   deployer.deploy(LotteryGenerator);
   deployer.deploy(WeeklyLottery, VRFv2ConsumerAddress);
   deployer.deploy(MonthlyLottery, VRFv2ConsumerAddress);
   deployer.deploy(LotteryLiquidityPool);
   deployer.deploy(LotteryMultiSigWallet);
}
