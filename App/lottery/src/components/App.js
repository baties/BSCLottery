import './App.css';
import React, { useEffect, useState} from 'react';
import { Container, Row, Col, Card, Button, Table} from 'react-bootstrap'
import ProgressBar from 'react-bootstrap/ProgressBar'
import Modal from 'react-bootstrap/Modal'

import COIN1 from '../images/COIN_01.png'
import COIN2 from '../images/COIN_02.png'
import COIN3 from '../images/COIN_03.png'
import MACHINE from '../images/lottery_machine.png'

import Start from './Start.js'

import Web3 from 'web3' ;
// const web3 = new Web3(window.ethereum.currentProvider);

import LotteryCore from "./contractx/LotteryCore.json";
import LotteryGenerator from "./contractx/LotteryGenerator.json";
import WeeklyLottery from "./contractx/WeeklyLottery.json";
import MonthlyLottery from "./contractx/MonthlyLottery.json";
import LotteryLiquidityPool from "./contractx/LotteryLiquidityPool.json";

// import * as fs from 'fs';

const METAMAST_BASE64_URL = "data:image/svg+xml;utf8;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyMTIiIGhlaWdodD0iMTg5IiB2aWV3Qm94PSIwIDAgMjEyIDE4OSI+PGcgZmlsbD0ibm9uZSIgZmlsbC1ydWxlPSJldmVub2RkIj48cG9seWdvbiBmaWxsPSIjQ0RCREIyIiBwb2ludHM9IjYwLjc1IDE3My4yNSA4OC4zMTMgMTgwLjU2MyA4OC4zMTMgMTcxIDkwLjU2MyAxNjguNzUgMTA2LjMxMyAxNjguNzUgMTA2LjMxMyAxODAgMTA2LjMxMyAxODcuODc1IDg5LjQzOCAxODcuODc1IDY4LjYyNSAxNzguODc1Ii8+PHBvbHlnb24gZmlsbD0iI0NEQkRCMiIgcG9pbnRzPSIxMDUuNzUgMTczLjI1IDEzMi43NSAxODAuNTYzIDEzMi43NSAxNzEgMTM1IDE2OC43NSAxNTAuNzUgMTY4Ljc1IDE1MC43NSAxODAgMTUwLjc1IDE4Ny44NzUgMTMzLjg3NSAxODcuODc1IDExMy4wNjMgMTc4Ljg3NSIgdHJhbnNmb3JtPSJtYXRyaXgoLTEgMCAwIDEgMjU2LjUgMCkiLz48cG9seWdvbiBmaWxsPSIjMzkzOTM5IiBwb2ludHM9IjkwLjU2MyAxNTIuNDM4IDg4LjMxMyAxNzEgOTEuMTI1IDE2OC43NSAxMjAuMzc1IDE2OC43NSAxMjMuNzUgMTcxIDEyMS41IDE1Mi40MzggMTE3IDE0OS42MjUgOTQuNSAxNTAuMTg4Ii8+PHBvbHlnb24gZmlsbD0iI0Y4OUMzNSIgcG9pbnRzPSI3NS4zNzUgMjcgODguODc1IDU4LjUgOTUuMDYzIDE1MC4xODggMTE3IDE1MC4xODggMTIzLjc1IDU4LjUgMTM2LjEyNSAyNyIvPjxwb2x5Z29uIGZpbGw9IiNGODlEMzUiIHBvaW50cz0iMTYuMzEzIDk2LjE4OCAuNTYzIDE0MS43NSAzOS45MzggMTM5LjUgNjUuMjUgMTM5LjUgNjUuMjUgMTE5LjgxMyA2NC4xMjUgNzkuMzEzIDU4LjUgODMuODEzIi8+PHBvbHlnb24gZmlsbD0iI0Q4N0MzMCIgcG9pbnRzPSI0Ni4xMjUgMTAxLjI1IDkyLjI1IDEwMi4zNzUgODcuMTg4IDEyNiA2NS4yNSAxMjAuMzc1Ii8+PHBvbHlnb24gZmlsbD0iI0VBOEQzQSIgcG9pbnRzPSI0Ni4xMjUgMTAxLjgxMyA2NS4yNSAxMTkuODEzIDY1LjI1IDEzNy44MTMiLz48cG9seWdvbiBmaWxsPSIjRjg5RDM1IiBwb2ludHM9IjY1LjI1IDEyMC4zNzUgODcuNzUgMTI2IDk1LjA2MyAxNTAuMTg4IDkwIDE1MyA2NS4yNSAxMzguMzc1Ii8+PHBvbHlnb24gZmlsbD0iI0VCOEYzNSIgcG9pbnRzPSI2NS4yNSAxMzguMzc1IDYwLjc1IDE3My4yNSA5MC41NjMgMTUyLjQzOCIvPjxwb2x5Z29uIGZpbGw9IiNFQThFM0EiIHBvaW50cz0iOTIuMjUgMTAyLjM3NSA5NS4wNjMgMTUwLjE4OCA4Ni42MjUgMTI1LjcxOSIvPjxwb2x5Z29uIGZpbGw9IiNEODdDMzAiIHBvaW50cz0iMzkuMzc1IDEzOC45MzggNjUuMjUgMTM4LjM3NSA2MC43NSAxNzMuMjUiLz48cG9seWdvbiBmaWxsPSIjRUI4RjM1IiBwb2ludHM9IjEyLjkzOCAxODguNDM4IDYwLjc1IDE3My4yNSAzOS4zNzUgMTM4LjkzOCAuNTYzIDE0MS43NSIvPjxwb2x5Z29uIGZpbGw9IiNFODgyMUUiIHBvaW50cz0iODguODc1IDU4LjUgNjQuNjg4IDc4Ljc1IDQ2LjEyNSAxMDEuMjUgOTIuMjUgMTAyLjkzOCIvPjxwb2x5Z29uIGZpbGw9IiNERkNFQzMiIHBvaW50cz0iNjAuNzUgMTczLjI1IDkwLjU2MyAxNTIuNDM4IDg4LjMxMyAxNzAuNDM4IDg4LjMxMyAxODAuNTYzIDY4LjA2MyAxNzYuNjI1Ii8+PHBvbHlnb24gZmlsbD0iI0RGQ0VDMyIgcG9pbnRzPSIxMjEuNSAxNzMuMjUgMTUwLjc1IDE1Mi40MzggMTQ4LjUgMTcwLjQzOCAxNDguNSAxODAuNTYzIDEyOC4yNSAxNzYuNjI1IiB0cmFuc2Zvcm09Im1hdHJpeCgtMSAwIDAgMSAyNzIuMjUgMCkiLz48cG9seWdvbiBmaWxsPSIjMzkzOTM5IiBwb2ludHM9IjcwLjMxMyAxMTIuNSA2NC4xMjUgMTI1LjQzOCA4Ni4wNjMgMTE5LjgxMyIgdHJhbnNmb3JtPSJtYXRyaXgoLTEgMCAwIDEgMTUwLjE4OCAwKSIvPjxwb2x5Z29uIGZpbGw9IiNFODhGMzUiIHBvaW50cz0iMTIuMzc1IC41NjMgODguODc1IDU4LjUgNzUuOTM4IDI3Ii8+PHBhdGggZmlsbD0iIzhFNUEzMCIgZD0iTTEyLjM3NTAwMDIsMC41NjI1MDAwMDggTDIuMjUwMDAwMDMsMzEuNTAwMDAwNSBMNy44NzUwMDAxMiw2NS4yNTAwMDEgTDMuOTM3NTAwMDYsNjcuNTAwMDAxIEw5LjU2MjUwMDE0LDcyLjU2MjUgTDUuMDYyNTAwMDgsNzYuNTAwMDAxMSBMMTEuMjUsODIuMTI1MDAxMiBMNy4zMTI1MDAxMSw4NS41MDAwMDEzIEwxNi4zMTI1MDAyLDk2Ljc1MDAwMTQgTDU4LjUwMDAwMDksODMuODEyNTAxMiBDNzkuMTI1MDAxMiw2Ny4zMTI1MDA0IDg5LjI1MDAwMTMsNTguODc1MDAwMyA4OC44NzUwMDEzLDU4LjUwMDAwMDkgQzg4LjUwMDAwMTMsNTguMTI1MDAwOSA2My4wMDAwMDA5LDM4LjgxMjUwMDYgMTIuMzc1MDAwMiwwLjU2MjUwMDAwOCBaIi8+PGcgdHJhbnNmb3JtPSJtYXRyaXgoLTEgMCAwIDEgMjExLjUgMCkiPjxwb2x5Z29uIGZpbGw9IiNGODlEMzUiIHBvaW50cz0iMTYuMzEzIDk2LjE4OCAuNTYzIDE0MS43NSAzOS45MzggMTM5LjUgNjUuMjUgMTM5LjUgNjUuMjUgMTE5LjgxMyA2NC4xMjUgNzkuMzEzIDU4LjUgODMuODEzIi8+PHBvbHlnb24gZmlsbD0iI0Q4N0MzMCIgcG9pbnRzPSI0Ni4xMjUgMTAxLjI1IDkyLjI1IDEwMi4zNzUgODcuMTg4IDEyNiA2NS4yNSAxMjAuMzc1Ii8+PHBvbHlnb24gZmlsbD0iI0VBOEQzQSIgcG9pbnRzPSI0Ni4xMjUgMTAxLjgxMyA2NS4yNSAxMTkuODEzIDY1LjI1IDEzNy44MTMiLz48cG9seWdvbiBmaWxsPSIjRjg5RDM1IiBwb2ludHM9IjY1LjI1IDEyMC4zNzUgODcuNzUgMTI2IDk1LjA2MyAxNTAuMTg4IDkwIDE1MyA2NS4yNSAxMzguMzc1Ii8+PHBvbHlnb24gZmlsbD0iI0VCOEYzNSIgcG9pbnRzPSI2NS4yNSAxMzguMzc1IDYwLjc1IDE3My4yNSA5MCAxNTMiLz48cG9seWdvbiBmaWxsPSIjRUE4RTNBIiBwb2ludHM9IjkyLjI1IDEwMi4zNzUgOTUuMDYzIDE1MC4xODggODYuNjI1IDEyNS43MTkiLz48cG9seWdvbiBmaWxsPSIjRDg3QzMwIiBwb2ludHM9IjM5LjM3NSAxMzguOTM4IDY1LjI1IDEzOC4zNzUgNjAuNzUgMTczLjI1Ii8+PHBvbHlnb24gZmlsbD0iI0VCOEYzNSIgcG9pbnRzPSIxMi45MzggMTg4LjQzOCA2MC43NSAxNzMuMjUgMzkuMzc1IDEzOC45MzggLjU2MyAxNDEuNzUiLz48cG9seWdvbiBmaWxsPSIjRTg4MjFFIiBwb2ludHM9Ijg4Ljg3NSA1OC41IDY0LjY4OCA3OC43NSA0Ni4xMjUgMTAxLjI1IDkyLjI1IDEwMi45MzgiLz48cG9seWdvbiBmaWxsPSIjMzkzOTM5IiBwb2ludHM9IjcwLjMxMyAxMTIuNSA2NC4xMjUgMTI1LjQzOCA4Ni4wNjMgMTE5LjgxMyIgdHJhbnNmb3JtPSJtYXRyaXgoLTEgMCAwIDEgMTUwLjE4OCAwKSIvPjxwb2x5Z29uIGZpbGw9IiNFODhGMzUiIHBvaW50cz0iMTIuMzc1IC41NjMgODguODc1IDU4LjUgNzUuOTM4IDI3Ii8+PHBhdGggZmlsbD0iIzhFNUEzMCIgZD0iTTEyLjM3NTAwMDIsMC41NjI1MDAwMDggTDIuMjUwMDAwMDMsMzEuNTAwMDAwNSBMNy44NzUwMDAxMiw2NS4yNTAwMDEgTDMuOTM3NTAwMDYsNjcuNTAwMDAxIEw5LjU2MjUwMDE0LDcyLjU2MjUgTDUuMDYyNTAwMDgsNzYuNTAwMDAxMSBMMTEuMjUsODIuMTI1MDAxMiBMNy4zMTI1MDAxMSw4NS41MDAwMDEzIEwxNi4zMTI1MDAyLDk2Ljc1MDAwMTQgTDU4LjUwMDAwMDksODMuODEyNTAxMiBDNzkuMTI1MDAxMiw2Ny4zMTI1MDA0IDg5LjI1MDAwMTMsNTguODc1MDAwMyA4OC44NzUwMDEzLDU4LjUwMDAwMDkgQzg4LjUwMDAwMTMsNTguMTI1MDAwOSA2My4wMDAwMDA5LDM4LjgxMjUwMDYgMTIuMzc1MDAwMiwwLjU2MjUwMDAwOCBaIi8+PC9nPjwvZz48L3N2Zz4=";

