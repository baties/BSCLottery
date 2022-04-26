import React, {Component, useLayoutEffect, useEffect, useState} from 'react';
import { Container, Row, Col, FormControl, InputGroup, Button } from 'react-bootstrap';
import './App.css';
// import Web3 from "web3";

import web3 from './web3';
import LotteryContract from './lottery';
// import { LotteryCore } from './ABI/LotteryCore';

/* --------------------------------------------------- */
// const web3 = new Web3(window.ethereum.currentProvider);
/* --------------------------------------------------- */

// const contractAddress = "0x6e6D6E924A1900E3033476058F4d8F98aC8f55A9"

/* --------------------------------------------------- */
// const lottery_json = require("./contracts/LotteryCore.json");
// // const lottery_json = require("./ABI/LotteryCore.js");
// const abi = lottery_json["abi"];
// const contractAddress = lottery_json["networks"]["4"]["address"];
// const lottery = new web3.eth.Contract(abi, contractAddress);  // , {from: contractAddress}
/* --------------------------------------------------- */
var contractAddress = LotteryContract.contractAddress;
console.log("Contract Address is : " + contractAddress);
contractAddress = "0x6e6D6E924A1900E3033476058F4d8F98aC8f55A9"
/* --------------------------------------------------- */


// LotteryContract.setProvider(`wss://rinkeby.infura.io/ws/v3/${process.env.REACT_APP_INFURA_PROJECT_ID}`);

class App extends Component {

  constructor(props) {
    super(props);
    this.state = {
      owner: '',
      players: [],
      balance: '',
      value: '',
      message: '...',
      account: '',
      generator: '',
      winner: ''
      };
    this.value = React.createRef();
  }

  render() {
    return (
      <div className="LotteryContract">

        <h2> Lottery SmartContract  </h2>

        <div className="form-row">
          <div className="col xs = {12}">
            <p> My Account: {this.state.account} </p>
            <br></br>
            <p> Contract Address Account: 
            <a
              className="App-link"
              href="https://rinkeby.etherscan.io/address/0x7dF37cb452fF9eda678ff666189742194B19612E"
              target="_blank"
              rel="noopener noreferrer"
            >
              {contractAddress}
            </a>
            </p>
          </div>
        </div>
        <>

        <p>
          This lottery is managed by {this.state.owner}.<br /> There are currently{' '}
          {this.state.players.length} players, competing to win{' '}
          {web3.utils.fromWei(this.state.balance, 'ether')} ether!
        </p>

        <br></br>
        <br></br>

        <Container>

          <Row>
            <InputGroup className="mb-1">
              <FormControl
                ref={this.state.value}
                placeholder="Value to Play"
                aria-label="Value To Play"
                aria-describedby="basic-addon1"
                value={this.state.value}
                onChange={event => this.setState({ value: event.target.value })}
                />
              <Button variant="primary" id="button-addon1" onClick={this.onSubmit}>
                Play</Button>
                <br></br>
            </InputGroup>
          </Row>
          <br></br>

          <form onSubmit={this.onSubmit}>
            <h4>Want to try your luck?</h4>
            <div>
              <label>Amount of ether to enter</label>
              <input
                value={this.state.value}
                onChange={event => this.setState({ value: event.target.value })}
              />
            </div>
            <Button variant="primary" id="button-addon2" onClick={this.onSubmit}>
                Play</Button>
          </form>

          <br></br>

          <form 
              className="form-inline row" 
              onSubmit={this.onSubmit}>
              <div className="col-md-7">
                <div className='form-group mb-2'>
                  <label htmlFor="price" className="sr-only">Ticket Price (BNB)</label>
                  <input
                    id='price'
                    step="0.01"
                    type='number'
                    className="form-control"
                    placeholder='price... ex: 0.01'
                    value={this.state.value}
                    // onChange={this.handlePriceChange}
                    onChange={event => this.setState({ value: event.target.value })}
                    required />
                </div>
                {/*<Button variant="primary" type="submit">Create new Lottery</Button>*/}
                <button type='submit' className='btn btn-primary'>DEPOSIT</button> 
              </div>
              <div className="col-md-5 text-center" style={{paddingTop:'20px'}}>
                {/* <img src={COIN2} alt="coin2" className="icon2"/> */}
              </div>
              {/* <button type='submit' className='btn btn-primary'>DEPOSIT</button> */}
           </form>



          <br></br>

          <Row>
            <InputGroup className="mb-3">
              <FormControl
                ref={this.state.generator}
                placeholder="Address to Set"
                aria-label="Address to Set"
                aria-describedby="basic-addon3"
                value={this.state.generator}
                onChange={event => this.setState({ generator: event.target.value })}
              />
              <Button variant="secondary" id="button-addon3" onClick={this.setAddress}>
                Set Address</Button>
                <br></br>
            </InputGroup>
          </Row>

          <br></br>

          <Row>
            <br></br>
            <Col><Button variant="success" onClick={this.getValue}>Retrieve</Button>{' '}</Col>
            <Col>The Lottery Pot Value is: {web3.utils.fromWei(this.state.balance, 'ether')}</Col>
          </Row>

          <br></br>

          <Row>
            <br></br>
            <Col><Button variant="success" onClick={this.getPlayerList}>PlayerList</Button>{' '}</Col>
            <Col>The Lottery Players are: {this.state.players}</Col>
          </Row>

          <br></br>

          <Row>
            <br></br>
            <Col><Button variant="warning" onClick={this.onClick}>SelectWinner</Button>{' '}</Col>
            <Col>The Lottery Winner is: {this.state.winner}</Col>
          </Row>

        </Container>

        <h1>{this.state.message}</h1>

        </>
      </div>
    );
  }

