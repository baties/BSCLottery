import React, { Component } from "react";
import { Container, Row, Col, FormControl, InputGroup, Button } from 'react-bootstrap';
import Web3 from "web3";

import { LotteryCore } from './ABI/LotteryCore'

const web3 = new Web3(Web3.givenProvider);

const contractAddress = "0x7dF37cb452fF9eda678ff666189742194B19612E"
const weeklyContractAddress = "0x7D20FFdb9be85530885e0de29a7fA9033F266E35"
const monthlyContractAddress = "0x60E61BfB3a06940962E0FBa179e92eD39B437707"
const ContractGeneratorAddress = "0x1D237c0181A1f62B106043c0B6c787Cfad6E562D"

const LotteryContract = new web3.eth.Contract(LotteryCore, contractAddress);

class App extends Component {

  constructor(props) {
    super(props);
    this.state = {
      potValue: 0,
      account: null
    };
    this.value = React.createRef();
  }

  componentDidMount = async (t) => {
    const accounts = await window.ethereum.enable();
    const account = accounts[0];
    this.setState({ account: account });
  }

  getValue = async (t) => {
    const accounts = await window.ethereum.enable();
    const account = accounts[0];    
    const result = await LotteryContract.methods.balanceInPot().call({
      from: account, // this.state.account,
    });
    this.setState({ potValue: result });
  }

  setValue = async (t) => {
    const accounts = await window.ethereum.enable();
    const account = accounts[0];    
    const address = contractAddress;
    const gas = await LotteryContract.methods.generatorLotteryAddress(address).estimateGas();
    const result = await LotteryContract.methods.generatorLotteryAddress(address).send({
      from: account,   // this.state.account,
      gas,
    });
  }

  render() {
    return (
      <div className="LotteryContract">

        <h2> Lottery SmartContract  </h2>
        <h2> ---------------------  </h2>
        <div class="form-row">
          <div class="col xs = {12}">
            <h7> My Account: {this.state.account} </h7>
          </div>
        </div>
        <>

          <br></br>
          <br></br>
          <br></br>
          <br></br>
          <Container>

            <Row>
              <InputGroup className="mb-3">
                <FormControl
                  ref={this.value}
                  placeholder="Address to Set"
                  aria-label="Address to Set"
                  aria-describedby="basic-addon2"
                />
                <Button variant="secondary" id="button-addon2" onClick={this.setValue}>
                  Set Address</Button>
              </InputGroup>
            </Row>

            <Row>
              <Col><Button variant="success" onClick={this.getValue}>Retrieve</Button>{' '}</Col>
              <Col>The Lottery Pot Value is: {this.state.potValue}
              </Col>
            </Row>

          </Container>
        </>
      </div>
    )
  }
}
export default App;

