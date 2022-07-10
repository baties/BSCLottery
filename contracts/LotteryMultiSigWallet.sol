// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract MultiSigWallet {
    event Deposit(address indexed sender, uint amount, uint balance);
    event SubmitTransaction(address indexed owner, uint indexed txIndex, address indexed to, uint value, bytes data);
    event ConfirmTransaction(address indexed owner, uint indexed txIndex);
    event RevokeConfirmation(address indexed owner, uint indexed txIndex);
    event ExecuteTransaction(address indexed owner, uint indexed txIndex);

    address[] public owners;
    address private firstOwner;
    mapping(address => bool) public isOwner;
    uint public numConfirmationsRequired;
    //bool private firstOwnerConfirmation;

    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
        uint numConfirmations;
        bool firstOwnerConfirm;
    }

    // mapping from tx index => owner => bool
    mapping(uint => mapping(address => bool)) public isConfirmed;

    Transaction[] public transactions;

    modifier onlyFirstOwner() {
        require(msg.sender == firstOwner , "not First Owner");
        _;
    }

    modifier onlyOwner() {
        require((isOwner[msg.sender] || msg.sender == firstOwner), "Sender is not an Owner");
        _;
    }

    modifier txExists(uint _txIndex) {
        require(_txIndex < transactions.length, "tx does not exist");
        _;
    }

    modifier notExecuted(uint _txIndex) {
        require(!transactions[_txIndex].executed, "tx already executed");
        _;
    }

    modifier notConfirmed(uint _txIndex) {
        require(!isConfirmed[_txIndex][msg.sender], "tx already confirmed");
        _;
    }

    constructor(address[] memory _owners, uint _numConfirmationsRequired) {
        require(_owners.length > 0, "owners required");
        require(
            _numConfirmationsRequired > 0 &&
                _numConfirmationsRequired <= _owners.length,
            "invalid number of required confirmations"
        );

        firstOwner =  msg.sender;

        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];

            require(owner != address(0), "invalid owner");
            require(!isOwner[owner], "owner not unique");
            require(owner != firstOwner, "none of the owners can be the same as firstOwner");

            isOwner[owner] = true;
            owners.push(owner);
        }

        numConfirmationsRequired = _numConfirmationsRequired;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    function submitTransaction(
        address _to,
        uint _value,
        bytes memory _data
    ) public onlyOwner {
        uint txIndex = transactions.length;

        transactions.push(
            Transaction({
                to: _to,
                value: _value,
                data: _data,
                executed: false,
                numConfirmations: 0,
                firstOwnerConfirm: false
            })
        );

        emit SubmitTransaction(msg.sender, txIndex, _to, _value, _data);
    }

    function confirmTransaction(uint _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
        notConfirmed(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];
        if (msg.sender == firstOwner) {
            transaction.firstOwnerConfirm = true;
        } else {
            transaction.numConfirmations += 1;
            isConfirmed[_txIndex][msg.sender] = true;
        }

        emit ConfirmTransaction(msg.sender, _txIndex);
    }

    function executeTransaction(uint _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];

        require(transaction.numConfirmations >= numConfirmationsRequired, "cannot execute tx");
        require(transaction.firstOwnerConfirm == true, "First Owner has not confirmed this TX yet");

        transaction.executed = true;

        (bool success, ) = transaction.to.call{value: transaction.value}(
            transaction.data
        );
        require(success, "tx failed");

        emit ExecuteTransaction(msg.sender, _txIndex);
    }

    function revokeConfirmation(uint _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];

        if (msg.sender == firstOwner) {
            require(transaction.firstOwnerConfirm, "tx not confirmed by firstOwner");
            transaction.firstOwnerConfirm = false;
        } else {
            require(isConfirmed[_txIndex][msg.sender], "tx not confirmed");
            transaction.numConfirmations -= 1;
            isConfirmed[_txIndex][msg.sender] = false;
        }

        emit RevokeConfirmation(msg.sender, _txIndex);
    }

    function getOwners() public view returns (address[] memory) {
        return owners;
    }

    function getMainOwner() public view returns (address) {
        return firstOwner;
    }

    function getTransactionCount() public view returns (uint) {
        return transactions.length;
    }

    function getTransaction(uint _txIndex)
        public
        view
        returns (
            address to,
            uint value,
            bytes memory data,
            bool executed,
            uint numConfirmations,
            bool firstOwnerConfirm
        )
    {
        Transaction storage transaction = transactions[_txIndex];

        return (
            transaction.to,
            transaction.value,
            transaction.data,
            transaction.executed,
            transaction.numConfirmations,
            transaction.firstOwnerConfirm
        );
    }

    function isConfirmedByAddress(uint _txIndex, address _owner)
        public
        view
        returns (bool)
    {
        bool returnValue = false;
        Transaction storage transaction = transactions[_txIndex];

        if (_owner == firstOwner) {
            returnValue = transaction.firstOwnerConfirm;
        } else {
            returnValue = isConfirmed[_txIndex][_owner];
        }

        return returnValue;
    }

    function deposit() public payable{
        require(msg.value != 0);
        require(msg.sender != address(0));
        // address(this).balance += msg.value;
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

}
