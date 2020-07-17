// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.7.0;

contract Ballot {
    // candidate standing for election
    struct Candidate {
        string name;       //candidate's name
        uint voteCount;    //candidate's vote count
    }

    address public administrator;

    struct Voter {
        address delegate;
        uint vote;
        uint weight;    // weight of vote of the voter
        bool voted;       // to check if voter has voted
    }

    mapping(address => Voter) public voters;
    Candidate[] public candidates;

    // modifier to check administrator
    modifier onlyAdministrator() {
        require(msg.sender == administrator,"Only   administrator can give right to vote.");
        _;
    }
    constructor() public {
        administrator = msg.sender;
        voters[administrator].weight = 1;
    }

    //add candidate
    function addCandidate(string memory candidateName) public onlyAdministrator{
         candidates.push(Candidate({name: candidateName, voteCount: 0}));
    }

    // give right to vote
    function giveRightToVote(address voter) public  onlyAdministrator {

        require(!voters[voter].voted, "The voter already voted.");
        require(voters[voter].weight == 0, "Already have right");
        voters[voter].weight = 1;
    }

    //assign delegate
    function delegate(address _delegate) public {
        Voter storage sender = voters[msg.sender];
        address to = _delegate;
        require(!sender.voted, "You already voted.");
        require(to != msg.sender, "Self-delegation is not allowed.");
        //this assigns delegate
        //loop assigns the delegate of the delegate
        // returns error if infinite loop occurs
        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;
            require(to != msg.sender, "There is a loop loop ");
        }
        sender.voted = true;
        sender.delegate = to;
        Voter storage delegate_ = voters[to];
        if (delegate_.voted) {
            //if delegate has alredy voted
            // then the vote is added to the candidate's vote count
            //to whom delegate has alredy voted
            candidates[delegate_.vote].voteCount += sender.weight;
        } else {
            delegate_.weight += sender.weight;
        }
    }

    // cast vote
    function vote(uint CandidateNumber) public {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Has no right to vote");
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = CandidateNumber;

        candidates[CandidateNumber].voteCount += sender.weight;
    }

    //finds winner
    //by checking every candidates vote
    function winningCandidate() public view returns (string memory winnerName){
        uint winningVoteCount = 0;
        uint winingCandidateNumber;
        for (uint i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > winningVoteCount) {
                winningVoteCount = candidates[i].voteCount;
                winingCandidateNumber = i;
            }
        }
        winnerName = candidates[winingCandidateNumber].name;
    }

}