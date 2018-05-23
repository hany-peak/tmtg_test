pragma solidity ^0.4.20;

import "./TGKillable.sol";

contract TGApprovable is TGKillable {
    //(1) 매핑
    mapping (address => bool) public approvers;

    //(2) 제어자
    modifier onlyApprovers() {
        require(approvers[msg.sender]);
        _;
    }
    //(3) 생성자
    constructor () public {
        approvers[msg.sender] = true;
    }
    //(4) 승인 함수
    function setApprover(address _approver, bool _enabled) public onlyOwner onlyNotKilled {
        approvers[_approver] = _enabled;

    }
}