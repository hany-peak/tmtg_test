pragma solidity ^0.4.20;

import "./TGTokenSale.sol";

contract TGTimedTokenSale is TGTokenSale {

    uint public startTime; // 0 = right away
    uint public endTime;   // 0 = never

    constructor(address _token, address _beneficiary, uint _price, uint _minEther, uint _startTime, uint _endTime)
    TGTokenSale(_token, _beneficiary, _price, _minEther) public {
        startTime = _startTime;
        endTime = _endTime;
    }

    modifier live() {
        require(isLive());
        _;
    }
    modifier notLive() {
        require(!isLive());
        _;
    }

    function isLive() public view returns(bool){
        bool live = true;
        if (killed) {
            live = false;
        } else if ( startTime > 0){
            //보안 이슈 now? block.timestamp? 
            if(startTime > now) {
                live = false;
            }
        } else if ( endTime > 0) {
            if(endTime < now) {
                live = false;
            }
        }
        return live;
    }
}