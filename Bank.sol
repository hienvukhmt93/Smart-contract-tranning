pragma solidity ^0.4.25;
pragma  experimental ABIEncoderV2;

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

contract Owner {
    
    address public owner;
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    event TransferOwnerShip(address indexed from, address indexed to);
    
    constructor () public {
        owner = msg.sender;
    }
    
    function transferOwnerShip(address newOwner) public onlyOwner {
        require(newOwner != 0x0);
        owner = newOwner;
        emit TransferOwnerShip(msg.sender, owner);
    }
        
}

contract BankBasic is Owner {
    
    string public bankName;
    uint public totalMoney;
    
    constructor(string _bankName, uint _totalMoney) public {
        bankName = _bankName;
        totalMoney =  _totalMoney;
    }
    
    function changeBankName(string _newName) onlyOwner public returns(bool _suc) {
        bytes memory _name = bytes(_newName);
        require(_name.length > 0);
        bankName = _newName;
        _suc = true;
        return;
    }
}


interface BankInterFace {
    
    function transfer(address _to, uint _amout) external returns(bool _suc);
    function withdraw(uint _amout)  external returns(bool _suc);
}


contract BankMeta is BankBasic, BankInterFace {
    
    using SafeMath for uint;
    
    mapping(address => uint)  _addToIndex;
    mapping(address => uint)  _balances;
    mapping(address => uint) _count;
    
    struct User {
        string username;
        uint id;
        uint balance;
    }
    struct TransactionHistory {
        address _from;
        address _to;
        uint _amout;
        uint time;
    }
    
    User[]  users;
    TransactionHistory[] transactions;
    uint index = 0;
    
    constructor(string _bankName, uint _totalMoney) BankBasic(_bankName, _totalMoney) public {}
    
    function signUp(string _userName) public returns(bool _suc) {
        require(msg.sender != owner);
        bytes memory _name = bytes(_userName);
        require(_name.length > 0);
        require(_count[msg.sender] == 0);
        User memory _user = User(_userName, index, 0);
        users.push(_user);
        _addToIndex[msg.sender] = index;
        _count[msg.sender]++;
        index++;
        _suc = true;
        return;
    }
    
    
    function setBalances(address _target, uint _amout) onlyOwner public returns(bool _suc) {
        require(_target != 0x0);
        require(_count[_target] != 0);
        require(_amout > 0);
        users[_addToIndex[msg.sender]].balance = users[_addToIndex[msg.sender]].balance.add(_amout);
        _suc = true;
        return;
    }
    
    function getSelfInfor() public view returns(User _self) {
        _self = users[_addToIndex[msg.sender]];
        return;
    }
    
    function getListUser() onlyOwner public view returns(User[] _listUser) {
        _listUser = users;
        return;
    }
    
    function getAnyOneUser(address _target) onlyOwner public view returns(User _result) {
        require(_target!= 0x0);
        require(_count[_target] !=0);
        _result = users[_addToIndex[_target]];
        return;
    }
    
    
    function transfer(address _to, uint _amout) external returns(bool _suc) {
        require(msg.sender != owner);
        require(_to != 0x0);
        require(_count[_to] != 0);
        require(_amout > 0);
        require(users[_addToIndex[msg.sender]].balance > _amout);
        users[_addToIndex[msg.sender]].balance = users[_addToIndex[msg.sender]].balance.sub(_amout);
        users[_addToIndex[_to]].balance = users[_addToIndex[_to]].balance.add(_amout);
        transactions.push(TransactionHistory(msg.sender, _to, _amout, now));
        _suc = true;
        return;
    }
    
    function withdraw(uint _amout)  external returns(bool _suc) {
        require(msg.sender != owner);
        require(_count[msg.sender] != 0);
        require(_amout > 0);
        users[_addToIndex[msg.sender]].balance = users[_addToIndex[msg.sender]].balance.sub(_amout);
        _suc = true;
        transactions.push(TransactionHistory(msg.sender, 0x0, _amout, now));
        return;
    }
    
    function getTransactionsHistory() public view returns(TransactionHistory[] ) {
        require(_count[msg.sender] != 0);
        TransactionHistory[] memory _tran = new TransactionHistory[](transactions.length);
        uint8 _index = 0;
        if(transactions.length > 0) {
            for(uint8 i = 0; i < transactions.length; i++) {
                if(transactions[i]._from == address(msg.sender) || transactions[i]._to == address(msg.sender)) {
                   _tran[_index] = transactions[i];
                   _index++;
                }
            }
        }
        return _tran;
    }
    
}
