from brownie import *

def main():
    ERC20Mock.deploy("Test Token", "TST", {'from' : accounts[0]})
    ERC20Mock.deploy("Alt Token", "AST", {'from' : accounts[1]})
    
    SoloStaking.deploy(ERC20Mock[0], {'from' : accounts[2]})

