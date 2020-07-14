// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.7.0;
contract wallet {
    // Holders of the wallet
    struct Holder{
        string Name;       //name
        bool access;        // access of wallet
        uint accepted;      // accepted a transaction
    }

    // transaction from the wallet
    struct Transaction{
        address payable Receiver;
        uint Payment;       // amount to Pay
        uint acceptance;    // the count of acceptance from holders
        address Sender;
        bool completed;     // status of transaction
    }

    address mainHolder;                             //wallet creator
    mapping (address => Holder) holders;
    mapping (uint => Transaction) transactions;
    uint Total_Holders;                             // total number of holders
    uint Amount;
    uint Transaction_Number;                        // counter for transaction
    //
    //initialization
    constructor (string memory name) public payable {
        mainHolder = msg.sender;
        holders[mainHolder].Name = name;
        holders[mainHolder].access = true;
        Total_Holders = 1;
        Amount = msg.value;
        Transaction_Number = 0;
    }
    //
    // add holders
    // done by main holder
    function giveAccessTo(address to, string memory name) public {
        require(msg.sender==mainHolder, "Not allowed to give access");
        require(!holders[to].access, "already have access");
        holders[to].Name = name;
        holders[to].access = true;
        holders[to].accepted = 0;
        Total_Holders++;
    }
    //
    // anyone with access can add in wallet
     function addAmount() public  payable{
        require(holders[msg.sender].access, "Do not have access");
        Amount += msg.value;
     }
     //
     // ask for a Transaction_Number
     //only with access can ask
     // returns a Transaction number
     function askForTransaction(address payable receiver) public payable returns(uint){
        require(holders[msg.sender].access, "Do not have access");
        require(msg.value<=Amount,"Insufficient Balance");
        ++Transaction_Number;
        transactions[Transaction_Number].Sender = msg.sender;
        transactions[Transaction_Number].Receiver = receiver;
        transactions[Transaction_Number].Payment = msg.value;
        transactions[Transaction_Number].completed = false;
        transactions[Transaction_Number].acceptance = 0;
        return Transaction_Number;
     }
     //
     // accepting a transaction
     // only holders can accept
     function acceptTransaction(uint transaction_number ) public {
        require(holders[msg.sender].access, "Do not have access");
        //
        //if holder have accepted a transaction and transactions with
        //transaction number greater than this cannot accept
        require(holders[msg.sender].accepted<transaction_number, "Not allowed");
        //
        // holders can accept a transaction in serial order
        // this number is stored in holders detail
        holders[msg.sender].accepted = transaction_number;
        transactions[transaction_number].acceptance++;
     }
     //
     //complete the transaction
     function transact(uint transaction_number) public returns (bool) {
         require(transactions[transaction_number].Sender==msg.sender, "Do not have permission");
         require(transactions[transaction_number].acceptance > (Total_Holders/2), "Not Approved");
         require(!transactions[transaction_number].completed, "Transaction is already completed");
         Amount -= transactions[transaction_number].Payment;
         address payable receiver = transactions[transaction_number].Receiver;
         receiver.transfer(transactions[transaction_number].Payment);
         transactions[transaction_number].completed = true;
         return true ;
     }
}