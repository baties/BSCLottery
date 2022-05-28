const ganache = require('ganache-cli');
const Web3 = require('web3');
const chai = require('chai');
const chaiAsPromised = require('chai-as-promised');
const chaiAlmost = require('chai-almost');
const assert = require('chai').assert;
const should = require('chai').should();

chai.use(chaiAsPromised);
chai.use(chaiAlmost());

const { expect } = require('chai')

const LotteryCore = artifacts.require('./LotteryCore')
const LotteryGenerator = artifacts.require('./LotteryGenerator')
const LotteryLiquidityPool = artifacts.require('./LotteryLiquidityPool')
const WeeklyLottery = artifacts.require('./WeeklyLottery')
const MonthlyLottery = artifacts.require('./MonthlyLottery')

// const lotteryAddress = LotteryCore.address
// const lotteryGeneratorAddress = LotteryGenerator.address
// const lotteryLiquidityPoolAddress = LotteryLiquidityPool.address
// const weeklyLotteryAddress = WeeklyLottery.address
// const monthlyLotteryAddress = MonthlyLottery.address

// console.log("================================")
// // console.log(lotteryLiquidityPoolAddress)
// // console.log(lotteryGeneratorAddress)
// // console.log(monthlyLotteryAddress)
// // console.log(weeklyLotteryAddress)
// console.log(lotteryAddress)
// console.log("================================")


require('chai')
  .use(require('chai-as-promised'))
  .should()

contract('LotteryCore', ([deployer, user, user1, user2, user3, user4, user5]) => {
    let lotteryCore
    let lotteryliquidity
    let lotteryGenerator
    let weeklylottery
    let monthlylottery

    // console.log("######################################")
    // console.log(deployer)
    // console.log(user)
    // console.log(user1)
    // console.log(user2)
    // console.log(user3)
    // console.log(user4)
    // console.log(user5)
    // console.log("######################################")

    beforeEach(async () => {
        lotteryliquidity = await LotteryLiquidityPool.new()
        lotteryGenerator = await LotteryGenerator.new()
        const lotteryLiquidityPoolAddress = lotteryliquidity.address
        const lotteryGeneratorAddress = lotteryGenerator.address
        weeklylottery = await WeeklyLottery.new(lotteryGeneratorAddress, lotteryLiquidityPoolAddress)         
        monthlylottery = await MonthlyLottery.new(lotteryGeneratorAddress, lotteryLiquidityPoolAddress)         
        const weeklyLotteryAddress = WeeklyLottery.address
        const monthlyLotteryAddress = MonthlyLottery.address
        lotteryCore = await LotteryCore.new(lotteryLiquidityPoolAddress, lotteryGeneratorAddress, weeklyLotteryAddress, monthlyLotteryAddress, lotteryLiquidityPoolAddress)
    })

    describe('Testing Lottery Smart Contracts Initialization ...', function() {
        it('The Hourly Pot should be Initialized Firstly ...', async () => {
            // console.log(await lotteryCore.isPotActive())
            expect(await lotteryCore.isPotActive()).to.be.eq(true)
        });
        it('The Hourly Pot should not be in Select Winner Mode Firstly ...', async () => {
            // console.log(await lotteryCore.isReadySelectWinner())
            expect(await lotteryCore.isReadySelectWinner()).to.be.eq(false)
        });
    });

    // describe('Test Pot Starting ...', function() {
    //     beforeEach(async () => {
    //         await lotteryCore.potInitialize();
    //     })

    //     it('Ticket Price ...', async () => {
    //         expect(Number(await lottery.ticket_price())).to.eq(1)
    //     });
    // });

    describe('Player Enter ...', function() {

        beforeEach(async () => {
            // await lottery.potInitialize(20, 10, { from: deployer });
            // await lotteryCore.potInitialize();
            await lotteryCore.play({ from: user1, value: 100 * 10 ** 15 });
            await lotteryCore.play({ from: user2, value: 100 * 10 ** 15 });
            await lotteryCore.play({ from: user3, value: 100 * 10 ** 15 });
            await lotteryCore.play({ from: user4, value: 100 * 10 ** 15 });
            await lotteryCore.play({ from: user5, value: 100 * 10 ** 15 });
        })

        it('Number of player...', async () => {
            // console.log(Number(await lotteryCore.getPlayersNumber()))
            expect(Number(await lotteryCore.getPlayersNumber())).to.eq(5)
        });

        it('Balance of Contract...', async () => {
            // console.log(Number(await lotteryCore.balanceInPot()))
            expect(Number(await lotteryCore.balanceInPot())).to.eq(100 * 10 ** 15 * 5)
        });

        it('Game should be ready for Select Winner...', async () => {
            // console.log(await lotteryCore.isReadySelectWinner())
            expect(await lotteryCore.isReadySelectWinner()).to.eq(true);
        });
    });

    describe('Pickup Winner ...', function() {

        before(async () => {
            await lotteryCore.setDirector(user, { from: deployer });
            // console.log(await lotteryCore.getPotDirector());
            await lotteryCore.play({ from: user1, value: 100 * 10 ** 15 });
            await lotteryCore.play({ from: user2, value: 100 * 10 ** 15 });
            await lotteryCore.play({ from: user3, value: 100 * 10 ** 15 });
            await lotteryCore.play({ from: user4, value: 100 * 10 ** 15 });
            await lotteryCore.play({ from: user5, value: 100 * 10 ** 15 });
            await lotteryCore.select_Winner({from: deployer});
            await lotteryCore.potInitialize();
        });
        
        it('Number of player...', async () => {
            expect(Number(await lotteryCore.getPlayersNumber())).to.eq(0)
        });

        it('PickWinner Success...', async () => {
            expect(Number(await lotteryCore.balanceInPot())).to.eq(0);
        });

        it('Select a Winner ..', async () => {
            // expect(await lotteryCore.getWinners()).to.eq('0x0000000000000000000000000000000000000000');
            const [winnerAddress, winnerPrize] = await lotteryCore.getWinners();
            console.log(winnerAddress);
            expect(winnerAddress.to.eq('0x0000000000000000000000000000000000000000'));
        });
        
    });
});