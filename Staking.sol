// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// STAKE_TOKEN-0xde38bf17581c4bcddefc28febcf9ff0fb562c019
// REWARD_TOKEN-0xfe7ca0c52f5d160c590bb02f2b058f50fce60601
// STAKING-0x224938fedC2D94b5B608D15c7433752703087Cf1

contract Staking is ReentrancyGuard {
    using SafeMath for uint256;
    IERC20 public s_stakingToken;
    IERC20 public s_rewardToken;

    uint public constant REWARD_RATE = 1e18;
    uint private totalStakedTokens;
    uint public rewardPerTokenStored;
    uint public lastUpdateTime;
    uint public unstakingFeePercent = 3; // 3%

    address public owner;

    mapping(address => uint) public stakedBalance;
    mapping(address => uint) public rewards;
    mapping(address => uint) public userRewardPerTokenPaid;

    event Staked(address indexed user, uint256 indexed amount);
    event Withdrawn(address indexed user, uint256 indexed amount);
    event RewardsClaimed(address indexed user, uint256 indexed amount);

    constructor(address stakingToken, address rewardToken) {
        s_stakingToken = IERC20(stakingToken);
        s_rewardToken = IERC20(rewardToken);
        owner = msg.sender; // Set the owner to the contract deployer
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    function rewardPerToken() public view returns (uint) {
        if (totalStakedTokens == 0) {
            return rewardPerTokenStored;
        }
        uint totalTime = block.timestamp.sub(lastUpdateTime);
        uint totalRewards = REWARD_RATE.mul(totalTime);
        return rewardPerTokenStored.add(totalRewards.mul(1e18).div(totalStakedTokens));
    }

    function earned(address account) public view returns (uint) {
        return stakedBalance[account]
            .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
            .div(1e18)
            .add(rewards[account]);
    }

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;
        rewards[account] = earned(account);
        userRewardPerTokenPaid[account] = rewardPerTokenStored;
        _;
    }

    function stake(uint amount) external nonReentrant updateReward(msg.sender) {
        require(amount > 0, "Amount must be greater than zero");
        totalStakedTokens = totalStakedTokens.add(amount);
        stakedBalance[msg.sender] = stakedBalance[msg.sender].add(amount);
        emit Staked(msg.sender, amount);
        bool success = s_stakingToken.transferFrom(msg.sender, address(this), amount);
        require(success, "Transfer Failed");
    }

    function withdrawStakedTokens(uint amount) external nonReentrant updateReward(msg.sender) {
        require(amount > 0, "Amount must be greater than zero");
        require(stakedBalance[msg.sender] >= amount, "Staked amount not enough");
        uint fee = amount.mul(unstakingFeePercent).div(100);
        uint amountAfterFee = amount.sub(fee);
        totalStakedTokens = totalStakedTokens.sub(amount);
        stakedBalance[msg.sender] = stakedBalance[msg.sender].sub(amount);
        emit Withdrawn(msg.sender, amount);
        bool success = s_stakingToken.transfer(msg.sender, amountAfterFee);
        require(success, "Transfer Failed");
        bool feeSuccess = s_stakingToken.transfer(owner, fee); // Transfer fee to contract owner
        require(feeSuccess, "Fee Transfer Failed");
    }

    function getReward() external nonReentrant updateReward(msg.sender) {
        uint reward = rewards[msg.sender];
        require(reward > 0, "No rewards to claim");
        rewards[msg.sender] = 0;
        emit RewardsClaimed(msg.sender, reward);
        bool success = s_rewardToken.transfer(msg.sender, reward);
        require(success, "Transfer Failed");
    }

    function updateUnstakingFeePercent(uint _newFee) external onlyOwner {
        unstakingFeePercent = _newFee;
    }
}
// STAKE_TOKEN-0xde38bf17581c4bcddefc28febcf9ff0fb562c019
// REWARD_TOKEN-0xfe7ca0c52f5d160c590bb02f2b058f50fce60601
// STAKING-0x224938fedC2D94b5B608D15c7433752703087Cf1