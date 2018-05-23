pragma solidity ^0.4.20;

import "../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol";

library TGVariablePrice {
    using SafeMath for *;

    function getTokensForEther (
        uint _numberSold,
        uint _ether,
        uint _startVariablePrice,
        uint _endVariablePrice,
        uint _maxVariablePrice,
        uint _maxFixedAvailableIn,
        uint _maxVariableAvailableIn
        )
    internal pure returns(uint) {
        uint maxVariableAvailable = _maxVariableAvailableIn * (10 ** 18);
        uint maxFixedAvailable = _maxFixedAvailableIn * (10 ** 18);
        if ( _numberSold >= maxVariableAvailable + maxFixedAvailable) {
            return 0;
        }
        if (_isVariableSoldOut(_numberSold, maxVariableAvailable)) {
            if (_isFixedSoldOut(_numberSold, maxVariableAvailable, maxFixedAvailable)) {
                return 0;
            } else {
                return _getDesiredFixedTokensForEther(_numberSold, _ether, _endVariablePrice, maxVariableAvailable, maxFixedAvailable);
            }            
        } else {
            uint maxEtherSpendableOnVariable = _getMaxEtherSpendableOnVariable(_numberSold, _startVariablePrice, _endVariablePrice, maxVariableAvailable); // maximum amount of Ether that can be spent on Variable-priced Tokens
            uint desiredVariableTokens = _getDesiredVariableTokensForEther(_numberSold, _ether, _startVariablePrice, _endVariablePrice, maxVariableAvailable); // desired Variable-priced Tokens for Transaction (or maximum available if final Transaction at Variable price)
            if (maxEtherSpendableOnVariable > _ether) {
                return desiredVariableTokens;
            } else {
                uint etherLeftForFixed = _ether - maxEtherSpendableOnVariable; // Ether remaining for Fixed-priced Tokens
                uint maxEtherSpendableOnFixed = _getMaxEtherSpendableOnFixed(_numberSold, _endVariablePrice, maxVariableAvailable, maxFixedAvailable); // maximum Ether available to be spent on Fixed-priced Tokens
                uint desiredFixedTokens = _getDesiredFixedTokensForEther(_numberSold, etherLeftForFixed, _endVariablePrice, maxVariableAvailable, maxFixedAvailable);
                if (SafeMath.add(maxEtherSpendableOnFixed, maxEtherSpendableOnVariable) < _ether) {
                    return _getMaxTokensAvailableForTransaction(_numberSold, maxVariableAvailable, maxFixedAvailable);
                } else {
                    return SafeMath.add(desiredVariableTokens, desiredFixedTokens); 
                }
            }
        }
    }
    function _getMaxTokensAvailableForTransaction(uint _numberSold, uint _maxVariableAvailable, uint _maxFixedAvailable) 
    internal pure returns(uint) {
        if (_isFixedSoldOut(_numberSold, _maxVariableAvailable, _maxFixedAvailable)) {
            return 0;
        } else {
            return SafeMath.sub(SafeMath.add(_maxVariableAvailable, _maxFixedAvailable), _numberSold);
        }
    }
    function _isVariableSoldOut(uint _numberSold, uint _maxVariableAvailable) internal pure returns(bool) {
        return _numberSold >= _maxVariableAvailable;
    }
    function _isFixedSoldOut(uint _numberSold, uint _maxVariableAvailable, uint _maxFixedAvailable) internal pure returns(bool) {
        return _numberSold >= (SafeMath.add(_maxVariableAvailable, _maxFixedAvailable));    
    }
    function _getDesiredFixedTokensForEther(uint _numberSold, uint _ether, uint _endVariablePrice, uint _maxVariableAvailable, uint _maxFixedAvailable) 
        internal pure returns(uint) {
        uint maxFixedAvailableForTransaction = _getRemainingFixed(_numberSold, _maxVariableAvailable, _maxFixedAvailable);
        uint desiredFixedTokens = SafeMath.mul(_ether / (10 ** 9), _endVariablePrice / (10 ** 9));
        if (desiredFixedTokens <= maxFixedAvailableForTransaction) {
            return desiredFixedTokens;
        } else {
            return maxFixedAvailableForTransaction;
        }
    }
    function _getMaxEtherSpendableOnVariable(uint _numberSold, uint _startPrice, uint _endPrice, uint _maxVariableAvailable) 
    internal pure returns(uint) {
        if (_maxVariableAvailable < _numberSold) {
            return 0;
        } else {
            uint remainingVariable = SafeMath.sub(_maxVariableAvailable, _numberSold);
            uint currentPrice = _getCurrentPrice(_numberSold, _startPrice, _endPrice, _maxVariableAvailable); // price element for Ether calculation
            return SafeMath.div(remainingVariable * (10 ** 9), currentPrice / (10 ** 9));
        }    
    } 
    function _getDesiredVariableTokensForEther(uint _numberSold, uint _ether, uint _startVariablePrice, uint _endVariablePrice, uint _maxVariableAvailable) internal pure returns(uint) {
        if (_numberSold >= _maxVariableAvailable) { // check if Variable-priced Tokens are available
            return 0; // return 0 Variable-priced Tokens
        } else {
            uint currentPrice = _getCurrentPrice(_numberSold, _startVariablePrice, _endVariablePrice, _maxVariableAvailable); // current price of Token based on Tokens sold to-date
            uint desiredTokens = SafeMath.mul(_ether, currentPrice / (10 ** 9)) / (10 ** 9); // amount of Variable-priced Tokens available given Ether input
            uint maxVariableTokens = _getMaxVariableAvailableForTransaction(_numberSold, _maxVariableAvailable); // maximum Variable-priced Tokens available
            if (desiredTokens > maxVariableTokens) { // check if there are more desired Variable-priced Tokens than the amount available
                return maxVariableTokens; // return the maximum amount of Variable-priced Tokens available
            } else {
                return desiredTokens; //return the full amount of desired Variable-priced Tokens
            }
        }
    }

    // the maximum amount of Ether a buyer can spend on Fixed-priced Tokens
    function _getMaxEtherSpendableOnFixed(uint _numberSold, uint _endPrice, uint _maxVariableAvailable, uint _maxFixedAvailable) internal pure returns(uint) {
        if (_maxVariableAvailable > _numberSold) // check if there are Variable-priced Tokens available
        {
            return SafeMath.div(_maxFixedAvailable, _endPrice / 10**18); // returns the maximum amount of Ether that can be spent on Fixed-priced Tokens
        }else if (SafeMath.add(_maxVariableAvailable, _maxFixedAvailable) <= _numberSold) // case where there are no Tokens available
        {
            return 0;
        }
        else // case where there not Variable-priced Tokens available
        {
            return SafeMath.div(_getRemainingFixed(_numberSold, _maxVariableAvailable, _maxFixedAvailable), _endPrice / (10 ** 18)); // return maxiumum amount of Ether that can be spent on remaining Fixed-priced Tokens
        }
    }

    function _getRemainingFixed(uint _numberSold, uint _maxVariableAvailable, uint _maxFixedAvailable) internal pure returns(uint) {
        if (_numberSold > SafeMath.add(_maxVariableAvailable, _maxFixedAvailable)) // make sure Tokens are available for Transaction
        {
            return 0;
        }
        if (_numberSold < _maxVariableAvailable) // check if Variable-priced Tokens are available
        {
            return _maxFixedAvailable; // return maximum amount of Fixed-priced Tokens
        }
        else
        {
            uint fixedSoldToDate = SafeMath.sub(_numberSold, _maxVariableAvailable); // amount of Fixed-priced Tokens sold to-date
            return SafeMath.sub(_maxFixedAvailable, fixedSoldToDate); // return the remaining Fixed-priced Tokens available
        }
    }

    function _getCurrentPrice(uint _numberSold, uint _startPrice, uint _endPrice, uint _maxVariableAvailable) internal pure returns(uint) {
        if (_numberSold >= _maxVariableAvailable) // check if Variable-priced are Tokens available
        {
            return _endPrice; // returns the end price
        }
        else {
            uint tokensAvailablePerEtherRange = SafeMath.sub(_startPrice, _endPrice); // the start and end price are defined in Tokens, so the start price is greater than the end price (in Tokens)
            uint percentComplete = SafeMath.div(_numberSold, (_maxVariableAvailable) / (10 ** 18)); // the percentage of Tokens sold to-date of the maximum Variable-priced Tokens available
            uint delta = SafeMath.mul(percentComplete / (10 ** 9), tokensAvailablePerEtherRange / (10 ** 9));  // the amount of Tokens available given the percentage of Tokens sold to-date
            return SafeMath.sub(_startPrice, delta); // returns the price at a given number of Tokens sold to-date
        }
    }

    function _getMaxVariableAvailableForTransaction(uint _numberSold, uint _maxVariableAvailable) internal pure returns(uint) {
        if (_maxVariableAvailable > _numberSold) // check if Variable-priced Tokens are available
        {
            return SafeMath.sub(_maxVariableAvailable, _numberSold); // return the amount of Variable-priced Tokens available
        } else {
            return 0; // return 0 Variable-priced Tokens
        }
    }
}