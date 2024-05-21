# HeadSeason Smart Contract

## Overview
The HeadSeason Smart Contract is central to orchestrating seasonal transitions within the PCO ecosystem. It manages the lifecycle of each season, including creation and tracking of season-specific ValidatorPool and Candidate contracts.

## Contract Specifications
- **Compiler Version**: Solidity 0.8.20
- **License**: MIT

## Functionality
- Facilitates the creation of new seasons with their unique operational timelines.
- Updates ValidatorPool contract addresses across various related contracts.
- Provides retrieval of active season's contract addresses for staking and validation operations.

## Events
- CreatedSeason: Emitted when a new season is created, logging the newly deployed ValidatorPool and Candidate contract addresses.

## Constructor
Sets up essential contract addresses for tokens, lands, and sales, as well as initializing the tax amount.

## Primary Functions
1. createSeason: Deploys new ValidatorPool and Candidate contracts, ensuring the smooth transition between seasons.
2. updateTax: Adjusts the tax amount as dictated by the active ValidatorPool contract.
3. getSeasonRelatedContracts: Retrieves the contract addresses for the validator pool and candidates associated with a specific season.
4. addStakeContract: Adds the staking contract address post-deployment.
5. addOperator: Gives operator roles to specified addresses.
6. removeOperator: Removes operator privileges from specified addresses.
7. addNftMarketContracts: Establishes the NFT Sales and Marketplace contract addresses post-deployment.
Reach out for [support](info@pcometaearth.com) or further queries regarding the smart contract.

