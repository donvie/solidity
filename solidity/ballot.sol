// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;
import "hardhat/console.sol";

contract Ballot {
    address public chairperson;
    bool public votingEnabled;

    struct Candidate {
        string name;
        uint voteCount;
    }

    struct Voter {
        bool voted;
        uint vote;
    }

    Candidate[] public candidates;
    mapping(address => Voter) public voters;

    modifier onlyChairperson {
        require(msg.sender == chairperson);
        _;
    }

    modifier votingIsEnabled {
        require(votingEnabled == true, "Voting disabled");
        _;
    }

    constructor(string[] memory candidateNames) {
        chairperson = msg.sender;
        for (uint index = 0; index < candidateNames.length; index++) {
            candidates.push(Candidate(candidateNames[index], 0));
        }
    }

    function vote (uint _candidate) public votingIsEnabled {
        require(voters[msg.sender].voted == false, "Already voted");
        voters[msg.sender].vote = _candidate;
        voters[msg.sender].voted = true;

        candidates[_candidate].voteCount++;
    }

    function getCandidatesLength() public view returns (uint) {
        return candidates.length;
    }

    function setVotingState (bool _votingEnabled) public onlyChairperson {
        votingEnabled = _votingEnabled;
    }

    function getWinningCandidate() public view returns(uint) {
        uint winningVoteCount;
        uint winningCandidate;

        for (uint index = 0; index < candidates.length; index++) {
            if (candidates[index].voteCount > winningVoteCount) {
                winningVoteCount = candidates[index].voteCount;
                winningCandidate = index;
            }
        }

        return winningCandidate;
    }

    function getWinner() public view returns(string memory) {
        uint winner = getWinningCandidate();

        if (candidates[winner].voteCount > 0) {
            return candidates[winner].name;
        }

        return "";
    }
}