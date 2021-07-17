from scripts.setup_burnTest import main
from brownie import *

def test_burn():

    main()

    SoloStaking[0].donateTokens(int(90), {'from' : accounts[2]})

    SoloStaking[0].burnTokens(ERC20Mock[0], accounts[3])

    
    res = SoloStaking[0].getTotalAvailableTokens.call(ERC20Mock[0])
    res1 = ERC20Mock[0].balanceOf.call(accounts[3])

    assert res == 0
    assert res1 == 90