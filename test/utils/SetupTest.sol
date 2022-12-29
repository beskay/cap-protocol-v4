// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./Constants.sol";

import "../../src/Trade.sol";
import "../../src/Pool.sol";
import "../../src/Store.sol";
import "../../src/CLP.sol";
import "../../src/mocks/MockChainlink.sol";
import "../../src/mocks/MockToken.sol";

contract SetupTest is Constants {
    Trade public trade;
    Pool public pool;
    Store public store;
    CLP public clp;

    MockToken public usdc;
    MockChainlink public chainlink;

    function setUp() public virtual {
        usdc = new MockToken("USDC", "USDC", 6);
        //console.log("USDC token deployed to", address(usdc));

        chainlink = new MockChainlink();
        //console.log("Chainlink deployed to", address(chainlink));

        store = new Store();
        //console.log("Store deployed to", address(store));

        trade = new Trade();
        //console.log("Trade deployed to", address(trade));

        pool = new Pool();
        //console.log("Pool deployed to", address(pool));

        clp = new CLP(address(store));
        //console.log("CLP deployed to", address(clp));

        // Link
        store.link(address(trade), address(pool), address(usdc), address(clp));
        trade.link(address(chainlink), address(pool), address(store));
        pool.link(address(trade), address(store), treasury);
        //console.log("Contracts linked");

        // Setup markets
        store.setMarket(
            "ETH-USD",
            Store.Market({
                symbol: "ETH-USD",
                feed: ethFeed,
                maxLeverage: 50,
                maxOI: 5000000 * CURRENCY_UNIT,
                fee: 100,
                fundingFactor: 5000,
                minSize: 20 * CURRENCY_UNIT,
                minSettlementTime: 1 minutes
            })
        );
        store.setMarket(
            "BTC-USD",
            Store.Market({
                symbol: "BTC-USD",
                feed: btcFeed,
                maxLeverage: 50,
                maxOI: 5000000 * CURRENCY_UNIT,
                fee: 100,
                fundingFactor: 5000,
                minSize: 20 * CURRENCY_UNIT,
                minSettlementTime: 1 minutes
            })
        );

        //console.log("Markets set up.");

        // Setup prices
        chainlink.setPrice(ethFeed, 5000); // 1 ETH = 5000 USD
        chainlink.setPrice(btcFeed, 100_000); // 1 BTC = 100k USD

        // Mint and approve some mock USDC
        usdc.mint(INITIAL_BALANCE);
        usdc.approve(address(store), INITIAL_BALANCE);

        // To user
        vm.startPrank(user);
        usdc.mint(INITIAL_BALANCE);
        usdc.approve(address(store), INITIAL_BALANCE);
        vm.stopPrank();

        // To user2
        vm.startPrank(user2);
        usdc.mint(INITIAL_BALANCE);
        usdc.approve(address(store), INITIAL_BALANCE);
        vm.stopPrank();
    }
}
