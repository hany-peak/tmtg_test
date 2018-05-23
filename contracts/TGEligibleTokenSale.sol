pragma solidity ^0.4.20;

import "./TGPendingTokenSale.sol";
import "./TGProofOfEligibility.sol";

contract TGEligibleTokenSale is TGPendingTokenSale, TGProofOfEligibility {
    constructor(address _token, address _beneficiary, uint _price, uint _minEther, uint _startTime, uint _endTime)
    public TGPendingTokenSale(_token, _beneficiary, _price, _minEther, _startTime, _endTime){}
    
    function approve(address _buyer, byte[] _proofOfEligibility) public onlyApprovers onlyNotKilled {
        require(!blocked[_buyer]);
        setEligibility(_buyer, _proofOfEligibility);
        _approve(_buyer);
    }
    
    //사용하지 않는 함수, call-around 막아준다.
    function approve(address _buyer) public onlyApprovers {
        revert();
        _approve(_buyer);
    }
    
    function _purchase(uint _ethAmount, uint _tokenAmount) internal onlyNotBlocked {
        address buyer = msg.sender;
        super._purchase(_ethAmount, _tokenAmount);

        //만약 구매자가 자격이 있으면, 자동 approve 해준다.
        if(eligible[buyer].length > 0){
            _approve(buyer);
        }
    }
}