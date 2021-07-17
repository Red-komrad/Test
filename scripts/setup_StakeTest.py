from brownie import *

def main():
    ERC20Mock.deploy("Test Token", "TST", {'from' : accounts[0]})

    SoloStaking.deploy(ERC20Mock[0], {'from' : accounts[1]})

    ERC20Mock[0].mint(accounts[2], 100)

    ERC20Mock[0].approve(SoloStaking[0], 100, {'from' : accounts[2]})