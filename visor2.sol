pragma solidity ^0.5.0;

import "./Libraries/IERC20.sol";
import "./SafeMath.sol";
import "./Libraries/VeriSolContracts.sol";


contract visor2 is IERC20 {
    
     IERC20 public token0;
     IERC20 token1;
     IERC20 myToken;

     function exchange(uint256 amount, address to) public {

       //SmartInv generated:
       assert(getPrice() <= 2*VeriSol.Old(getPrice()));
       if(getPrice()>10000) {
           //or other kind of bugs
           myToken.transfer(to, amount);
       }     
     }

     function getPrice() public returns (uint) {
      return token0.balanceOf(address(this))/token1.balanceOf(address(this));
     }
}

contract attack_client is IERC20 {
  visor2 public client;
  event printPrice(uint number);
  constructor (address Addr) public {
        client = visor2(Addr);
  }

  function attack() public {
    uint currentPrice = client.getPrice();
    emit printPrice(currentPrice);
    client.token0().transfer(address(this), 100000000);
    uint newPrice = client.getPrice();
    emit printPrice(newPrice);
  }

}