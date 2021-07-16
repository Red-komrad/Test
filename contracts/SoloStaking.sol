pragma solidity >=0.7.0 <0.9.0;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract SoloStacking is Ownable{
    using SafeMath for uint256;

    struct APYBonuses{
        uint256 APYBonus_7;
        uint256 APYBonus_14;
        uint256 APYBonus_30;
        uint256 APYBonus_60;
        uint256 APYBonus_180;
        uint256 APYBonus_300;
    };

    address public token;
    uint256 public APY;
    APYBonuses public APYBONUSES;

    uint256 public MIN_PERIOD = 7 days;
    uint256 DENOMINATOR = 100000;

    mapping(address => uint256) public totalAvailableTokens;
    mapping(address => uint256) public totalSoldTokens;

    event tokenChanged(address, address);

    function stake(uint256 amount, uint256 delay) external payable{
        require(delay < MIN_PERIOD, 'period cannot be less than 7 days');

        uint256 availableTokens = totalAvailableTokens[token].sub(totalSoldTokens[token]);
        uint256 reward = calculateReward(amount, delay);

        require(reward >= availableTokens, 'Not enough tokens on balance to cover reward');


    }

    function calculateReward(uint256 amount, uint256 delay) private internal returns(uint256){
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

        uint256 bonusReward = amount.mul(APYBonus_360).mul(delay).div(365).div(DENOMINATOR);
            return baseReward.add(bonusReward);
    }

    ///ADMINISTRATION
    function changeToken(address newToken) external onlyOwner{
        require(newToken !=0, 'New token address cannot be zero');

        emit tokenChanged(token, newToken);

        token = newToken;
    }

    function changeOwner(address newOwner) external onlyOwner{

        Ownable.transferOwnershp(newOwner);

        emit OwnershipTransferred(msg.sender, newOwner);
    }

    
}