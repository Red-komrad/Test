from scripts.setup_donateTest import main
from brownie import *

def test_donate():
    main()

    SoloStaking[0].donateTokens(int(90), {'from' : accounts[2]})

    res = SoloStaking[0].getTotalAvailableTokens.call(ERC20Mock[0])
    res1 = ERC20Mock[0].balanceOf.call(accounts[2])

    assert res == 90
    assert res1 == 10