pragma solidity ^0.4.20;


import "../node_modules/zeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "./TGKillable.sol";
import "../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol";


contract TGTokenSale is TGKillable {
    using SafeMath for *;
    ERC20 public token; // ERC 20 토큰 주소
    uint private price; // 토큰 값 (how many tokens per ETH)
    // minimum amount of Ether required for a purchase (0 for no minimum) 18 places
    uint public minEther;   
    address public beneficiary; //where the duplicate tokens go : 수익자

    event EtherAccepted(address seller, address buyer, uint amount);
    event TokenSent(address seller, address buyer, uint amount);

    constructor(address _token, address _beneficiary, uint _price, uint _minEther) public {
        token = ERC20(_token);
        price = _price;
        minEther = _minEther;
        beneficiary = _beneficiary;
    }
    
    function () public onlyNotKilled payable {
        purchase();
    }
    
    function kill() public onlyOwner {
        token.transferFrom(this, beneficiary, token.balanceOf(this));
        beneficiary.transfer(address(this).balance);
        killed = true;
    }

    function purchase() public onlyNotKilled payable {
        uint ethAmount = msg.value;
        //이더로부터 토큰의 값 선언
        uint tokenAmount = _tokensFromEther(ethAmount);
        //좀더 이해 필요 왜 2배보다 작아야 하는가?
        require(tokenAmount * 2 <= getAvailableTokens());
        require(tokenAmount <= token.balanceOf(owner));
        require(ethAmount >= minEther || minEther == 0);
       
        _purchase(ethAmount, tokenAmount);
    }

    function _purchase(uint _ethAmount, uint _tokenAmount) internal onlyNotKilled {
        _acceptEther(_ethAmount);
        _sendTokens(_tokenAmount);
    }

    //해당 이더만큼을 받는다
    function _acceptEther(uint _amount) internal onlyNotKilled {
        beneficiary.transfer(_amount);
        emit EtherAccepted(beneficiary, msg.sender, _amount);
    }

    function _sendTokens(uint _amount) internal onlyNotKilled {
        token.transferFrom(owner, beneficiary, _amount);
        token.transferFrom(owner, msg.sender, _amount);
        emit TokenSent(owner, msg.sender, _amount);
    }

    function setMinEther(uint _minEther) public onlyOwner onlyNotKilled {
        minEther = _minEther;
    }

    function getAvailableTokens() public view onlyNotKilled returns(uint) {
        return token.allowance(owner, this);
    }

    function _tokensFromEther(uint _ethAmount) internal onlyNotKilled view returns(uint) {
        return SafeMath.div(_ethAmount, 1000000000) * SafeMath.div(getPrice(), 1000000000);

    }
   
    function setPrice(uint _price) public onlyOwner onlyNotKilled {
        price = _price;
    }

    function getPrice() public view onlyNotKilled returns(uint) {
        return price;
    }
}