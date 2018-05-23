pragma solidity ^0.4.19;

import "./TGApprovable.sol";
    
    // wallet eligibility state 의 매핑을 저장한다.
    // The address can be whatever the caller wants
    // 0 = Not yet XYEligible
    // setting eligibility 정보는 영구적이다.
    
contract TGProofOfEligibility is TGApprovable {
    
    
    mapping(address => byte[]) public eligible;
    
    modifier onlyEligible() {
        require(eligible[msg.sender].length > 0);
        _;
    }
    modifier onlyIneligible() {
        require(eligible[msg.sender].length > 0);
        _;
    }

    function setEligibility(address _wallet, byte[] _proof) public onlyApprovers {
        require(eligible[_wallet].length == 0);
        require(_proof.length <= 128);
        eligible[_wallet] = _proof;
    }
}