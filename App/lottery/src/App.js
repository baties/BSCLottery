// import React, {Component, useLayoutEffect} from 'react';
import React, {Component} from 'react';
// import { Container, Row, Col, FormControl, InputGroup, Button } from 'react-bootstrap';
import './App.css';
import web3 from './web3';
// import web3 from "web3";
import lottery from './lottery';
// import { LotteryCore } from './ABI/LotteryCore';

class App extends Component {

  constructor(props) {
    super(props);
    this.state = {
      owner: '',
      players: [],
      balance: '',
      value: '',
      message: '...',
      account: ''
      };
    this.value = React.createRef();
  }

  render() {
    return (
      <div>
        <h2>Lottery Contract</h2>
        <p>
          This lottery is managed by {this.state.owner}.<br /> There are currently{' '}
          {this.state.players.length} players, competing to win{' '}
          {web3.utils.fromWei(this.state.balance, 'ether')} ether!
        </p>
        <form onSubmit={this.onSubmit}>
          <h4>Want to try your luck?</h4>
          <div>
            <label>Amount of ether to enter</label>
            <input
              value={this.state.value}
              onChange={event => this.setState({ value: event.target.value })}
            />
          </div>
          <button>Enter</button>
        </form>
        <h4>Ready to pick a Winner?</h4>
        <button onClick={this.onClick}>Pick a Winner!</button>
        <h1>{this.state.message}</h1>
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

    const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
    const account = accounts[0];
    this.setState({ account: account });

    // lottery.manager.call((error, result) => {
    //   if(!error){
    //     this.setState({ manager: result });
    //   } else{
    //       console.log(error);
    //   }
    // });
  
    // web3.eth.getBalance(lottery.contractAddress, (error, result) => {
    //   if(!error){
    //     this.setState({ balance: result.toNumber()});
    //   } else {
    //       console.log(error);
    //     }
    // });
    var getValue = async (t) => {
      // const accounts = await window.ethereum.enable();
      // const account = accounts[0];    
      const result = await lottery.methods.balanceInPot().call({
        from: account, // this.state.account,
      });
      this.setState({ balance: result.toNumber() });
    }
    
    // lottery.listPlayers.call((error, result) => {
    //   if(!error){
    //     this.setState({ players: result });
    //   } else {
    //       console.log(error);
    //     }
    // });
    var getPlayerList = async (t) => {
      // const accounts = await window.ethereum.enable();
      // const account = accounts[0];    
      const result = await lottery.methods.listPlayers().call({
        from: account, // this.state.account,
      });
      this.setState({ players: result });
    }
  
  };
  
  // onSubmit = event => {
  onSubmit = async(t) => {
    // event.preventDefault();
    // const account = web3.eth.accounts[0];
    // const accounts = await window.ethereum.enable();
    const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
    const account = accounts[0];

    this.setState({ message: 'Waiting on transaction success...'});
    lottery.play({
      from: account,
      // from: web3.toChecksumAddress(account.address),
      value: web3.toWei(this.state.value, 'ether')
    }, (error, result) => { 
      if(!error) {
        this.setState({ message: 'You have been entered!' });
      } else {
          this.setState({ message: String(error) });
      }    
    })

  };

  onClick = async(t) => {
    // const account = web3.eth.accounts[0];
    // const accounts = await window.ethereum.enable();
    const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
    const account = accounts[0];

    this.setState({ message: 'Waiting for transaction success...'});
    lottery.select_Winner({
      from: account
      // from: web3.toChecksumAddress(account.address)
    }, (error, result) => {
      if(!error) {
        this.setState({ message: 'A winner has been picked!' });
      } else {
          this.setState({ message: String(error)});
        }
    })

  };

}

export default App;

