pragma solidity ^0.4.20;

import "../node_modules/zeppelin-solidity/contracts/ownership/Ownable.sol";

  // we need to block, but do not want to allow for future calls from a wallet, but keep the
  // previous wallet data address intact for our records
  // blocking is permanent
contract TGBlockable is Ownable {

    mapping(address => bool) public blocked;

    modifier onlyNotBlocked() {
        require(!blocked[msg.sender]);
        _;
    }

    modifier onlyBlocked() {
        require(blocked[msg.sender]);
        _;
    }


    function blockAddress(address _address) public onlyOwner {
        blocked[_address] = true;
    }
}