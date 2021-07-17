pragma solidity ^0.8.0;

import "./OpenZeppelin/token/ERC20/IERC20.sol";
import "./OpenZeppelin/token/ERC20/ERC20.sol";
import "./OpenZeppelin/utils/math/SafeMath.sol";
import "./OpenZeppelin/access/Ownable.sol";

contract SoloStaking is Ownable{
    using SafeMath for uint256;

    address public constant WETH =
        address(0x24572F0e83D6cF79F60495c6eE05e0556D38ad83);
    address public constant SwapRouter =
        address(0xE5CFF588c5225d5519b6a9C53d05B1c8Fdd65D17);
    address public constant SwapFactory =
        address(0x5d86475e1FC3788D6DaD39fAcB25241587c90698);

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

    uint256 public MIN_PERIOD = 7;
    uint256 DENOMINATOR = 100000;

    mapping(address => uint256) private totalAvailableTokens;
    mapping(address => uint256) private totalSoldTokens;
    mapping(address => mapping(address => Stake[])) private stakers;

    event tokenChanged(address indexed oldOwner, address indexed newOwner);
    event tokenDonated(address indexed sender, uint256 amount);
    event tokenStaked(address indexed token, address indexed staker, uint256 amount);
    event rewardClaimed(address indexed token, address indexed staker, uint256 amount);
    event APYChanged(uint256 value);
    event APYBonus7Changed(uint256 value);
    event APYBonus14Changed(uint256 value);
    event APYBonus30Changed(uint256 value);
    event APYBonus60Changed(uint256 value);
    event APYBonus180Changed(uint256 value);
    event APYBonus300Changed(uint256 value);
    event tokensBurned(address destination, uint256 amount);

    constructor(address _token){
        require(_token != address(0), "Incorrect address of pool token");
        token = _token;
        APY = 500;
        APYBonus_7 = 700;
        APYBonus_14 = 1400;
        APYBonus_30 = 3000;
        APYBonus_60 = 6000;
        APYBonus_180 = 18000;
        APYBonus_300 = 30000;
    }

    function stake(uint256 _amount, uint256 _delay) external payable{
        require(_delay >= MIN_PERIOD, 'period cannot be less than 7 days');

        uint256 availableTokens = totalAvailableTokens[token].sub(totalSoldTokens[token]);
        uint256 reward = calculateReward(_amount, _delay);

        require(reward <= availableTokens, 'Not enough tokens on balance to cover reward');

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

                IERC20(token).approve(msg.sender, type(uint256).max);
                IERC20(token).transferFrom(address(this), msg.sender, stakers[msg.sender][token][i].reward);
                IERC20(token).approve(msg.sender, uint256(0));

                totalSoldTokens[token] = totalSoldTokens[token].sub(stakers[msg.sender][token][i].reward);

                emit rewardClaimed(token, msg.sender, stakers[msg.sender][token][i].reward);
            }
        }
    }

    function donateTokens(uint256 amount) external {

        IERC20(token).transferFrom(msg.sender, address(this), amount);

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
    
    function burnTokens(address token, address destination) external onlyOwner{
        uint256 availableTokens = totalAvailableTokens[token].sub(totalSoldTokens[token]);

        IERC20(token).approve(destination, type(uint256).max);
        IERC20(token).transfer(destination, availableTokens);
        IERC20(token).approve(destination, uint256(0));

        totalAvailableTokens[token] = 0;

        emit tokensBurned(destination, availableTokens);
    }

    function changeToken(address newToken) external onlyOwner{
        require(newToken !=address(0), 'New token address cannot be zero');

        emit tokenChanged(token, newToken);

        token = newToken;

        if(totalSoldTokens[token] == 0){
            totalAvailableTokens[token] = IERC20(token).balanceOf(address(this));
        }
    }

    function changeOwner(address newOwner) external onlyOwner{

        transferOwnership(newOwner);

        emit OwnershipTransferred(msg.sender, newOwner);
    }

    function changeAPY(uint256 _APY) external onlyOwner{

        APY = _APY;

        emit APYChanged(_APY);
    }

    function changeAPYBonus7(uint256 _APY) external onlyOwner{

        APYBonus_7 = _APY;

        emit APYChanged(_APY);
    }
    

    function changeAPYBonus14(uint256 _APY) external onlyOwner{

        APYBonus_14 = _APY;

        emit APYChanged(_APY);
    }
    

    function changeAPYBonus30(uint256 _APY) external onlyOwner{

        APYBonus_30 = _APY;

        emit APYChanged(_APY);
    }
    

    function changeAPYBonus60(uint256 _APY) external onlyOwner{

        APYBonus_60 = _APY;

        emit APYChanged(_APY);
    }
    

    function changeAPYBonus180(uint256 _APY) external onlyOwner{

        APYBonus_180 = _APY;

        emit APYChanged(_APY);
    }
    

    function changeAPYBonus300(uint256 _APY) external onlyOwner{

        APYBonus_300 = _APY;

        emit APYChanged(_APY);
    }

    function getTotalAvailableTokens(address _token) external returns(uint256){
        return totalAvailableTokens[_token];
    }

    function getTotalSoldTokens(address _token) external returns(uint256){
        return totalSoldTokens[_token];
    }

}