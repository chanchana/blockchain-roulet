pragma solidity ^0.5.1;

contract Roulet {
    address payable public manager;
    uint public playerCount = 0;
    address payable[] public players;
    mapping(address => bool) private playerExists;
    mapping(address => uint) private playerTokenBalance;
    mapping(address => mapping(uint => uint)) private bet;
    
    uint constant private totalNumber = 37;
    uint constant private numberRewardMultiplier = 35;
    uint constant private colorRewardMultiplier = 2;
    
    uint constant private oddColorPosition = 37;
    uint constant private evenColorPosition = 38;
    
    constructor() public {
        manager = msg.sender;
    }
    
    function buyToken(uint _amount) public {
        playerTokenBalance[msg.sender] += _amount;
    }
    
    function myToken() public view returns (uint) {
        return playerTokenBalance[msg.sender];
    }
    
    // Add bet for player
    function addBet(uint _number, uint _amount) public {
        require(playerTokenBalance[msg.sender] >= _amount, 'Not enough token in the balance');
        if (!playerExists[msg.sender]) {
            playerExists[msg.sender] = true;
            players.push(msg.sender);
            playerCount += 1;
        }
        bet[msg.sender][_number] += _amount;
        playerTokenBalance[msg.sender] -= _amount;
    }
    
    function removeBet(uint _number, uint _amount) public {
        require(bet[msg.sender][_number] >= _amount, 'Not enough bet token to remove');
        bet[msg.sender][_number] -= _amount;
        playerTokenBalance[msg.sender] += _amount;
    }
    
    // // Finish spinning and pay the reward
    // function finish(uint _targetNumber) public payable onlyManager {
    //     uint _i;
    //     bool _isOdd = _targetNumber % 2 == 1;
    //     bool _isEven = _targetNumber % 2 == 0;
        
    //     for (_i = 0; _i < playerCount; _i++) {
    //         address payable _playerAddress = players[_i];
    //         uint _rewardAmount = 0;
            
    //         // number reward
    //         if (bet[_playerAddress][_targetNumber] > 0) {
    //             _rewardAmount += bet[_playerAddress][_targetNumber] * numberRewardMultiplier;
    //         }
            
    //         // odd even color reward
    //         if (_isOdd && bet[_playerAddress][oddColorPosition] > 0) {
    //             _rewardAmount += bet[_playerAddress][oddColorPosition] * colorRewardMultiplier;
    //         } else if (_isEven && bet[_playerAddress][evenColorPosition] > 0) {
    //             _rewardAmount += bet[_playerAddress][evenColorPosition] * colorRewardMultiplier;
    //         }
            
    //         // pay reward
    //         require(address(this).balance >= _rewardAmount, "not enough fund");
    //         if (_rewardAmount > 0) {
    //             _playerAddress.transfer(_rewardAmount);
    //             emit PayReward(_playerAddress, manager, _rewardAmount);
    //         }
    //     }
    // }
    
    function getBalance() public view returns (uint) {
        return msg.sender.balance;
    }
    
    // // function spin() public {
    // //     uint targetNumber = pseudoRandom() % totalNumber;
    // // }
    
    function getMyBet(uint _number) public view returns (uint) {
        return bet[msg.sender][_number];
    }
    
    function pseudoRandom() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, now, players)));
    }
    
    function testRand() public view returns (uint) {
        return (pseudoRandom() % totalNumber) - 1;
    }
}