// const dotenv = require('dotenv');
// dotenv.config();
// const mnemonic = process.env.MNEMONIC;

// require('dotenv').config() ;

function App() {

    const currentNetwork = "https://rinkeby.etherscan.io/address/";
  
    // const fs = require('fs');
    // const LotteryCoreX = require("./contractx/LotteryCore.json");
    // const abiX = LotteryCoreX["abi"];
    // const contractAddressX = LotteryCoreX["networks"]["97"]["address"];
    // const MyContractX = new web3.eth.Contract(abiX, contractAddressX);  
    // console.log("Lottery Contract Address is : " + contractAddressX);
    // const mnemonic = fs.readFileSync(".env").toString().trim();
    // MyContract.setProvider(`wss://rinkeby.infura.io/ws/v3/${process.env.REACT_APP_INFURA_PROJECT_ID}`);

    const [show, setShow] = useState(false);
    const [web3, setWeb3] = useState('undefined')
    const [account, setAccount] = useState(null)
    const [accountBalance, setAccountBalance] = useState(0)
    const [accountPotCount, setAccountPotCount] = useState(0)
    const [accountPotValue, setAccountPotValue] = useState(0)
  
    const [lottery, setLottery] = useState(null)
    const [lotteryAddress, setLotteryAddress] = useState(null)
    const [lotteryBalance, setLotteryBalance] = useState(0)

    const [lotteryGenerator, setLotteryGenerator] = useState(null)
    const [lotteryGeneratorAddress, setLotteryGeneratorAddress] = useState(null)
    const [lotteryGeneratorBalance, setLotteryGeneratorBalance] = useState(0)

    const [weeklylottery, setWeeklyLottery] = useState(null)
    const [weeklylotteryAddress, setWeeklyLotteryAddress] = useState(null)
    const [weeklylotteryBalance, setWeeklyLotteryBalance] = useState(0)

    const [monthlylottery, setMonthlyLottery] = useState(null)
    const [monthlylotteryAddress, setMonthlyLotteryAddress] = useState(null)
    const [monthlylotteryBalance, setMonthlyLotteryBalance] = useState(0)

    const [liquidityPool, setLiquidityPool] = useState(null)
    const [liquidityPoolAddress, setLiquidityPoolAddress] = useState(null)
    const [liquidityPoolBalance, setLiquidityPoolBalance] = useState(0)

    const [owner, setOwner] = useState(null)  
    // const [verifier, setVerifier] = useState(null)
    const [potDirector, setPotDirector] = useState(null)
    const [ticketPrice, setTicketPrice] = useState(0)
    const [ticketAmount, setTicketAmount] = useState(0)
    const [isPotActive, setIsPotActive] = useState(true)
    const [selectReady, setSelectReady] = useState(false)
    const [winnerSelected, setWinnerSelected] = useState(false)
    const [isPotActiveW, setIsPotActiveW] = useState(true)
    const [selectReadyW, setSelectReadyW] = useState(false)
    const [winnerSelectedW, setWinnerSelectedW] = useState(false)
    const [isPotActiveM, setIsPotActiveM] = useState(true)
    const [selectReadyM, setSelectReadyM] = useState(false)
    const [winnerSelectedM, setWinnerSelectedM] = useState(false)
    const [playerCount, setPlayerCount] = useState(0)
    const [players, setPlayers] = useState([])
    const [winners, setWinners] = useState([])
    const [winnersW, setWinnersW] = useState([])
    const [winnersM, setWinnersM] = useState([])
    const [startedTime, setStartedTime] = useState(0)
    const [progress, setProgress] = useState(0)
    const [formPrice, setFormPrice] = useState(0.01)
    const [formAmount, setFormAmount] = useState(1)
  
    const handleClose = () => setShow(false);
    const handleShow = () => setShow(true);

    useEffect( ()  => {
      
      const loadBlockchainData = async() => {
        if(typeof window.ethereum!=='undefined'){
          const web3 = new Web3(window.ethereum)
          setWeb3(web3)
          
          const netId = await web3.eth.net.getId()
          const accounts = await web3.eth.getAccounts()
          if(typeof accounts[0] !=='undefined'){
            const balance = await web3.eth.getBalance(accounts[0])          
            // console.log(await web3.eth.getCoinbase());
            setAccount(accounts[0])
            setAccountBalance(web3.utils.fromWei(balance))
          } else {
            // Notify to login
            handleShow();        
          }
  
          //load contracts
          try {
            const lottery = new web3.eth.Contract(LotteryCore.abi, LotteryCore.networks[netId].address)
            const lotteryAddress = LotteryCore.networks[netId].address
  
            const lotteryGenerator = new web3.eth.Contract(LotteryGenerator.abi, LotteryGenerator.networks[netId].address)
            const lotteryGeneratorAddress = LotteryGenerator.networks[netId].address
  
            const weeklylottery = new web3.eth.Contract(WeeklyLottery.abi, WeeklyLottery.networks[netId].address)
            const weeklylotteryAddress = WeeklyLottery.networks[netId].address

            const monthlylottery = new web3.eth.Contract(MonthlyLottery.abi, MonthlyLottery.networks[netId].address)
            const monthlylotteryAddress = MonthlyLottery.networks[netId].address

            const liquidityPool = new web3.eth.Contract(LotteryLiquidityPool.abi, LotteryLiquidityPool.networks[netId].address)
            const liquidityPoolAddress = LotteryLiquidityPool.networks[netId].address

            const owner = await lottery.methods.owner().call()
            // const verifier = await lottery.methods.getVerifier().call()
            const potDirector = await lottery.methods.getPotDirector().call()
            
            const lotteryBalance = await lottery.methods.balanceInPot().call()
            const weeklylotteryBalance = await weeklylottery.methods.balanceInPot().call()
            const monthlylotteryBalance = await monthlylottery.methods.balanceInPot().call()
            const liquidityPoolBalance = await liquidityPool.methods.balanceInPot().call()
            
            // let {accountPotCount, accountPotValue} = await lottery.methods.getPlayerAmounts().call()
            const accountPotValue = await lottery.methods.getPlayerValue(accounts[0]).call()

            const ticketPrice = await lottery.methods.getTicketPrice().call()
            const isPotActive = await lottery.methods.isPotActive().call()
            const isPotActiveW = await weeklylottery.methods.isPotActive().call()
            const isPotActiveM = await monthlylottery.methods.isPotActive().call()
            const ticketAmount = await lottery.methods.getTicketAmount().call()
            const playerCount = await lottery.methods.getPlayersNumber().call()

            const players = await lottery.methods.listPlayers().call()
            const winners = await lotteryGenerator.methods.getWinners().call()
            const winnersW = await lotteryGenerator.methods.getWeeklyWinners().call()
            const winnersM = await lotteryGenerator.methods.getWeeklyWinners().call()
            const selectReady = await lottery.methods.isReadySelectWinner().call()
            const winnerSelected = await lottery.methods.isWinnerSelected().call()
            const selectReadyW = await weeklylottery.methods.isReadySelectWinner().call()
            const winnerSelectedW = await weeklylottery.methods.isWinnerSelected().call()
            const selectReadyM = await monthlylottery.methods.isReadySelectWinner().call()
            const winnerSelectedM = await monthlylottery.methods.isWinnerSelected().call()
            // const progress = await lottery.methods.getPercent().call()
            let startedTime = await lottery.methods.getStartedTime().call()
            if(! isPotActive) startedTime = 0  // isGameEnded
            
            // setProgress(progress)
            setStartedTime(startedTime)
            setLotteryBalance(web3.utils.fromWei(lotteryBalance))
            setWeeklyLotteryBalance(web3.utils.fromWei(weeklylotteryBalance))
            setMonthlyLotteryBalance(web3.utils.fromWei(monthlylotteryBalance))
            setLiquidityPoolBalance(web3.utils.fromWei(liquidityPoolBalance))
            setTicketPrice(web3.utils.fromWei(ticketPrice))
            setAccountPotValue(web3.utils.fromWei(accountPotValue))
            setTicketAmount(ticketAmount)
            setIsPotActive(isPotActive)
            setIsPotActiveW(isPotActiveW)
            setIsPotActiveM(isPotActiveM)
            setSelectReady(selectReady)
            setSelectReadyW(selectReadyW)
            setSelectReadyM(selectReadyM)
            setWinnerSelected(winnerSelected)
            setWinnerSelectedW(winnerSelectedW)
            setWinnerSelectedM(winnerSelectedM)
            setPlayers(players)
            setWinners(winners)
            setWinnersW(winnersW)
            setWinnersM(winnersM)
            setPlayerCount(playerCount)
            setLottery(lottery)
            setLotteryAddress(lotteryAddress)
            setWeeklyLottery(weeklylottery)
            setWeeklyLotteryAddress(weeklylotteryAddress)
            setMonthlyLottery(monthlylottery)
            setMonthlyLotteryAddress(monthlylotteryAddress)
            setOwner(owner)
            // setVerifier(verifier);
            setPotDirector(potDirector)
          } catch (e) {
            console.log('Error', e)
            console.log('Contracts not deployed to the current network')
          }
        } else {
          console.log('Non-Ethereum browser detected. You should consider trying Metamask!')
        }
      }
      // Load 
      loadBlockchainData()
    },[]);
  
    const loadContractData = async () => {
      // console.log(lottery)
      try {
        const lotteryBalance = await lottery.methods.balanceInPot().call()
        const weeklylotteryBalance = await weeklylottery.methods.balanceInPot().call()
        const monthlylotteryBalance = await monthlylottery.methods.balanceInPot().call()
        const liquidityPoolBalance = await liquidityPool.methods.balanceInPot().call()

        // let {accountPotCount, accountPotValue} = await lottery.methods.getPlayerAmounts().call()
        const accountPotValue = await lottery.methods.getPlayerValue(account).call()

        const ticketPrice = await lottery.methods.ticket_price().call()
        const isPotActive = await lottery.methods.isPotActive().call()
        const isPotActiveW = await weeklylottery.methods.isPotActive().call()
        const isPotActiveM = await monthlylottery.methods.isPotActive().call()
        const ticketAmount = await lottery.methods.getTicketAmount().call()
        const playerCount = await lottery.methods.getPlayersNumber().call()
        const players = await lottery.methods.listPlayers().call()
        const selectReady = await lottery.methods.isReadySelectWinner().call()
        const winnerSelected = await lottery.methods.isWinnerSelected().call()
        const selectReadyW = await weeklylottery.methods.isReadySelectWinner().call()
        const winnerSelectedW = await weeklylottery.methods.isWinnerSelected().call()
        const selectReadyM = await monthlylottery.methods.isReadySelectWinner().call()
        const winnerSelectedM = await monthlylottery.methods.isWinnerSelected().call()
        const startedTime = await lottery.methods.getStartedTime().call()
        // const progress = await lottery.methods.getPercent().call()
  
        // setProgress(progress)
        setStartedTime(startedTime)
        setLotteryBalance(web3.utils.fromWei(lotteryBalance))
        setWeeklyLotteryBalance(web3.utils.fromWei(weeklylotteryBalance))
        setMonthlyLotteryBalance(web3.utils.fromWei(monthlylotteryBalance))
        setLiquidityPoolBalance(web3.utils.fromWei(liquidityPoolBalance))
        setTicketPrice(web3.utils.fromWei(ticketPrice))
        setAccountPotValue(web3.utils.fromWei(accountPotValue))
        setTicketAmount(ticketAmount)
        setIsPotActive(isPotActive)
        setIsPotActiveW(isPotActiveW)
        setIsPotActiveM(isPotActiveM)
        setSelectReady(selectReady)
        setSelectReadyW(selectReadyW)
        setSelectReadyM(selectReadyM)
        setWinnerSelected(winnerSelected)
        setWinnerSelectedW(winnerSelectedW)
        setWinnerSelectedM(winnerSelectedM)
        setPlayers(players)
        setPlayerCount(playerCount)

      } catch (e) {
        console.log('Error', e)
        console.log('Contracts not deployed to the current network')
      }
    }
  
    const connectWallet = async() => {
      const isEnabled = await window.ethereum.enable();
      if(isEnabled) {
        const accounts = await web3.eth.getAccounts()   
  
        if(typeof accounts[0] !=='undefined'){
          const balance = await web3.eth.getBalance(accounts[0])
          setAccount(accounts[0])
          setAccountBalance(web3.utils.fromWei(balance))
        } else window.alert("something went wrong")
      } else {
        alert("Connection has been refused")
      }
      handleClose()
    }

    const setAddress = async(potDirector)=>{
      if(account == null || account === '') {
        handleShow();
        return;
      }
      
      if(lottery && lottery !== 'undefined') {
        try {
          await lottery.methods.setDirector(potDirector).send({from: account})
          await loadContractData()
        } catch (e) {
          console.log('Error, Set Address: ', e)
        }
      } else {
        alert("contract has not deployed yet.")
      }
    }

    const setAddressG = async(potDirector)=>{
      if(account == null || account === '') {
        handleShow();
        return;
      }
      
      if(lotteryGenerator && lotteryGenerator !== 'undefined') {
        try {
          await lotteryGenerator.methods.setDirector(potDirector).send({from: account})
          await loadContractData()
        } catch (e) {
          console.log('Error, Set Address: ', e)
        }
      } else {
        alert("contract has not deployed yet.")
      }
    }

    const setAddressW = async(potDirector)=>{
      if(account == null || account === '') {
        handleShow();
        return;
      }
      
      if(weeklylottery && weeklylottery !== 'undefined') {
        try {
          await weeklylottery.methods.setDirector(potDirector).send({from: account})
          await loadContractData()
        } catch (e) {
          console.log('Error, Set Address: ', e)
        }
      } else {
        alert("contract has not deployed yet.")
      }
    }

    const setAddressM = async(potDirector)=>{
      if(account == null || account === '') {
        handleShow();
        return;
      }
      
      if(monthlylottery && monthlylottery !== 'undefined') {
        try {
          await monthlylottery.methods.setDirector(potDirector).send({from: account})
          await loadContractData()
        } catch (e) {
          console.log('Error, Set Address: ', e)
        }
      } else {
        alert("contract has not deployed yet.")
      }
    }

    const buyTicket = async(amount, price)=>{
      if(account == null || account === '') {
        handleShow();
        return;
      }
      
      if(lottery && lottery !== 'undefined') {
        if (! isPotActive) {
          window.alert("Pot has not been started yet");
        } else {
          try {
            // var wei_price = ticketPrice * 10 ** 18
            // const buyApp = await lottery.methods.play().send({value: wei_price.toString(), from: account})
            var wei_price = amount * price * 10 ** 18
            const buyApp = await lottery.methods.play().send({value: wei_price, from: account})
            await loadContractData()
            console.log("--------------------")
            console.log(buyApp.events.PlayerRegister);
            console.log(buyApp.events.PlayerRegister.raw);
            console.log("--------------------")
            console.log(buyApp.events.PlayerRegister.returnValues);
            console.log(buyApp.events.PlayerRegister.returnValues[0]);
            console.log(buyApp.events.PlayerRegister.returnValues["potPlayer"]);
            console.log("--------------------")
          } catch (e) {
            console.log('Error, buy ticket: ', e)
          }
        }
      } else {
        alert("contract has not deployed yet.")
      }
    }
  
    const SelectWinner = async()=>{
      console.log("Winner Selection Process");
      if(account == null || account === '') {
        handleShow();
        return;
      }
  
      if(lottery && lottery !== 'undefined') {
        if(selectReady) {
          try {
            console.log("Winner Select Starts")
            // const gas = 0;
            // web3.eth.getGasPrice().then((result) => {
            //   console.log(web3.utils.fromWei(result, 'ether'));
            //   gas = result;
            //   });
            const gas = await lottery.methods.select_Winner().estimateGas({from: account})
            // console.log(gas);
            const result = await lottery.methods.select_Winner().send({from: account, gas:gas}); 
            await loadContractData()
            console.log("Winner is Starting to Select")
            console.log("--------------------")
          } catch (e) {
            console.log('Error, Select Winner : ', e)
          }
        } else {
          console.log("SelectReady is False")
        }
      } else {
        alert("contract has not deployed yet.")
      }
    }
  
    const SelectWinnerContinue = async()=>{
      console.log("Winner Selection Process Continue");
      if(account == null || account === '') {
        handleShow();
        return;
      }
  
      if(lottery && lottery !== 'undefined') {
        if(selectReady) {
          try {
            console.log("Winner Select Continues")
            // const gas = 0;
            // web3.eth.getGasPrice().then((result) => {
            //   console.log(web3.utils.fromWei(result, 'ether'));
            //   gas = result;
            //   });
            const gas = await lottery.methods.select_Winner_Continue().estimateGas({from: account})
            // console.log(gas);
            const result = await lottery.methods.select_Winner_Continue().send({from: account, gas:gas}); 
            await loadContractData()
            console.log("Winner Selected")
            console.log("--------------------")
            console.log(result.events.SelectWinnerIndex);
            console.log(result.events.SelectWinnerIndex.raw);
            console.log("--------------------")
            console.log(result.events.SelectWinnerIndex.returnValues);
            console.log(result.events.SelectWinnerIndex.returnValues[0]);
            console.log(result.events.SelectWinnerIndex.returnValues["winnerIndex"]);
            console.log("--------------------")
          } catch (e) {
            console.log('Error, Select Winner : ', e)
          }
        } else {
          console.log("SelectReady is False")
        }
      } else {
        alert("contract has not deployed yet.")
      }
    }
  
    const potInitialize = async()=>{
      console.log("Pot Initialization Process");
      if(account == null || account === '') {
        handleShow();
        return;
      }
  
      if(lottery && lottery !== 'undefined') {
        if(! isPotActive) {
          try {
            console.log("Pot Must be Started again !")
            // const gas = 0;
            // web3.eth.getGasPrice().then((result) => {
            //   console.log(web3.utils.fromWei(result, 'ether'));
            //   gas = result;
            //   });
            const gas = await lottery.methods.potInitialize().estimateGas({from: account})
            // console.log(gas);
            await lottery.methods.potInitialize().send({from: account, gas:gas}); 
            await loadContractData()
            console.log("Pot Initialized")
          } catch (e) {
            console.log('Error, Pot Initializing : ', e)
          }
        } else {
          console.log("Pot is Active !")
        }
      } else {
        alert("contract has not deployed yet.")
      }
    }

    const potInitializeW = async()=>{
      console.log("Weekly Pot Initialization Process");
      if(account == null || account === '') {
        handleShow();
        return;
      }
  
      if(weeklylottery && weeklylottery !== 'undefined') {
        if(! isPotActiveW) {
          try {
            console.log("Weekly Pot Must be Started again !")
            // const gas = 0;
            // web3.eth.getGasPrice().then((result) => {
            //   console.log(web3.utils.fromWei(result, 'ether'));
            //   gas = result;
            //   });
            const gas = await weeklylottery.methods.potInitialize().estimateGas({from: account})
            // console.log(gas);
            await weeklylottery.methods.potInitialize().send({from: account, gas:gas}); 
            await loadContractData()
            console.log("Weekly Pot Initialized")
          } catch (e) {
            console.log('Error, Weekly Pot Initializing : ', e)
          }
        } else {
          console.log("Weekly Pot is Active !")
        }
      } else {
        alert("contract has not deployed yet.")
      }
    }

    const potInitializeM = async()=>{
      console.log("Monthly Pot Initialization Process");
      if(account == null || account === '') {
        handleShow();
        return;
      }
  
      if(monthlylottery && monthlylottery !== 'undefined') {
        if(! isPotActiveM) {
          try {
            console.log("Monthly Pot Must be Started again !")
            // const gas = 0;
            // web3.eth.getGasPrice().then((result) => {
            //   console.log(web3.utils.fromWei(result, 'ether'));
            //   gas = result;
            //   });
            const gas = await monthlylottery.methods.potInitialize().estimateGas({from: account})
            // console.log(gas);
            await monthlylottery.methods.potInitialize().send({from: account, gas:gas}); 
            await loadContractData()
            console.log("Monthly Pot Initialized")
          } catch (e) {
            console.log('Error, Monthly Pot Initializing : ', e)
          }
        } else {
          console.log("Monthly Pot is Active !")
        }
      } else {
        alert("contract has not deployed yet.")
      }
    }

    const potPause = async()=>{
      console.log("Pot Pause Process");
      if(account == null || account === '') {
        handleShow();
        return;
      }
  
      if(lottery && lottery !== 'undefined') {
        if(isPotActive) {
          try {
            console.log("Pot Must be Stopped !")
            // const gas = 0;
            // web3.eth.getGasPrice().then((result) => {
            //   console.log(web3.utils.fromWei(result, 'ether'));
            //   gas = result;
            //   });
            const gas = await lottery.methods.potPause().estimateGas({from: account})
            // console.log(gas);
            await lottery.methods.potPause().send({from: account, gas:gas}); 
            await loadContractData()
            console.log("Pot Paused")
          } catch (e) {
            console.log('Error, Pot Pausing : ', e)
          }
        } else {
          console.log("Pot is not Active !")
        }
      } else {
        alert("contract has not deployed yet.")
      }
    }
    
    const potPauseW = async()=>{
      console.log("Weekly Pot Pause Process");
      if(account == null || account === '') {
        handleShow();
        return;
      }
  
      if(weeklylottery && weeklylottery !== 'undefined') {
        if(isPotActiveW) {
          try {
            console.log("Weekly Pot Must be Stopped !")
            // const gas = 0;
            // web3.eth.getGasPrice().then((result) => {
            //   console.log(web3.utils.fromWei(result, 'ether'));
            //   gas = result;
            //   });
            const gas = await weeklylottery.methods.potPause().estimateGas({from: account})
            // console.log(gas);
            await weeklylottery.methods.potPause().send({from: account, gas:gas}); 
            await loadContractData()
            console.log("Weekly Pot Paused")
          } catch (e) {
            console.log('Error, Weekly Pot Pausing : ', e)
          }
        } else {
          console.log("Weekly Pot is not Active !")
        }
      } else {
        alert("weekly contract has not deployed yet.")
      }
    }
    
    const potPauseM = async()=>{
      console.log("monthly Pot Pause Process");
      if(account == null || account === '') {
        handleShow();
        return;
      }
  
      if(monthlylottery && monthlylottery !== 'undefined') {
        if(isPotActiveM) {
          try {
            console.log("Monthly Pot Must be Stopped !")
            // const gas = 0;
            // web3.eth.getGasPrice().then((result) => {
            //   console.log(web3.utils.fromWei(result, 'ether'));
            //   gas = result;
            //   });
            const gas = await monthlylottery.methods.potPause().estimateGas({from: account})
            // console.log(gas);
            await monthlylottery.methods.potPause().send({from: account, gas:gas}); 
            await loadContractData()
            console.log("Monthly Pot Paused")
          } catch (e) {
            console.log('Error, Monthly Pot Pausing : ', e)
          }
        } else {
          console.log("Monthly Pot is not Active !")
        }
      } else {
        alert("Monthly contract has not deployed yet.")
      }
    }
    
    const createLottery = async (amount, price) => {
      if(account == null || account === '') {
        handleShow();
        return;
      }
  
      if(lottery && lottery !== 'undefined') {
        if(!owner || owner !== account) {
          window.alert("You have no access role")
          return;
        }
  
        if(isPotActive) {
          window.alert("Game is running now");
          return;
        }
  
        try {
          // console.log("create lottery : ", amount, price, account)
          var wei_price = web3.utils.toWei(price.toString(), 'Ether');
          // const initLottery = await lottery.methods.initialize(wei_price, amount).send({from: account})
          await loadContractData()
        } catch (e) {
          console.log('Error, creat ticket: ', e)
        }
      } else {
        alert("contract has not deployed yet.")
      }
    }
  
    const handleConnectCallBack = async() => {
      await connectWallet()
      await loadContractData()
    }
  
    const handleDisconnectCallBack = async() => {
      await web3.eth.accounts.wallet.clear();
      await loadContractData()
    }
  
    const handlePriceChange = (e) => {
      setFormPrice( e.target.value );
    }
  
    const handleAmountChange = (e) => {
      setFormAmount( e.target.value );
    }

    const handlePotDirectorChange = (e) => {
      setPotDirector( e.target.value );
    }

    const secondsToHms = (d) => {
      d = Number(d);
      var h = Math.floor(d / 3600);
      var m = Math.floor(d % 3600 / 60);
      var s = Math.floor(d % 3600 % 60);
  
      var hDisplay = h > 0 ? h + (h === 1 ? " hour, " : " hours, ") : "";
      var mDisplay = m > 0 ? m + (m === 1 ? " minute, " : " minutes, ") : "";
      var sDisplay = s > 0 ? s + (s === 1 ? " second" : " seconds") : "";
      return hDisplay + mDisplay + sDisplay; 
    }
  
    return (
      <>
        <Start 
          handleConnectCallBack={handleConnectCallBack} 
          account={account}
          handleDisconnectCallBack={handleDisconnectCallBack}
        />
        <Modal
          show={show}
          onHide={handleClose}
        >
          <Modal.Header>
            <Modal.Title>Welcome to our Lottery</Modal.Title>
          </Modal.Header>
          <Modal.Body>
            <img src={METAMAST_BASE64_URL} width="80px" height="80px" alt="meta mask icon"/>
            <p>Please connect your wallet on this site to enter the lottery.</p>
          </Modal.Body>
          <Modal.Footer >
            <Button variant="secondary" onClick={handleClose}>
              Skip it now
            </Button>
            <Button variant="primary" onClick={connectWallet}>Connect wallet</Button>
          </Modal.Footer>
        </Modal>
  
          <div style={{float: 'right'}}>
            <img src={MACHINE} alt="machine"/>
          </div>
        <Container>      
          <Row className="justify-content-md-center">
            <Col md="auto">
              <h4 style={{margin:'20px', color:"#0000CD"}}>Welcome to Lottery. Please enjoy the day here. ✌️</h4>
            </Col>
          </Row>
          <div>
            <img src={COIN1} alt="coin1"  style={{width: '40px', height: '40px'}}/>
            <i>Your Wallet Balance : <b style={{color: "#32CD32"}}>{accountBalance}</b> </i> 
            <i>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</i> 
            <i>Your Balance in This Pot : <b style={{color: "#32CD32"}}>{accountPotValue}</b> </i> 
            <br></br>
            <i>Owner : <b style={{color: "#4682B4"}}> {owner} </b> </i> 
            <i>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</i> 
            <i>Account : <b style={{color: "#4682B4"}}> <a href={currentNetwork+account}> {account} </a> </b> </i> <br></br>
            <i>Director : <b style={{color: "#4682B4"}}> {potDirector} </b> </i> 
            {/* <i>Verifier : <card style={{color: "#4682B4"}}> {verifier} </card> </i> <p></p> */}
          </div>
          
          {
            // owner === account ? 
              isPotActive ?
              <Card style={{marginTop:'10px', marginBottom:'10px'}}>
                <Card.Body>
                  <Card.Title style={{color: "#C70039"}}>Start a Chance in the current Pot</Card.Title>
                  <form 
                    className="form-inline row" 
                    onSubmit={(e) => {
                      e.preventDefault()
                      buyTicket(formAmount, formPrice)
                    //   createLottery(formAmount, formPrice)
                  }                      
                  }>
                    <div className="col-md-4">
                      <div className='form-group mb-2'>
                        <label htmlFor="price" className="sr-only">Ticket Price (BNB)</label>
                        <input
                          id='price'
                          step="0.01"
                          type='number'
                          className="form-control"
                          placeholder='price... ex: 0.01'
                          value={formPrice}
                          onChange={handlePriceChange}
                          required />
                      </div>
                      <div className='form-group mb-2'>
                        <label htmlFor="amount" className="sr-only">Deposit Amount</label>
                        <input
                          id='amount'
                          step="1"
                          type='number'
                          className="form-control"
                          placeholder='amount... ex: 1'
                          value={formAmount}
                          onChange={handleAmountChange}
                          required />
                      </div>
                      <Button variant="primary" type="submit">Deposit</Button>
                    </div>
                    <div className="col-md-5 text-center" style={{marginLeft:'300px', paddingTop:'20px', paddingLeft:'50px'}}>
                      <img src={COIN2} alt="coin2" className="icon2"/>
                    </div>
                    {/* <button type='submit' className='btn btn-primary'>DEPOSIT</button> */}
                  </form>
                  {/* <Button variant="primary" onClick={createLottery}>Create new Lottery</Button> */}
                </Card.Body>
              </Card>
              : selectReady ?
              <Card style={{marginTop:'50px', marginBottom:'50px'}}>
                <Card.Body>
                  <Card.Title>Game has been ended! Select the winner.</Card.Title>
                  <form 
                    className="form-inline" 
                    onSubmit={(e) => {
                      e.preventDefault()
                      SelectWinner()
                    }                      
                  }>
                    <Button variant="Warning" type="submit">Select Winner</Button>
                  </form>
                </Card.Body>
                <Card.Body>
                  <Card.Title>Game has been ended! Select the winner.</Card.Title>
                  <form 
                    className="form-inline" 
                    onSubmit={(e) => {
                      e.preventDefault()
                      SelectWinnerContinue()
                    }                      
                  }>
                    <Button variant="Warning" type="submit">Select Winner Continue</Button>
                  </form>
                </Card.Body>
              </Card>
              : <></>
            // : <></>
          }
          
          {
            owner === account ? 
              <Card style={{marginTop:'10px', marginBottom:'10px'}}>
                <Card.Body>
                  <Card.Title style={{color: "#C70039"}}>Main Setting for The Pots</Card.Title>
                  <form 
                    className="form-inline row" 
                    onSubmit={(e) => {
                      e.preventDefault()
                      setAddressG(potDirector)
                  }                      
                  }>
                    <div className="col-md-8">
                      <div className='form-group mb-2'>
                        <label htmlFor="potDirector" className="sr-only">Set Pot Director Address</label>
                        <input
                          id='potDirector'
                          type='string'
                          className="form-control"
                          placeholder='Pot Director Address'
                          value={potDirector}
                          onChange={handlePotDirectorChange}
                          required />
                      </div>
                      <Button variant="success" type="submit">Set PotGenerator Director</Button> &emsp;
                      <Button variant="success" onClick={() => setAddress(potDirector)}>Set Hourly Director</Button> &emsp;
                      <Button variant="success" onClick={() => setAddressW(potDirector)}>Set Weekly Director</Button> &emsp;
                      <Button variant="success" onClick={() => setAddressM(potDirector)}>Set Monthly Director</Button> 
                    </div>
                  </form>
                </Card.Body>
              </Card>
            : <></>
          }

          {/* <ProgressBar max={100} now={progress} label={`${progress}%`} animated srOnly/> */}
          <Card>
            <Card.Body className="row">
              <Card.Title style={{color: "#C70039"}}>Current Lottery Room : <a href={currentNetwork+lotteryAddress}>{lotteryAddress}</a></Card.Title>
              {/* <Card.Title style={{color: "#C70039"}}>Current Lottery Room : {lotteryAddress}</Card.Title> */}
              <div className="col-md-7">
              {
                  isPotActive ?
                    selectReady ?
                        <Card.Text> 
                            <i><small>Pot is Active and Ready for Select the Winner</small></i> <br></br>
                            <i><small>HourlyPot Started at : {startedTime === '0'? "0s" : secondsToHms(startedTime)} </small></i>
                        </Card.Text>
                    :
                        <Card.Text>
                            <i><small>Pot is Active But not fill enough for Selecting the Winner</small></i> <br></br>
                            <i><small>HourlyPot Started at : {startedTime === '0'? "0s" : secondsToHms(startedTime)} </small></i>
                        </Card.Text>
                  : 
                    <Card.Text>
                        <i><small>Pot is Finished</small></i> <br></br>
                    </Card.Text>
              }
              <Card.Text>
                Current Pot balance : <b> { lotteryBalance } </b>  &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;  Total Ticket bought : <b> { ticketAmount } </b> <br></br>
                Current Weekly Pot balance : <b> { weeklylotteryBalance } </b> &emsp;&emsp; Current Monthly Pot balance : <b> { monthlylotteryBalance } </b> <br></br>
                Current LiquidityPool balance : <b> { liquidityPoolBalance } </b> <br></br> 
              </Card.Text>
              <Card.Text>
                Please buy more more than one ticket with <b> {ticketPrice} BNB</b> and increase the chance to be a winner!
              </Card.Text>
              {/* {
                ! isPotActive || selectReady ? 
                <div>
                  <p>Lottery round has not been started newly</p>
                  <Button variant="primary" disabled>Buy Ticket</Button>
                </div>
                : <Button variant="primary" onClick={buyTicket}>Buy Ticket</Button>
              } */}
              {/* <Card.Text>
                  Owner : { owner }
              </Card.Text>
              <Card.Text>
                  Account : { account }
              </Card.Text> */}
              { (owner === account || potDirector === account) ? 
                  (isPotActive) ? 
                      <Button variant="danger" onClick={potPause}>Stop the HourlyPot</Button> 
                  : ! isPotActive ?
                      <Button variant="warning" onClick={potInitialize}>Start New HourlyPot</Button>
                  : <></> 
                : <></>
              }
              &emsp;&emsp;
              { (owner === account || potDirector === account) ? 
                  (isPotActiveW) ? 
                      <Button variant="danger" onClick={potPauseW}>Stop the WeeklyPot</Button> 
                  : ! isPotActiveW ?
                      <Button variant="warning" onClick={potInitializeW}>Start New WeeklyPot</Button>
                  : <></> 
                : <></>
              }
              &emsp;&emsp; 
              { (owner === account || potDirector === account) ? 
                  (isPotActiveM) ? 
                      <Button variant="danger" onClick={potPauseM}>Stop the MonthlyPot</Button> 
                  : ! isPotActiveM ?
                      <Button variant="warning" onClick={potInitializeM}>Start New MonthlyPot</Button>
                  : <></> 
                : <></>
              }
              <br></br> <br></br>
              { (owner === account || potDirector === account) ? 
                  (isPotActive && selectReady) ?
                      (! winnerSelected) ?
                          <Button variant="warning" onClick={SelectWinner}>Select a Winner</Button>
                      : 
                          <Button variant="danger" onClick={SelectWinnerContinue}>Select a Winner Continue</Button>
                  : <></> 
                : <></>
              }
              </div>
              <div className="col-md-5" style={{paddingLeft:'30px', paddingTop: '30px'}}>
                <img src={COIN3} alt="icon3" className="icon3"/>
              </div>
            </Card.Body>
          </Card>
  
          {/* Current Player */}
  
          <Row style={{marginTop: '50px'}}>
            <Col md="6">
              Current Players : {playerCount}
              <Table responsive>
                <tbody>
                  {
                    players.map((player, idx) => {
                      return (
                        <tr key={idx}>
                          <td>{idx+1}</td>
                          <td style={{color: "#4682B4"}}>{player}</td>
                        </tr>
                      )
                    })    
                  }
                </tbody>
              </Table>
            </Col>
            <Col md="6">
              Previous winners
              <Table responsive>
                <tbody>
                  {
                    winners.map((winner, idx) => {
                      return (
                        <tr key={idx}>
                          <td>{idx+1}</td>
                          <td style={{color: "#4682B4"}}>{winner}</td>
                        </tr>
                      )
                    })    
                  }
                </tbody>
              </Table>
            </Col>
          </Row>

          <Row style={{marginTop: '50px'}}>
            <Col md="6">
              Weekly Winners : 
              <Table responsive>
                <tbody>
                  {
                    winnersW.map((winner, idx) => {
                      return (
                        <tr key={idx}>
                          <td>{idx+1}</td>
                          <td style={{color: "#4682B4"}}>{winner}</td>
                        </tr>
                      )
                    })    
                  }
                </tbody>
              </Table>
            </Col>
            <Col md="6">
              Monthly winners
              <Table responsive>
                <tbody>
                  {
                    winnersM.map((winner, idx) => {
                      return (
                        <tr key={idx}>
                          <td>{idx+1}</td>
                          <td style={{color: "#4682B4"}}>{winner}</td>
                        </tr>
                      )
                    })    
                  }
                </tbody>
              </Table>
            </Col>
          </Row>

        </Container>
      </>
    );
}
  
export default App;

