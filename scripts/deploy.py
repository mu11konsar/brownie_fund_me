from brownie import FundMe, MockV3Aggregator, config, network
from scripts.helpful_script import get_account, deploy_mocks

LOCAL_BLOCKCHAIN_ENVIRONMENTS = ["development", "ganache-local"]


def deploy_fund_me():
    account = get_account()

    # pass the price feed address to FundMe contract

    # if we are on rinkeby, use the associated address
    # otherwise, deploy mocks
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        price_feed_address = config["networks"][network.show_active()][
            "eth_usd_price_feed"
        ]
    else:
        deploy_mocks()
        price_feed_address = MockV3Aggregator[-1].address

    fund_me = FundMe.deploy(
        price_feed_address,
        {"from": account},
        publish_source=config["networks"][network.show_active()].get("verify"),
    )
    print(f"Contract deploy to {fund_me.address}")
    return fund_me


def main():
    deploy_fund_me()
