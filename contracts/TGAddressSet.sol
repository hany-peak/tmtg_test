pragma solidity ^ 0.4.21;

contract TGAddressSet {

    mapping (address => uint) duplicateCheck;
    address[] items;

    function add(address item) public {
        require(item != 0);
        if(!contains(item)) {
            duplicateCheck[item] = items.length;
            items.push(item);
        }
    }

    function contains(address item) public view returns (bool) {
        require(item != 0);
        if (duplicateCheck[item] > 0) {
            return true;
        }
        return false;
    }

    function getPosition(uint pos) public view returns (address) {
        return items[pos];
    }
}