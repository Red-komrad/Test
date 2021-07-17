from scripts.setup_StakeTest import main
from brownie import *

def test_stake():

    main()

    SoloStaking[0].donateTokens(int(90), {'from' : accounts[2]})

    SoloStaking[0].stake(1000, 100, {'from': accounts[3]})

    res = SoloStaking[0].getTotalAvailableTokens.call(ERC20Mock[0])
    res1 = SoloStaking[0].getTotalSoldTokens.call(ERC20Mock[0])

    assert res == 73
    assert res1 == 17
