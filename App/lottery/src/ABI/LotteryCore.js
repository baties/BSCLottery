export const LotteryCore = [
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "VRF",
          "type": "address"
        }
      ],
      "stateMutability": "nonpayable",
      "type": "constructor"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": true,
          "internalType": "address",
          "name": "previousOwner",
          "type": "address"
        },
        {
          "indexed": true,
          "internalType": "address",
          "name": "newOwner",
          "type": "address"
        }
      ],
      "name": "OwnershipTransferred",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": false,
          "internalType": "address",
          "name": "potPlayer",
          "type": "address"
        },
        {
          "indexed": false,
          "internalType": "uint256[]",
          "name": "playerId",
          "type": "uint256[]"
        },
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "playCount",
          "type": "uint256"
        },
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "playerValue",
          "type": "uint256"
        },
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "ticketNumber",
          "type": "uint256"
        }
      ],
      "name": "PlayeTotalValue",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": false,
          "internalType": "address",
          "name": "potPlayer",
          "type": "address"
        },
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "playerId",
          "type": "uint256"
        },
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "PlayerValue",
          "type": "uint256"
        },
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "ticketNumber",
          "type": "uint256"
        }
      ],
      "name": "PlayerRegister",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": false,
          "internalType": "address",
          "name": "potWinner",
          "type": "address"
        },
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "winnerPrize",
          "type": "uint256"
        }
      ],
      "name": "SelectWinnerAddress",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "winnerIndex",
          "type": "uint256"
        },
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "potBalance",
          "type": "uint256"
        },
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "winnerPrize",
          "type": "uint256"
        }
      ],
      "name": "SelectWinnerIndex",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": false,
          "internalType": "address",
          "name": "receiver",
          "type": "address"
        },
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "TrxValue",
          "type": "uint256"
        }
      ],
      "name": "TotalPayment",
      "type": "event"
    },
    {
      "stateMutability": "payable",
      "type": "fallback"
    },
    {
      "inputs": [],
      "name": "WeeklyPotAddress",
      "outputs": [
        {
          "internalType": "address",
          "name": "",
          "type": "address"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "owner",
      "outputs": [
        {
          "internalType": "address",
          "name": "",
          "type": "address"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "renounceOwnership",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "newOwner",
          "type": "address"
        }
      ],
      "name": "transferOwnership",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "stateMutability": "payable",
      "type": "receive"
    },
    {
      "inputs": [],
      "name": "balanceInPot",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "withdraw",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "numerator",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "denominator",
          "type": "uint256"
        }
      ],
      "name": "getDivided",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "quotient",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "remainder",
          "type": "uint256"
        }
      ],
      "stateMutability": "pure",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "play",
      "outputs": [],
      "stateMutability": "payable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "_VRFv2",
          "type": "address"
        }
      ],
      "name": "getRandomValue",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "randomWords",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "select_Winner",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "_WeeklyPotAddress",
          "type": "address"
        }
      ],
      "name": "set_WeeklyPotAddress",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "listPlayers",
      "outputs": [
        {
          "internalType": "address[]",
          "name": "",
          "type": "address[]"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "getLotteryTickets",
      "outputs": [
        {
          "internalType": "uint256[]",
          "name": "",
          "type": "uint256[]"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "_contractAddr",
          "type": "address"
        }
      ],
      "name": "generatorLotteryAddress",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    }
  ];
