
var LotteryCore=artifacts.require ("./LotteryCore.sol");
var WeeklyLottery=artifacts.require ("./WeeklyLottery.sol");
var MonthlyLottery=artifacts.require ("./MonthlyLottery.sol");
var LotteryGenerator=artifacts.require ("./LotteryGenerator.sol");
var LotteryLiquidityPool=artifacts.require ("./LotteryLiquidityPool.sol");
var LotteryMultiSigWallet= artifacts.require("./LotteryMultiSigWallet.sol");

// const VRFv2ConsumerAddress = "0xE535CB9554C86c78fCf9ef1EaE9862ed4A8afA46";  // Rinkeby TestNet
// const VRFv2ConsumerAddress = "0x904C3029603a58e499197Ce4315D6185d8D5012A";  // BSC Testnet  ID:707  Owner: 0x4de8d75ef9b48856e708347c4a0bf1bca338db53
// const VRFv2ConsumerAddress = "0x1e481086668e91bacad76e58ecd015062d22cea9";  // BSC Testnet  ID:706  Owner: 0x893300d805a6db7d4e691fa7679db53c94802cde
// const VRFv2ConsumerAddress = "" 

const OwnerNoOne = "0xbf665F71d93B9Ec85d05A05529cDaC90e97d1034" ; 
const OwnerNoTwo = "0x42651d187Fc5f75dFA8349364b705F1F47819C12" ; 
const OwnerNoThree = "0x5d86E2609d5f41227846BC838B0D571FbaBab182" ; 
const OwnerNoFour = "0xc6A0C1C4b860ddfe653CA59bF814a3061dE876C0" ; 


// const SubscriptionID = 706;  // BSC TestNet
// const SubscriptionID = 2181;  // Rinkeby TestNet
const SubscriptionID = 263;  // BSC MainNet


module.exports = function (deployer) {
   deployer.deploy(LotteryMultiSigWallet).then(async() => { 
      const cMultiSigWalletInstance = await LotteryMultiSigWallet.deployed([OwnerNoOne,OwnerNoTwo,OwnerNoThree,OwnerNoFour],2);
      console.log("MultiSig Wallet: " + cMultiSigWalletInstance.address);
      await deployer.deploy(LotteryLiquidityPool, cMultiSigWalletInstance.address).then(async() => {
         const cLiquidityInstance = await LotteryLiquidityPool.deployed();
         console.log("Liquidity Pool: " + cLiquidityInstance.address);
         await deployer.deploy(LotteryGenerator).then(async() => {
            const cGeneratorInstance = await LotteryGenerator.deployed();
            console.log("Lottery Generator: " + cGeneratorInstance.address);
            await deployer.deploy(MonthlyLottery, SubscriptionID, cGeneratorInstance.address).then(async() => {  // VRFv2ConsumerAddress
               const cMonthlyInstance = await MonthlyLottery.deployed();
               console.log("Monthly Lottery: " + cMonthlyInstance.address);
               await deployer.deploy(WeeklyLottery, SubscriptionID, cGeneratorInstance.address).then(async() => {  // VRFv2ConsumerAddress
                  const cWeeklyInstance = await WeeklyLottery.deployed();
                  console.log("Weekly Lottery: " + cWeeklyInstance.address);
                  await deployer.deploy(LotteryCore, SubscriptionID, cGeneratorInstance.address, cWeeklyInstance.address, cMonthlyInstance.address, cLiquidityInstance.address, cMultiSigWalletInstance.address).then(async() => {  // VRFv2ConsumerAddress
                     const cHourlyInstance = await LotteryCore.deployed();
                     console.log("Hourly Lottery: " + cHourlyInstance.address);
                  }) ;  
               })
            })
         })
      }) 
   })
}




/*
module.exports = function (deployer) {
   // "0x0000000000000000000000000000000000000000"
   let LotteryCoreAddress = "0x50fC3eb5FB1D5890a927087CF3a5CaAB9E410F40";
   let GeneralLotteryAddress = "0x30d8d623660C52E6567dcEEb3Ce5ae0f6F3c40AD";
   let WeeklyLotteryAddress = "0x685fEFbd629B1C1306e4b2763c4B461a3c0a8Efb";
   let MonthlyLotteryAddress = "0x4bf8c11824F24e637CB2eAB2181a14b2DA38aDF9";
   let LiquidityPoolAddress = "0x723a4b3B3b8F5ad05f87C8e08Da352e380275F58";
   let LotteryMultiSigWalletAddress = "0xF25163F3FdD9268Ce4E5CC5018536A3a4B08354D";
   deployer.deploy(LotteryMultiSigWallet);
   deployer.deploy(LotteryLiquidityPool, LotteryMultiSigWalletAddress);
   deployer.deploy(LotteryGenerator);
   deployer.deploy(MonthlyLottery, SubscriptionID, GeneralLotteryAddress);
   deployer.deploy(WeeklyLottery, SubscriptionID, GeneralLotteryAddress);
   deployer.deploy(LotteryCore, SubscriptionID, GeneralLotteryAddress, WeeklyLotteryAddress, MonthlyLotteryAddress, LiquidityPoolAddress, LotteryMultiSigWalletAddress);
}
*/



// module.exports = function(deployer) {
//    deployer.deploy(LotteryGenerator).then(() => generatorAddress = LotteryGenerator.address);
//    deployer.deploy(WeeklyLottery, VRFv2ConsumerAddress, generatorAddress).then(() => weeklyAddress = WeeklyLottery.address);
//    deployer.deploy(MonthlyLottery, VRFv2ConsumerAddress, generatorAddress).then(() => monthlyAddress = MonthlyLottery.address);
//    deployer.deploy(LotteryLiquidityPool).then(() => liquidityAddress = LotteryLiquidityPool.address);
//    deployer.deploy(LotteryMultiSigWallet);
//    deployer.deploy(LotteryCore, VRFv2ConsumerAddress, generatorAddress, weeklyAddress, monthlyAddress, liquidityAddress).then(() => console.log(LotteryCore.address));
// }



