# **Cygnus LP Price Oracle on Starknet**


Features:
- Completely felt based, thus tx and storage costs are greatly optimised
- Adjusts price of LP Tokens to always return in 18 decimals
- Prevents price manipulations from attacks that move along constant AMM curves such as flash loans.
- Empiric price feeds
- Anyone is free to use or implement their own

Caveats:
- To use in contracts that rely on uint256 the price must be converted from a felt to a uint struct

This is a Cairo implementation of our original oracle:
```
https://github.com/CygnusDAO/cygnusdao-price-oracle/blob/main/contracts/ChainlinkNebulaOracle.sol
```

We make use of Empiric Network price feeds to bring one of the most accurate and reliable oracles in DeFi yet.

Empiric Network is a decentralized, transparent and composable oracle network, leveraging state-of-the-art zero-knowledge cryptography. They partner with the biggest market makers and the most liquid exchanges who sign and timestamp their own high quality, robust data and send it directly on-chain. Their feeds are already live in public alpha on Starknet, where they are powering the next generation of ambitious protocols such as ZKLend, CurveZero, Magnety, Canvas, FujiDAO and more. Learn more about them [here](https://empiric.network/).
