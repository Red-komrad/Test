from brownie import accounts, ERC20Mock, SoloStaking

def main():
    account = accounts.load("0xf802AD03f9b4d6a39A9f738048285007C9784bf4")
    token = ERC20Mock.deploy("GToken", "GTK", {'from' : accounts[0]})
    stake = SoloStaking.deploy(token, {'from' : account})
    token.mint(accounts[1], 10000, {'from' : accounts[0]})

    token.approve(stake, 100, {'from' : accounts[1]})
    stake.donateTokens(100, {'from' : accounts[1]})
    token.approve(stake, 0, {'from' : accounts[1]})

    stake.stake(1000, 100, {'from' : accounts[1]})
    stake.burnTokens(token, accounts[2], {'from' : account})




