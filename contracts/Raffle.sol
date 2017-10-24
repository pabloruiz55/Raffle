pragma solidity ^0.4.4;

import "./usingOraclize.sol";

contract Raffle is usingOraclize{

  uint private chosenNumber;
  address private winnerParticipant;

  //The maximum number of participants the raffle can have
  //Set by the organizer
  uint8 maxParticipants;
  uint8 minParticipants;
  uint8 joinedParticipants;
  address organizer;

  bool raffleFinished = false;
  //uint raffleID = now();

  address[] participants;
  mapping (address => bool) participantsMapping;

  event ChooseWinner(uint _chosenNumber,address winner);
  event RandomNumberGenerated(uint);

  function Raffle(address _org,uint8 _min, uint8 _max){ //USE THIS ONE WHEN FACTORY IS READY
  //function Raffle(){
    //address _org = msg.sender ;
    //uint8 _min = 2 ;
    //uint8 _max = 10 ;

    require(_min < _max && _min >=2 && _max <=50);

    organizer = _org;
    chosenNumber = 999;
    maxParticipants = _max;
    minParticipants = _min;
  }

  function() payable {}

  function joinRaffle(){
    require(!raffleFinished);
    require(msg.sender != organizer);
    require(joinedParticipants + 1 < maxParticipants);
    require(!participantsMapping[msg.sender]);

    participants.push(msg.sender);
    participantsMapping[msg.sender] = true;

    joinedParticipants ++;
  }

  function chooseWinner(uint _chosenNum) internal{

    chosenNumber = _chosenNum;
    winnerParticipant = participants[chosenNumber];
    ChooseWinner(chosenNumber,participants[chosenNumber]);

  }

  //Oraclize random number functions
  // the callback function is called by Oraclize when the result is ready
  // the oraclize_randomDS_proofVerify modifier prevents an invalid proof to execute this function code:
  // the proof validity is fully verified on-chain
  function __callback(bytes32 _queryId, string _result, bytes _proof)
  {
      // If we already generated a random number, we can't generate a new one.
      require(!raffleFinished);
      // if we reach this point successfully, it means that the attached authenticity proof has passed!
      require (msg.sender == oraclize_cbAddress());

      if (oraclize_randomDS_proofVerify__returnCode(_queryId, _result, _proof) != 0) {
          // the proof verification has failed, do we need to take any action here? (depends on the use case)
      } else {
          // the proof verification has passed

          raffleFinished=true;

          // for simplicity of use, let's also convert the random bytes to uint if we need
          uint maxRange = joinedParticipants; // this is the highest uint we want to get. It should never be greater than 2^(8*N), where N is the number of random bytes we had asked the datasource to return
          uint randomNumber = uint(sha3(_result)) % maxRange; // this is an efficient way to get the uint out in the [0, maxRange] range
          chooseWinner(randomNumber);

          RandomNumberGenerated(randomNumber); // this is the resulting random number (uint)
      }
    }

  function generateRandomNum(){
    require(!raffleFinished);
    require(joinedParticipants >=minParticipants && joinedParticipants<=maxParticipants);

    oraclize_setProof(proofType_Ledger); // sets the Ledger authenticity proof in the constructor
    uint N = 4; // number of random bytes we want the datasource to return
    uint delay = 0; // number of seconds to wait before the execution takes place
    uint callbackGas = 200000; // amount of gas we want Oraclize to set for the callback function
    bytes32 queryId = oraclize_newRandomDSQuery(delay, N, callbackGas); // this function internally generates the correct oraclize_query and returns its queryId

  }

  function getChosenNumber() constant returns (uint) {
    return chosenNumber;
  }

  function getWinnerAddress() constant returns (address) {
    return winnerParticipant;
  }

  function getParticipants() constant returns (address[]) {
    return participants;
  }

}
