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

contract GenesisAnimal is Owner {
    
    struct GenesisAnimal {
        uint dna;
        string name;
        bool sex;
        uint age;
        uint weight;
        uint bornTimes;
        bool status;
        uint coolDownEat;
        uint coolDownExercise;
    }
    
    GenesisAnimal[] public animals;
}

contract Zoo is GenesisAnimal {
    
    mapping(address => uint8) _addressToIndex;
    mapping(address => uint8) _count;
    
    event CreateAnimal(address indexed _from);
    event Eat(address _from);
    event Sleep(address _from);
    event DoExercise(address _from);
    
    uint8 index = 0;
    function _create(string _name, bool sex) private  view returns(uint){
        uint result = uint(keccak256(_name, sex, now));
        return result % (10 ** 16);
    }
    
    function createAnimal(string _name, bool sex) public returns(GenesisAnimal) {
        require(_count[msg.sender] == 0);
        uint dna = _create(_name, sex);
        GenesisAnimal memory _ani = GenesisAnimal(dna, _name, sex, 1, 1, now, false, now, now);
        animals.push(_ani);
        _count[msg.sender]++;
        _addressToIndex[msg.sender] = index;
        index++;
        emit CreateAnimal(msg.sender);
        return _ani;
    }
    
    function eat(uint _index) external returns(bool _suc){}
    function sleep() external returns(bool _suc) {}
    function doexercise() external returns(bool _suc) {}
}

contract GrownAnimals is Zoo {
    using SafeMath for uint;
    modifier isReady(address _target) {
        require(now >= animals[_addressToIndex[msg.sender]].coolDownEat);
        _;
    }
    
    modifier isNotSleep(address _target) {
        require(!animals[_addressToIndex[msg.sender]].status);
        _;
    }
    
    function eat(uint _index)  isNotSleep(msg.sender) isReady(msg.sender) external returns(bool _suc) {
        require(_count[msg.sender] != 0);
        GenesisAnimal memory _selfAnimal = animals[_addressToIndex[msg.sender]];
        GenesisAnimal memory _targetAnimal = animals[_index];
        if(_selfAnimal.age > _targetAnimal.age) {
            animals[_addressToIndex[msg.sender]].age = animals[_addressToIndex[msg.sender]].age.add(1);
            animals[_addressToIndex[msg.sender]].weight = animals[_addressToIndex[msg.sender]].weight.add(1);
            animals[_addressToIndex[msg.sender]].coolDownEat = animals[_addressToIndex[msg.sender]].coolDownEat.add(1 days);
            _suc = true;
            emit Eat(msg.sender);
        }
        return;
    }

    function sleep() external returns(bool _suc) {
        require(_count[msg.sender] != 0);
        animals[_addressToIndex[msg.sender]].status = true;
        _suc = true;
        emit Sleep(msg.sender);
        return;
    }
    
    function doexercise() isNotSleep(msg.sender)  isReady(msg.sender) external returns(bool _suc) {
        require(_count[msg.sender] != 0);
        animals[_addressToIndex[msg.sender]].age = animals[_addressToIndex[msg.sender]].age.add(1);
        animals[_addressToIndex[msg.sender]].weight = animals[_addressToIndex[msg.sender]].weight.add(1);
        animals[_addressToIndex[msg.sender]].coolDownEat = animals[_addressToIndex[msg.sender]].coolDownEat.add(1 hours);
        emit DoExercise(msg.sender);
        _suc = true;
        return;
    }
}


contract CallContract {
    function call(address _target) public {
        GrownAnimals(_target).sleep();
    }
}