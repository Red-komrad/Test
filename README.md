Solo Staking

Repository contains brownie project for solo staking smart contract.

Documentation:

token - the ERC20 token that you can stake

stake(uint256 _amount, uint256 _delay) -method for stake tokens
  _amount - number of tokens to be stake
  _dekay - span between stake and claim profit
  
function collectRewards() - method for claim rewards for staking tokens
 
function donateTokens(uint256 amount) - method for transfer tokens to smart contranct

function burnTokens(address _token, address _destination) - method for withdraw tokens from smart contranct (owner only)
  _token - token to withdraw
  _amount - amount tokens to withdraw
  
function changeToken(address _newToken) - change primary token to smart contract (owner only)
    _newToken - address of the new token
    
function changeOwner(address _newOwner) - change smart contract owner (owner only)
    _newOvner - address of the new contract owner

function changeAPY(uint256 _APY) - change APY ratio (owner only)
    _APY - new APY
    
function changeAPYBonus7(uint256 _APY) - change APY bonus for long tem stake (7+ days) (owner only)
    _APY - new APY bonus
    
function changeAPYBonus14(uint256 _APY) - change APY bonus for long tem stake (14+ days) (owner only)
    _APY - new APY bonus
    
function changeAPYBonus30(uint256 _APY) - change APY bonus for long tem stake (30+ days) (owner only)
    _APY - new APY bonus
    
function changeAPYBonus60(uint256 _APY) - change APY bonus for long tem stake (60+ days) (owner only)
    _APY - new APY bonus
    
function changeAPYBonus180(uint256 _APY) - change APY bonus for long tem stake (180+ days) (owner only)
    _APY - new APY bonus
    
function changeAPYBonus300(uint256 _APY) - change APY bonus for long tem stake (300+ days) (owner only)
    _APY - new APY bonus
    
function getTotalAvailableTokens(address _token) - returns amount of available to cover stake bonus tokens (to make SC testable)

function getTotalSoldTokens(address _token) - returns amount of reserved tokens (to make SC testable)

USAGE:
to build priject use command: brownie compile

to run all tests use command: brownie test

to run certain test ude command: brownie test <test name>

List of tests:
   Access_test
   Donate_test
   Burn_test
   Stake_test
  
 To deploy and test SC in the testnet or mainnet use the command: brownie run deploy.py --network <name of network>
