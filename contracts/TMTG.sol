pragma solidity ^0.4.20;

// 블랙리스트 기능을 추가한 가상 화폐
import "../node_modules/zeppelin-solidity/contracts/token/ERC20/StandardToken.sol";
import "../node_modules/zeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
import "../node_modules/zeppelin-solidity/contracts/token/ERC20/BurnableToken.sol";
contract TMTGCoin is StandardToken, BurnableToken {  
    // library SafeERC20 {
    //     function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    //         assert(token.transfer(to, value));
    //     }
    //     function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
    //         assert(token.transferFrom(from, to, value));
    //     }
    //     function safeApprove(ERC20 token, address spender, uint256 value) internal {
    //         assert(token.approve(spender, value));
    //     }
    // } 
    //(0-1) 안전한 거래 함수 이용
    using SafeERC20 for ERC20;
    using SafeMath for uint256;
    // (1-1) 상태 변수 선언
    string public name = "TMTGCoin"; // 토큰 이름
    string public symbol = "TMTG"; // 토큰 단위
    uint8 public decimals = 8; // 소수점 이하 자릿수
    uint256 public totalSupply_ = 10000000000; // 토큰 총량 : 100억 개
    address public owner; // 소유자 주소
    uint256 public capOfTotalSupply;
    bool public released = false; //계약 배포여부
    bool public lockTransfers = false; //거래 잠금여부    
    // (1-2) MAPPING 선언
    mapping (address => uint256) public balanceOf; // 각 주소의 잔고
    mapping (address => int8) public blackList; // 블랙리스트
    
    

    // (2) 수식자
    modifier onlyOwner() { 
        require(msg.sender != owner); 
        _; 
    }
    modifier onlyReleased() { 
        require(released); 
        _;
    }
    // (3) 이벤트 알림
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Blacklisted(address indexed target);
    event DeleteFromBlacklist(address indexed target);
    event RejectedPaymentToBlacklistedAddr(address indexed from, address indexed to, uint256 value);
    event RejectedPaymentFromBlacklistedAddr(address indexed from, address indexed to, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    // (4) 생성자
    constructor(uint256 _supply, string _name, string _symbol, uint8 _decimals) public {
        balanceOf[msg.sender] = _supply;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply_ = _supply;
        capOfTotalSupply = totalSupply_;
        owner = msg.sender; // 소유자 주소 설정
    }

    //(0-2) 안전한 함수 사용 위한 로킹 
    function lockTransfer(bool _lock) onlyOwner public {
        lockTransfers = _lock;
    }

    // (5) 계약 배포 여부 - 이미 토큰은 발행되었지만 출시라는 인위적인 개념
    function release() public {
        require(owner == msg.sender);
        require(!released);
        released = true;
    }    
    // (6-1) 주소를 블랙리스트에 등록 
    function blacklisting(address _addr) onlyOwner public {
        blackList[_addr] = 1;
        emit Blacklisted(_addr);
    } 
    // (6-2) 주소를 블랙리스트에서 제거
    function deleteFromBlacklist(address _addr) onlyOwner public {
        blackList[_addr] = -1;
        emit DeleteFromBlacklist(_addr);
    }     
    // (7-1) 토큰 총량을 늘리는 함수
    function increaseCap(uint _addedValue) onlyOwner public returns (bool) {
        require(_addedValue >= 100e6 * 1 ether); // 100e6 * 1 ether 수정 필요
        capOfTotalSupply = capOfTotalSupply.add(_addedValue);
        return true;
    }
    // (7-2) 토큰 총량을 넘었는지 함수 
    function checkCap(uint256 _amount) public view returns (bool) {
        return (totalSupply_.add(_amount) <= capOfTotalSupply);
    }
    // (8-1) 소유자를 바꿔주는 함수(/Ownable) 
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
    // (9-1) 토큰 번(내장)
    
    // (10-1) @Override 거래 함수
    function transfer(address _to, uint256 _value) public returns(bool){
        require(!lockTransfers);
        return super.transfer(_to,_value);
    }
     
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool){
        require(!lockTransfers);
        return super.transferFrom(_from,_to,_value);
    }
    
    function() public {
        revert();
    }
    
    
}
