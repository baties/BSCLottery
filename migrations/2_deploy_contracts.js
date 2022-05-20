let generatorAddress = "0x0000000000000000000000000000000000000000" ;
let weeklyAddress = "0x0000000000000000000000000000000000000000";
let monthlyAddress = "0x0000000000000000000000000000000000000000";
let liquidityAddress = "0x0000000000000000000000000000000000000000";

var LotteryCore=artifacts.require ("./LotteryCore.sol");
var WeeklyLottery=artifacts.require ("./WeeklyLottery.sol");
var MonthlyLottery=artifacts.require ("./MonthlyLottery.sol");
var LotteryGenerator=artifacts.require ("./LotteryGenerator.sol");
var LotteryLiquidityPool=artifacts.require ("./LotteryLiquidityPool.sol");
var LotteryMultiSigWallet= artifacts.require("./LotteryMultiSigWallet.sol");
// const VRFv2ConsumerAddress = "0xE535CB9554C86c78fCf9ef1EaE9862ed4A8afA46";  // Rinkeby TestNet
const VRFv2ConsumerAddress = "0x904C3029603a58e499197Ce4315D6185d8D5012A";  // BSC Testnet
module.exports = function(deployer) {
   deployer.deploy(LotteryGenerator).then(() => generatorAddress = LotteryGenerator.address);
   deployer.deploy(WeeklyLottery, VRFv2ConsumerAddress, generatorAddress).then(() => weeklyAddress = WeeklyLottery.address);
   deployer.deploy(MonthlyLottery, VRFv2ConsumerAddress, generatorAddress).then(() => monthlyAddress = MonthlyLottery.address);
   deployer.deploy(LotteryLiquidityPool).then(() => liquidityAddress = LotteryLiquidityPool.address);
   deployer.deploy(LotteryMultiSigWallet);
   deployer.deploy(LotteryCore, VRFv2ConsumerAddress, generatorAddress, weeklyAddress, monthlyAddress, liquidityAddress).then(() => console.log(LotteryCore.address));
}
