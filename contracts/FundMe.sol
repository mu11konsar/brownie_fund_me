// SPDX-License-Identifier: MIT

pragma solidity >=0.6.6 <0.9.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract FundMe {
    using SafeMathChainlink for uint256;

    address public owner;
    address[] public funders;

    AggregatorV3Interface public priceFeed;

    mapping(address => uint256) public addressToAmountFunded;

    constructor(address _priceFeed) public {
        owner = msg.sender;
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    function fund() public payable {
        // $50
        uint256 minimumUSD = 50;
        require(
            getConversionRate(msg.value) >= minimumUSD * (10**18) * (10**8),
            "Too little, Please send more than $50"
        );

        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Sorry, for owner only.");
        _;
    }

    function withdraw() public payable onlyOwner {
        // only owner can withdraw
        uint256 balance = address(this).balance;
        msg.sender.transfer(balance);
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
    }

    function getVersion() public view returns (uint256) {
        // Chainlink interface address
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(
        //     0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
        // );
        return priceFeed.version();
    }

    function getPrice() public view returns (uint256) {
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(
        //     0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
        // );
        (
            ,
            /*uint80 roundId*/
            int256 price, /*uint256 startedAt*/ /*uint256 timeStamp*/ /*uint80 answerInRound*/
            ,
            ,

        ) = priceFeed.latestRoundData();
        // ethPrice * 10 ** 8
        return uint256(price);
    }

    function getConversionRate(uint256 ethAmount)
        public
        view
        returns (uint256)
    {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount);
        // USD * 10 ** 8
        return ethAmountInUsd;
    }

    function getEntranceFee() public view returns (uint256) {
        // minimumUSD
        uint256 minimumUSD = 50 * 10**8;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        return (minimumUSD * precision) / price;
    }
}
