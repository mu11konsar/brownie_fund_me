from brownie import network, config, accounts, MockV3Aggregator
from web3 import Web3

FORKED_LOCAL_ENVIRONMENTS = ["mainnet-fork", "mainnet-fork-dev"]
LOCAL_BLOCKCHAIN_ENVIRONMENTS = ["development", "ganache-local"]

DECIMAL = 8
STARTING_PRICE = 2000000000


def get_account():
    if (
        network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS
        or network.show_active() in FORKED_LOCAL_ENVIRONMENTS
    ):
        return accounts[0]
    if network.show_active() == "rinkeby":
        return accounts.add(config["wallets"]["from_key"])


def deploy_mocks():
    print(f"The active network is {network.show_active()}")
    if len(MockV3Aggregator) <= 0:
        print("Deploy Mocks...")
        MockV3Aggregator.deploy(DECIMAL, STARTING_PRICE, {"from": get_account()})
    print("Mocks Deployed!")
