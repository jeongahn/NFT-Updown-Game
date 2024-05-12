// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.11;

contract BettingGame {
    address public owner;
    uint256 public totalAmount;
    uint256 private randomNumber;
    uint256 private betAmount;
    uint256 private chances;
    bool public gamePossible;

    event BetResult(address indexed player, uint256 amount, uint256 randomNumber, string isWin);

    constructor() {
        owner = msg.sender;
        totalAmount = 0;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can call this function");
        _;
    }

    function startGame() external payable {
        require(msg.value >= 1 ether && msg.value <= 5 ether, "Bet amount must be between 1 and 5 ethers");
        require(totalAmount >= msg.value * 3, "Insufficient funds in totalAmount");

        betAmount = msg.value;
        totalAmount += msg.value;
        chances = 3;
        randomNumber = uint8(block.timestamp % 25 + 1);

        gamePossible = true;
    }

    function progressGame(uint256 number) external {
        require(gamePossible, "Game is not possible to play currently");
        require(chances > 0, "No chances left to bet");

        chances--;

        if (randomNumber == number) {
            if (chances == 2) {
                payable(msg.sender).transfer(betAmount * 3);
                totalAmount -= (betAmount * 3);
            } else if (chances == 1) {
                payable(msg.sender).transfer(betAmount * 2);
                totalAmount -= (betAmount * 2);
            } else {
                payable(msg.sender).transfer(betAmount);
                totalAmount -= betAmount;
            }
            emit BetResult(msg.sender, betAmount, randomNumber, "answer");
        } else if (chances == 0) {
            emit BetResult(msg.sender, betAmount, randomNumber, "game over");
        } else {
            string memory message = randomNumber < number ? "down" : "up";
            emit BetResult(msg.sender, betAmount, randomNumber, message);
        }
    }

    function withdrawFunds() public onlyOwner {
        uint256 amount = totalAmount;
        totalAmount = 0;
        payable(owner).transfer(amount);
    }

    function deposit() external payable onlyOwner {
        totalAmount += msg.value;
    }
}
