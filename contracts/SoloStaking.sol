pragma solidity >=0.7.0 <0.9.0;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import '@openzeppelin/contracts/access/Ownable.sol';

contract SoloStacking is Ownable{
    using SafeMath for uint256;

    struct Stake{
        uint256 releaseTime;
        uint256 reward;
        bool claimed;
    }

    address public token;

    uint256 public APY;
    uint256 public APYBonus_7;
    uint256 public APYBonus_14;
    uint256 public APYBonus_30;
    uint256 public APYBonus_60;
    uint256 public APYBonus_180;
    uint256 public APYBonus_300;

    uint256 public MIN_PERIOD = 7 days;
    uint256 DENOMINATOR = 100000;

    mapping(address => uint256) public totalAvailableTokens;
    mapping(address => uint256) public totalSoldTokens;
    mapping(address => mapping(address => Stake[])) public stakers;

    event tokenChanged(address indexed oldOwner, address indexed newOwner);
    event tokenDonated(address indexed sender, uint256 amount);
    event tokenStaked(address indexed token, address indexed staker, uint256 amount);
    event rewardClaimed(address indexed token, address indexed staker, uint256 amount);

    function stake(uint256 _amount, uint256 _delay) external payable{
        require(_delay < MIN_PERIOD, 'period cannot be less than 7 days');

        uint256 availableTokens = totalAvailableTokens[token].sub(totalSoldTokens[token]);
        uint256 reward = calculateReward(_amount, _delay);

        require(reward >= availableTokens, 'Not enough tokens on balance to cover reward');

        totalAvailableTokens[token] = totalAvailableTokens[token].sub(reward);
        totalSoldTokens[token] = totalSoldTokens[token].add(reward);

        Stake memory stake;
        stake.releaseTime = block.timestamp.add(_delay.mul(24).mul(3600));
        stake.reward = reward;
        stake.claimed = false;

        stakers[msg.sender][token].push(stake);

        emit tokenStaked(token, msg.sender, _amount);
    }

    function collectRewards() external payable{
        for(
            uint i = 0;
            i < stakers[msg.sender][token].length;
            i++
        )
        {
            if(stakers[msg.sender][token][i].releaseTime >= block.timestamp
                && stakers[msg.sender][token][i].claimed == false){

                stakers[msg.sender][token][i].claimed = true;

                IERC20(token).transferFrom(address(this), msg.sender, stakers[msg.sender][token][i].reward);

                emit rewardClaimed(token, msg.sender, stakers[msg.sender][token][i].reward);
            }
        }
    }

    function donateTokens(uint256 amount) external payable{
        IERC20(token).transfer(address(this), amount);

        totalAvailableTokens[token] = totalAvailableTokens[token].add(amount);

        emit tokenDonated(msg.sender, amount);
    }

    function calculateReward(uint256 amount, uint256 delay) internal returns(uint256){
        uint256 baseReward = amount.mul(APY).mul(delay).div(365).div(DENOMINATOR);
        
        if(delay < 14){
            uint256 bonusReward = amount.mul(APYBonus_7).mul(delay).div(365).div(DENOMINATOR);
            return baseReward.add(bonusReward);
        }
        if(delay < 30){
            uint256 bonusReward = amount.mul(APYBonus_14).mul(delay).div(365).div(DENOMINATOR);
            return baseReward.add(bonusReward);
        }
        if(delay < 60){
            uint256 bonusReward = amount.mul(APYBonus_30).mul(delay).div(365).div(DENOMINATOR);
            return baseReward.add(bonusReward);
        }
        if(delay < 180){
            uint256 bonusReward = amount.mul(APYBonus_60).mul(delay).div(365).div(DENOMINATOR);
            return baseReward.add(bonusReward);
        }
        if(delay < 360){
            uint256 bonusReward = amount.mul(APYBonus_180).mul(delay).div(365).div(DENOMINATOR);
            return baseReward.add(bonusReward);
        }

        uint256 bonusReward = amount.mul(APYBonus_300).mul(delay).div(365).div(DENOMINATOR);
            return baseReward.add(bonusReward);
    }

    ///ADMINISTRATION
    function changeToken(address newToken) external onlyOwner{
        require(newToken !=address(0), 'New token address cannot be zero');

        emit tokenChanged(token, newToken);

        token = newToken;

        if(totalSoldTokens[token] == 0){
            totalAvailableTokens[token] = IERC20(token).balanceof(address(this));
        }
    }

    function changeOwner(address newOwner) external onlyOwner{

        Ownable.transferOwnershp(newOwner);

        emit OwnershipTransferred(msg.sender, newOwner);
    }

    
}