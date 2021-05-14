pragma solidity ^0.5.1;

contract Roulet {
    uint public playerCount = 0;
    address payable[] public players;
    mapping(address => bool) private playerExists;
    mapping(address => mapping(uint => uint)) private bet;
    mapping(address => uint) private playerTokenBalance;
    mapping(address => uint[]) private playerRewardHistory;
    uint[] public spinHistory;
    uint private spinHistoryCount = 0;
    
    uint constant private totalNumber = 37;
    uint constant private numberRewardMultiplier = 35;
    uint constant private colorRewardMultiplier = 2;
    
    uint constant private oddColorPosition = 37;
    uint constant private evenColorPosition = 38;
    
    constructor() payable public {
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
    
    // Finish spinning and pay the reward
    function finish(uint _targetNumber) public {
        uint _i;
        bool _isOdd = _targetNumber % 2 == 1;
        bool _isEven = _targetNumber % 2 == 0;
        
        for (_i = 0; _i < playerCount; _i++) {
            address _playerAddress = players[_i];
            uint _rewardAmount = 0;
            
            // number reward
            if (bet[_playerAddress][_targetNumber] > 0) {
                _rewardAmount += bet[_playerAddress][_targetNumber] * numberRewardMultiplier;
            }
            
            // odd even color reward
            if (_isOdd && bet[_playerAddress][oddColorPosition] > 0) {
                _rewardAmount += bet[_playerAddress][oddColorPosition] * colorRewardMultiplier;
            } else if (_isEven && bet[_playerAddress][evenColorPosition] > 0) {
                _rewardAmount += bet[_playerAddress][evenColorPosition] * colorRewardMultiplier;
            }
            
            // pay reward
            playerRewardHistory[_playerAddress].push(_rewardAmount);
            if (_rewardAmount > 0) {
                playerTokenBalance[msg.sender] += _rewardAmount;
            }
        }
        
        addToHistory(_targetNumber);
        reset();
    }
    
    function reset() private {
        uint _i;
        uint _j;
        
        for (_i = 0; _i < playerCount; _i++) {
             for (_j = 0; _j < totalNumber + 2; _j++) {
                bet[players[_i]][_j] = 0;
            }
        }
    }
    
    function addToHistory(uint _targetNumber) private {
        spinHistory.push(_targetNumber);
        spinHistoryCount += 1;
    }
    
    function getHistory() public view returns (uint[] memory) {
        return spinHistory;
    }
    
    function getPlayerRewardHistory() public view returns (uint[] memory) {
        return playerRewardHistory[msg.sender];
    }
    
    function getBalance() public view returns (uint) {
        return msg.sender.balance;
    }
    
    function spin() public returns (uint) {
        uint _targetNumber = pseudoRandom() % totalNumber;
        finish(_targetNumber);
        return _targetNumber;
    }
    
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