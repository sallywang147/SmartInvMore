pragma solidity ^0.5.0;

import "./Libraries/IERC20.sol";
import "./SafeMath.sol";
import "./Libraries/VeriSolContracts.sol";



contract moneyReserve is IERC20 {
    
     IERC20 token0;
     IERC20 token1;
     address token0addr;
     address token1aadr; 
     uint amount1out;

     function swap(IERC20 token0, IERC20 token1, uint amount1out) public {

       uint balance0 = token0.balanceOf(address(this));
       uint balance1 = token1.balanceOf(address(this));
       token1.transfer(token0addr, amount1out);
       uint charge = amount1out * 100 / 22;
       uint amount0in = amount1out;
       //SmartInv generated: 
       assert(balance1 >= charge + amount1out);
       balance1 = balance1 - amount1out - charge; 

     }
}