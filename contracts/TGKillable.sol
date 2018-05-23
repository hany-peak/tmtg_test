pragma solidity ^0.4.20;

import "../node_modules/zeppelin-solidity/contracts/ownership/Ownable.sol";
contract TGKillable is Ownable {

    bool public killed;

    modifier onlyKilled() {
        require(killed);
        _;
    }

    modifier onlyNotKilled() {
        require(!killed);
        _;
    }
    //this marks the contract dead forever - no more transactions
    //flushes all ETH from the contract to the seller
    
    function kill() public onlyOwner onlyNotKilled {
        killed = true;
        owner.transfer(address(this).balance);
    }
}