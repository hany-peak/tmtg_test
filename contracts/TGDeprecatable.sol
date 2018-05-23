pragma solidity ^0.4.20;

import "../node_modules/zeppelin-solidity/contracts/ownership/Ownable.sol";

contract TGDeprecatable is Ownable {
    
    address public deprecated = 0;

    modifier onlyIfNotDeprecated() {
        require(deprecated == 0);
        _;
    }

    function deprecate(address _newAddress) public onlyOwner {
        deprecated = _newAddress;
    }

}