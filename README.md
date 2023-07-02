# abap-nft

Mint a NFT in SAP ABAP - using proUBC and the Provide stack!

This ABAP code example demonstrates how to use proUBC and the Provide API stack to mint an ERC721 NFT on a given Ethereum compatible blockchain.

## Pre requisites (do these first before running code!)
- Clone [proUBC](https://github.com/provideplatform/proUBC) to your SAP system
- Activate the proubc SICF node
- Configure the SSL certificates needed for Provide stack (see certificates directory of the proUBC repo)
- Create an account at https://shuttle.provide.services. Create organization at minimum (workgroup creation is recommended but optional)

## Configuration

### Postman configuration
- Import the provided Postman collection. 
- Maintain the shuttle_email and shuttle_password collection variables accordingly
- Maintain SAP user id and password in the Postman collection
- Run the HTTP requests in the following order:
1. Get access token with login
2. List organizations
3. Generate long-dated refresh token
4. Get access token from refresh token
5. Create account (Do both Polygon Mumbai and Celo Alfajores)
6. List accounts (take note of the address field for later!)
7. SAP / proUBC fetch token
8. SAP / proUBC tenants create

Steps 7 an 8 populate your Provide credentials to the SAP system. 

### Wallet configuration
For these self-custody transactions, you'll need some gas tokens to complete the NFT mint transaction. Use the wallet addresses you noted earlier to request gas from the given network testnet faucet.

Polygon Mumbai : https://faucet.polygon.technology 
Celo Alfajores : https://faucet.celo.org/alfajores


### Additional SAP configuration
- Upload the json files in the abi directory of this repo to a directory in AL11
- Maintain the following entries in the zprvdabiregistry table. This can be done via execution of the class method zcl_prvd_file_helper=>update_abi_registry (be sure to check case sensitive)

## Minting NFTs through ABAP
- Open the report ZPRVD_NFT_MINT_EXAMPLE
- Run with either the following sets of parameters
- Polygon.
    1. Network ID :
    2. Contract name : CarbonEmissionsNFT
    3. Contract address :
- Celo
    1. Network ID :
    2. Contract name : ProvideTest
    3. Contract address :


## Review and reflect - what's going here?
Upon 

## Bonus : Mint a NFT in Javascript/Typescript with provide-js
For comparison sake - check out [this repo]() to see a similar integration in Javascript/Typescript to mint NFTs using the provide-js library


## Special thank yous!
Huge thanks to Nuve!
Highly recommended to take your ABAP development to a whole new level of sophistication with abapGit, CI/CD, system versioning and more :)