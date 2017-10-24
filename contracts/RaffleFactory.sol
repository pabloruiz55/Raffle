pragma solidity ^0.4.4;
import './Raffle.sol';

contract RaffleFactory{

  Raffle[] raffles;
  mapping (address => Raffle) rafflesMapping;

  event RaffleCreated(address);

  function startRaffle(uint8 _min, uint8 _max){
    Raffle l = new Raffle(msg.sender,_min,_max);
    raffles.push(l);
    rafflesMapping[address(l)] = l;
    RaffleCreated(address(l));
  }

}
