import { tokens, ether, ETHER_ADDRESS, ONLY_OWNER, EVM_REVERT, wait } from './helper.js'

const LotteryCore = artifacts.require('./LotteryCore')
const LotteryGenerator = artifacts.require('./LotteryGenerator')
const LotteryLiquidityPool = artifacts.require('./LotteryLiquidityPool')
const WeeklyLottery = artifacts.require('./WeeklyLottery')
const MonthlyLottery = artifacts.require('./MonthlyLottery')

const lotteryAddress = LotteryCore.address
const lotteryGeneratorAddress = LotteryGenerator.address
const lotteryLiquidityPoolAddress = LotteryLiquidityPool.address
const weeklyLotteryAddress = WeeklyLottery.address
const monthlyLotteryAddress = MonthlyLottery.address

console.log(lotteryAddress)
console.log(lotteryGeneratorAddress)

require('chai')
  .use(require('chai-as-promised'))
  .should()

contract('LotteryCore', ([deployer, user]) => {
    let lotteryCore

    console.log(deployer)
    console.log(user)

    beforeEach(async () => {
        lotteryCore = await LotteryCore.new(lotteryLiquidityPoolAddress, lotteryGeneratorAddress, weeklyLotteryAddress, monthlyLotteryAddress, lotteryLiquidityPoolAddress)
    })

    describe('Testing Lottery Smart Contracts Initialization ...', function() {
        it('The Hourly Pot should be Initialized Firstly ...', async () => {
            expect(await lotteryCore.isPotActive()).to.be.eq(true)
        });
        it('The Hourly Pot should not be in Select Winner Mode Firstly ...', async () => {
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
            await lotteryCore.potInitialize();
            await lotteryCore.enter({ from: deployer, value: 100 });
            await lotteryCore.enter({ from: deployer, value: 100 });
            await lotteryCore.enter({ from: deployer, value: 100 });
            await lotteryCore.enter({ from: deployer, value: 100 });
            await lotteryCore.enter({ from: deployer, value: 100 });
        })

        it('Number of player...', async () => {
            expect(Number(await lotteryCore.getPlayersNumber())).to.eq(5)
        });

        it('Balance of Contract...', async () => {
            expect(Number(await lotteryCore.balanceInPot())).to.eq(100 * 5)
        });

        it('Game should be ready for Select Winner...', async () => {
            expect(await lotteryCore.isReadySelectWinner()).to.eq(true);
        });
    });

    describe('Pickup Winner ...', function() {
        it('Number of player...', async () => {
            expect(Number(await lotteryCore.getPlayerNumber())).to.eq(0)
        });

        beforeEach(async () => {
            await lotteryCore.pickWinner({from: deployer});
            await lotteryCore.initialize();
        });
        
        it('PickWinner Success...', async () => {
            expect(Number(await lotteryCore.balanceInPool())).to.eq(0);
        });
        
    });
});