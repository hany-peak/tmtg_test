pragma solidity ^0.4.20;

import "./TGEligibleTokenSale.sol";
import "./TGVariablePrice.sol";

contract TGOfficialTokenSale is TGEligibleTokenSale {
    uint public numberSold;
    uint public startPrice;
    uint public endPrice;
    uint public totalVariableTokens;
    uint public totalFixedTokens;

    constructor (
        address _token, 
        address _beneficiary, 
        uint _minEther, 
        uint _startTime, 
        uint _endTime, 
        uint _startPrice, 
        uint _endPrice, 
        uint _totalVariableTokens, 
        uint _totalFixedTokens)
    public TGEligibleTokenSale(_token, _beneficiary, _startPrice, _minEther, _startTime, _endTime) { 
        startPrice = _startPrice;
        endPrice = _endPrice;
        totalVariableTokens = _totalVariableTokens;
        totalFixedTokens = _totalFixedTokens;
    }

    function _sendTokens(uint _amount) internal {
        super._sendTokens(_amount);
        numberSold = numberSold + _amount;
    }

    function setPrice(uint) public onlyOwner onlyNotKilled {
        //가격은 밖에서 set 불가능하게 한다.
        revert();
    }
    
    function getPrice() public view onlyNotKilled returns(uint) {
        return _tokensFromEther(1000000000000000000);
    }

    // function predictTokensForEther(uint _ethAmount) public view onlyNotKilled returns(uint) {
    //     return predictTokensForEtherAtPoint(_ethAmount, numberSold);
    // }
    
    // function _tokensFromEther(uint _ethAmount) internal view onlyNotKilled returns(uint) {
    //     return TGVariablePrice.getTokensForEther(numberSold, _ethAmount, startPrice, endPrice, totalVariableTokens, totalFixedTokens);
    // }

    // function predictTokensForEtherAtPoint(uint _ethAmount, uint _numberSold) public view onlyNotKilled returns(uint) {
    //     return TGVariablePrice.getTokensForEther(_numberSold, _ethAmount, startPrice, endPrice, totalVariableTokens, totalFixedTokens);
    // }
   

}