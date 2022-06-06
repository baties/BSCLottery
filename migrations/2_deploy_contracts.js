// let generatorAddress = "0x0000000000000000000000000000000000000000" ;
// let weeklyAddress = "0x0000000000000000000000000000000000000000";
// let monthlyAddress = "0x0000000000000000000000000000000000000000";
// let liquidityAddress = "0x0000000000000000000000000000000000000000";

var LotteryCore=artifacts.require ("./LotteryCore.sol");
var WeeklyLottery=artifacts.require ("./WeeklyLottery.sol");
var MonthlyLottery=artifacts.require ("./MonthlyLottery.sol");
var LotteryGenerator=artifacts.require ("./LotteryGenerator.sol");
var LotteryLiquidityPool=artifacts.require ("./LotteryLiquidityPool.sol");
var LotteryMultiSigWallet= artifacts.require("./LotteryMultiSigWallet.sol");
// const VRFv2ConsumerAddress = "0xE535CB9554C86c78fCf9ef1EaE9862ed4A8afA46";  // Rinkeby TestNet
// const VRFv2ConsumerAddress = "0x904C3029603a58e499197Ce4315D6185d8D5012A";  // BSC Testnet  ID:707  Owner: 0x4de8d75ef9b48856e708347c4a0bf1bca338db53
// const VRFv2ConsumerAddress = "0x1e481086668e91bacad76e58ecd015062d22cea9";  // BSC Testnet  ID:706  Owner: 0x893300d805a6db7d4e691fa7679db53c94802cde

// module.exports = function(deployer) {
//    deployer.deploy(LotteryGenerator).then(() => generatorAddress = LotteryGenerator.address);
//    deployer.deploy(WeeklyLottery, VRFv2ConsumerAddress, generatorAddress).then(() => weeklyAddress = WeeklyLottery.address);
//    deployer.deploy(MonthlyLottery, VRFv2ConsumerAddress, generatorAddress).then(() => monthlyAddress = MonthlyLottery.address);
//    deployer.deploy(LotteryLiquidityPool).then(() => liquidityAddress = LotteryLiquidityPool.address);
//    deployer.deploy(LotteryMultiSigWallet);
//    deployer.deploy(LotteryCore, VRFv2ConsumerAddress, generatorAddress, weeklyAddress, monthlyAddress, liquidityAddress).then(() => console.log(LotteryCore.address));
// }

const SubscriptionID = 706;

module.exports = function (deployer) {
   deployer.deploy(LotteryMultiSigWallet);
   deployer.deploy(LotteryLiquidityPool).then(async() => {
      const cLiquidityInstance = await LotteryLiquidityPool.deployed();
      console.log(cLiquidityInstance.address);
      await deployer.deploy(LotteryGenerator).then(async() => {
         const cGeneratorInstance = await LotteryGenerator.deployed();
         console.log(cGeneratorInstance.address);
         await deployer.deploy(MonthlyLottery, SubscriptionID, cGeneratorInstance.address).then(async() => {  // VRFv2ConsumerAddress
            const cMonthlyInstance = await MonthlyLottery.deployed();
            console.log(cMonthlyInstance.address);
            await deployer.deploy(WeeklyLottery, SubscriptionID, cGeneratorInstance.address).then(async() => {  // VRFv2ConsumerAddress
               const cWeeklyInstance = await WeeklyLottery.deployed();
               console.log(cWeeklyInstance.address);
               await deployer.deploy(LotteryCore, SubscriptionID, cGeneratorInstance.address, cWeeklyInstance.address, cMonthlyInstance.address, cLiquidityInstance.address);  // VRFv2ConsumerAddress
            })
         })

      })
   })
}