  componentDidMount = async (t) => {

    // const accounts = await window.ethereum.enable();

    // if (window.ethereum) {
    //   try {
    //     const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
    //     setAccounts(accounts);
    //   } catch (error) {
    //     if (error.code === 4001) {
    //       // User rejected request
    //     }
    //     setError(error);
    //   }
    // }
    
    // const [formPrice, setFormPrice] = useState(0.01)

    const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
    const account = accounts[0];
    this.setState({ account: account });

    console.log("Current Attached Account is : " + account);

    // LotteryContract.manager.call((error, result) => {
    //   if(!error){
    //     this.setState({ manager: result });
    //   } else{
    //       console.log(error);
    //   }
    // });
  
    // web3.eth.getBalance(LotteryContract.contractAddress, (error, result) => {
    //   if(!error){
    //     this.setState({ balance: result.toNumber()});
    //   } else {
    //       console.log(error);
    //     }
    // });

    
    // LotteryContract.listPlayers.call((error, result) => {
    //   if(!error){
    //     this.setState({ players: result });
    //   } else {
    //       console.log(error);
    //     }
    // });

    
  };
  
  // handlePriceChange = (t) => {
  //   this.state.value = t.target.value;
  // }

  getValue = async (t) => {
    const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
    const account = accounts[0];    
    const result = await LotteryContract.methods.balanceInPot().call({
      from: account, // this.state.account,
    });
    this.setState({ balance: result });  // .toNumber()
  }

  getPlayerList = async (t) => {
    t.preventDefault();
    const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
    const account = accounts[0];    
    const result = await LotteryContract.methods.listPlayers().call({
      from: account, // this.state.account,
    });
    this.setState({ players: result });
  }

  setAddress = async (t) => {
    t.preventDefault();
    const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
    const account = accounts[0];    
    this.setState({ message: 'Waiting on transaction success...'});
    const address = this.state.generator;
    const gas = await LotteryContract.methods.generatorLotteryAddress(address).estimateGas({
      from: account
    });
    const result = await LotteryContract.methods.generatorLotteryAddress(address).send({
      from: account, //this.state.account,
      gas,
    });
    console.log(result);
  }


  // onSubmit = event => {
  onSubmit = async(t) => {
    t.preventDefault();
    // event.preventDefault();
    // const account = web3.eth.accounts[0];
    // const accounts = await window.ethereum.enable();
    const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
    const account = accounts[0];
    // console.log("Player Account is : " + account);
    // console.log("Value is : " + this.state.value.toString());
    this.setState({ message: 'Waiting on transaction success...'});
    const gas = await LotteryContract.methods.play().estimateGas({
      from: account,
      value: web3.utils.toBN(this.state.value * 1e18)   // web3.utils.toWei(this.state.value, 'ether')
    });
    // console.log("gas is : " + gas);
    // console.log("real value is : " + (web3.utils.toBN(this.state.value * 1e18)))

    LotteryContract.methods.play().send({
      from: account,
      // from: web3.toChecksumAddress(account.address),
      gas:gas,
      value: web3.utils.toBN(this.state.value * 1e18)   // web3.utils.toWei(this.state.value, 'ether')
    }, (error, result) => { 
      if(!error) {
        console.log("Okay!");
        this.setState({ message: 'You have been entered!' });
      } else {
          console.log("Error : " + String(error));
          this.setState({ message: String(error) });
      }    
    })

    // const network = process.env.REACT_APP_ETHEREUM_NETWORK;
    // // Creating a signing account from a private key
    // const signer = web3.eth.accounts.privateKeyToAccount(
    //   process.env.REACT_APP_SIGNER_PRIVATE_KEY
    // );
    // web3.eth.accounts.wallet.add(signer);
    // // Creating the transaction object
    // const tx = {
    //   from: signer.address,
    //   to: contractAddress,
    //   value: web3.utils.toWei(this.state.value.toString()),
    // };
    // // Assigning the right amount of gas
    // tx.gas = await web3.eth.estimateGas(tx);

    // // Sending the transaction to the network
    // const receipt = await web3.eth
    //   .sendTransaction(tx)
    //   .once("transactionHash", (txhash) => {
    //     console.log(`Mining transaction ...`);
    //     console.log(`https://${network}.etherscan.io/tx/${txhash}`);
    //   });
    // // The transaction is now on chain!
    // console.log(`Mined in block ${receipt.blockNumber}`);

  };

  onClick = async(t) => {
    t.preventDefault();
    // const account = web3.eth.accounts[0];
    // const accounts = await window.ethereum.enable();
    const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
    const account = accounts[0];

    this.setState({ message: 'Waiting for transaction success...'});
    const gas = await LotteryContract.methods.select_Winner().estimateGas({
      from: account,
      value: web3.utils.toBN(this.state.value * 1e18)   // web3.utils.toWei(this.state.value, 'ether')
    });

    LotteryContract.select_Winner({
      from: account,
      // from: web3.toChecksumAddress(account.address)
      gas:gas
    }, (error, result) => {
      if(!error) {
        console.log("Okay!");
        this.setState({ message: 'A winner has been picked!' });
      } else {
        console.log("Error : " + String(error));
        this.setState({ message: String(error)});
        }
    })

  };

}

export default App;

