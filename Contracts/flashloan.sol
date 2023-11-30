pragma solidity ^0.5.0;

import "./Libraries/IERC20.sol";
import "./SafeMath.sol";
import "./Libraries/VeriSolContracts.sol";


contract flashloan is IERC20 {
    
     IERC20 ETH;
     IERC20 DAI;
     uint ETHout; 
     uint reserveETH;
     uint reserveDAI; 

     function exchange(uint256 amount, address to) public {
       DAI.transfer(to, amount);

       uint balanceETH = ETH.balanceOf(address(this));
       uint balanceDAI = DAI.balanceOf(address(this));
       uint ETHIn = balanceETH - (reserveETH - ETHout); 
       uint adjust = amount * 30 / 1000;
       require(adjust * balanceDAI >= reserveETH * reserveDAI, "insufficient funds \
       transferred back."); 
       //Guanaco generated:
       assert(ETH.balanceOf(address(this))/DAI.balanceOf(address(this)) >= VeriSol.Old(ETH.balanceOf(address(this))/DAI.balanceOf(address(this))));
       reserveDAI = balanceDAI;
       reserveETH = balanceETH; 

     }
}

