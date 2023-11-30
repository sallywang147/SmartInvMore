pragma solidity ^0.5.0;

import "./Libraries/IERC20.sol";
import "./SafeMath.sol";
import "./Libraries/VeriSolContracts.sol";

contract atomicityExample{

  mapping (address=>mapping(uint256=>uint256)) public tickets; 
  uint winner; 
  uint256 userID;
  bool drawingLock; 

  function startLotteryRound() public {
   // delete tickets; 
    winner = 0; 
    drawingLock = false;  
  }
  
  function enterDrawingPhase() internal {
    drawingLock = true;
  }

  function buy(uint userID, uint256 amount) external {
    require(winner == 0, "already drawn"); 
    require(!drawingLock, "drawing");
    tickets[msg.sender][userID] += amount;
    }

  function draw(uint userID) external {
   //Guanaco multimodal invariant: 
   require(drawingLock, "drawing is done");
   require(winner == 0, "already drawn");
   winner = userID; 
   }
}