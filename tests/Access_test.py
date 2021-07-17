import brownie
from scripts.setup_accessTest import main
from brownie import *

def test_changeToken():
    main()

    with brownie.reverts('Ownable: caller is not the owner'):
        SoloStaking[0].changeToken(ERC20Mock[1], {'from' : accounts[1]})

    SoloStaking[0].changeToken(ERC20Mock[1], {'from' : accounts[2]})

def test_changeOwner():

    main()

    with brownie.reverts('Ownable: caller is not the owner'):
        SoloStaking[0].changeOwner(accounts[3], {'from' : accounts[1]})

    SoloStaking[0].changeOwner(accounts[3], {'from' : accounts[2]})
