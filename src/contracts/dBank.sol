// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

import "./Token.sol";

contract dBank {
    //Token contract to variable
    Token private token;

    //mappings
    mapping(address => uint256) public etherBalanceOf;
    mapping(address => uint256) public depositStart;
    mapping(address => bool) public isDeposited;

    //events
    event Deposit(address indexed user, uint256 etherAmount, uint256 timeStart);
    event Withdraw(address indexed user, uint256 etherAmount, uint256 depositTime, uint256 interest);

    //pass as constructor argument deployed Token contract
    constructor(Token _token) public {
        //deployed token contract to variable
        token = _token;
    }

    function deposit() public payable {
        //check if msg.sender didn't already deposited funds
        require(isDeposited[msg.sender] == false, "Error, deposit already active");
        //check if msg.value is >= than 0.01 ETH=(1e16 or 10**16)
        require(msg.value >= 10**16, "Error, deposti must be >= 0.01 ETH");

        //increase msg.sender ether deposit balance
        etherBalanceOf[msg.sender] = etherBalanceOf[msg.sender] + msg.value;
        //start msg.sender hodling time
        depositStart[msg.sender] = depositStart[msg.sender] + block.timestamp;

        //set msg.sender deposit status to true
        isDeposited[msg.sender] = true;
        //emit Deposit event
        emit Deposit(msg.sender, msg.value, block.timestamp);
    }

    function withdraw() public {
        //check if msg.sender deposit status is true
        require(isDeposited[msg.sender] == true, "Error, no previous deposit");
        //msg.sender ether deposit balance to variable for event
        uint256 userBalance = etherBalanceOf[msg.sender];

        //check user's hodl time
        uint256 depositTime = block.timestamp - depositStart[msg.sender];
        //calc interest per second and calc accrued interest
        //31668017 - interest(10% APY) per second for min. deposit amount (0.01 ETH), cuz:
        //1e15(10% of 0.01 ETH) / 31577600 (seconds in 365.25 days)

        //(etherBalanceOf[msg.sender] / 1e16) - calc. how much higher interest will be (based on deposit), e.g.:
        //for min. deposit (0.01 ETH), (etherBalanceOf[msg.sender] / 1e16) = 1 (the same, 31668017/s)
        //for deposit 0.02 ETH, (etherBalanceOf[msg.sender] / 1e16) = 2 (doubled, (2*31668017)/s)
        uint256 interestPerSecond = 31668017 * (etherBalanceOf[msg.sender] / 1e16);
        uint256 interest = interestPerSecond * depositTime;

        //send eth to user
        msg.sender.transfer(userBalance);
        //send interest in tokens to user
        token.mint(msg.sender, interest);
        //reset depositer data
        depositStart[msg.sender] = 0;
        etherBalanceOf[msg.sender] = 0;
        isDeposited[msg.sender] = false;
        //emit event
        emit Withdraw(msg.sender, userBalance, depositTime, interest);
    }

    function borrow() public payable {
        //check if collateral is >= than 0.01 ETH
        //check if user doesn't have active loan
        //add msg.value to ether collateral
        //calc tokens amount to mint, 50% of msg.value
        //mint&send tokens to user
        //activate borrower's loan status
        //emit event
    }

    function payOff() public {
        //check if loan is active
        //transfer tokens from user back to the contract
        //calc fee
        //send user's collateral minus fee
        //reset borrower's data
        //emit event
    }
}
