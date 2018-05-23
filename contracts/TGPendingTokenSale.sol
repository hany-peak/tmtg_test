pragma solidity ^0.4.20;

import "./TGTimedTokenSale.sol";
import "./TGBlockable.sol";
import "./TGApprovable.sol";


contract TGPendingTokenSale is TGTimedTokenSale, TGApprovable, TGBlockable {

    struct Pending {
        uint eth;
        uint tokens;
    }
    
    event Approved(address buyer);

    mapping (address => Pending) public pending;
    
    constructor (address _token, address _beneficiary, uint _price, uint _minEther, uint _startTime, uint _endTime)
    TGTimedTokenSale(_token, _beneficiary, _price, _minEther, _startTime, _endTime)
    public {

    }

    function approve(address _buyer) public onlyApprovers {
        _approve(_buyer);
        emit Approved(_buyer);
    }

    function _acceptEther(uint _amount) internal {
        pending[msg.sender].eth = pending[msg.sender].eth + _amount;
        emit EtherAccepted(this, msg.sender, _amount);
    }

    function _sendTokens(uint _amount) internal {
        pending[msg.sender].tokens = pending[msg.sender].tokens + _amount;
        token.transferFrom(owner, beneficiary, _amount);
        token.transferFrom(owner, this, _amount);
    }

    //지연& 보류된 돈을 넘겨준다.
    function _approve(address _buyer) internal {
        if(pending[_buyer].tokens > 0) {
            beneficiary.transfer(pending[_buyer].eth);
            token.transfer(_buyer, pending[_buyer].tokens);
            
            pending[_buyer].tokens = 0;
            pending[_buyer].eth = 0;
        }

    
    
    
    }




}