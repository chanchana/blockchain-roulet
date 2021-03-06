pragma solidity ^0.5.1;

contract Roulet {
    
    struct PlayerProfile {
        bool exists;
        mapping(uint => uint) bet;
        uint tokenBalance;
        uint[] rewardHistory;
    }
    
    uint public playerCount = 0;
    address payable[] public players;
    address payable public dealer;
    mapping(address => PlayerProfile) private playerProfile;
    uint[] public spinHistory;
    uint private spinHistoryCount = 0;
    
    uint constant private totalNumber = 37;
    uint constant private numberRewardMultiplier = 35;
    uint constant private colorRewardMultiplier = 2;
    
    uint constant private oddColorPosition = 37;
    uint constant private evenColorPosition = 38;
    
    constructor() payable public {
    }
    
    function buyToken(uint _amount) public payable {
        playerProfile[msg.sender].tokenBalance += _amount;
    }

    function sellToken(uint _amount) public payable {
        require(playerProfile[msg.sender].tokenBalance >= _amount, 'Not enough token to sell');
        require(address(this).balance >= _amount * (1 ether), 'The contract have no enough eth');

         playerProfile[msg.sender].tokenBalance -= _amount;

        msg.sender.transfer(_amount  * (1 ether));
    }
    
    function myToken() public view returns (uint) {
        return  playerProfile[msg.sender].tokenBalance;
    }

    function dealerBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function beDealer() public {
        require(dealer == address(0), 'the roulet already have dealer');
        
        dealer = msg.sender;
    }

    function dealerWithDraw(uint _amount) public payable {
        require(dealer != address(0), 'the roulet have no dealer');
        require(dealer == msg.sender, 'you must be dealer to withdraw');

        msg.sender.transfer(_amount  * (1 ether));
    }

    function dealerDeposit() public payable {
        require(dealer != address(0), 'the roulet have no dealer');
        require(dealer == msg.sender, 'you must be dealer to deposit');
    }

    function dealerResign() public payable {
        require(dealer != address(0), 'the roulet have no dealer');
        require(dealer == msg.sender, 'you must be dealer to resign');
        
        dealer = address(0);

        if (address(this).balance > 0) {
            msg.sender.transfer(address(this).balance  * (1 ether));
        }
    }
    
    // Add bet for player
    function addBet(uint _number, uint _amount) public {
        require(playerProfile[msg.sender].tokenBalance >= _amount, 'Not enough token in the balance');
        if (!playerProfile[msg.sender].exists) {
            playerProfile[msg.sender].exists = true;
            players.push(msg.sender);
            playerCount += 1;
        }
        playerProfile[msg.sender].bet[_number] += _amount;
        playerProfile[msg.sender].tokenBalance -= _amount;
    }
    
    function removeBet(uint _number, uint _amount) public {
        require(playerProfile[msg.sender].bet[_number] >= _amount, 'Not enough bet token to remove');
        playerProfile[msg.sender].bet[_number] -= _amount;
        playerProfile[msg.sender].tokenBalance += _amount;
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
            if (playerProfile[_playerAddress].bet[_targetNumber] > 0) {
                _rewardAmount += playerProfile[_playerAddress].bet[_targetNumber] * numberRewardMultiplier;
            }
            
            // odd even color reward
            if (_isOdd && playerProfile[_playerAddress].bet[oddColorPosition] > 0) {
                _rewardAmount += playerProfile[_playerAddress].bet[oddColorPosition] * colorRewardMultiplier;
            } else if (_isEven && playerProfile[_playerAddress].bet[evenColorPosition] > 0) {
                _rewardAmount += playerProfile[_playerAddress].bet[evenColorPosition] * colorRewardMultiplier;
            }
            
            // pay reward
            playerProfile[_playerAddress].rewardHistory.push(_rewardAmount);
            if (_rewardAmount > 0) {
                playerProfile[_playerAddress].tokenBalance += _rewardAmount;
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
                playerProfile[players[_i]].bet[_j] = 0;
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
        return playerProfile[msg.sender].rewardHistory;
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
        return playerProfile[msg.sender].bet[_number];
    }
    
    function pseudoRandom() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, now, players)));
    }
    
    function testRand() public view returns (uint) {
        return (pseudoRandom() % totalNumber) - 1;
    }
}
