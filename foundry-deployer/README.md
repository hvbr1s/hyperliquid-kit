# Fordefi Foundry Contract Deployer

## Overview
This script deploys a smart contract on HyperEVM using Foundry for compilation and TypeScript for deployment, with Fordefi as the RPC provider and a Fordefi vault as the signer. For this example we'll be deploying a `HyperCoreWorker` contract that demonstrates how to interact with HyperCore's read precompiles and write actions.

## What We're Deploying

The deployment script deploys a `HyperCoreWorker` contract that inherits from both `L1Read.sol` and `CoreWriter.sol` contracts. This contract provides a comprehensive interface for both reading from and writing to HyperCore through EVM precompiles and system contracts.

### HyperCore Read Precompiles

The testnet EVM provides read precompiles that allow querying HyperCore information. The precompile addresses start at `0x0000000000000000000000000000000000000800` and have methods for querying information such as:

- **Perps positions** - User's perpetual trading positions
- **Spot balances** - User's spot token balances  
- **Vault equity** - User's vault equity and locked amounts
- **Staking delegations** - User's staking delegation information
- **Oracle prices** - Real-time oracle and mark prices
- **L1 block number** - Current L1 block number
- **Asset information** - Perp and spot asset metadata
- **Token supply** - Token supply and circulation data

The values are guaranteed to match the latest HyperCore state at the time the EVM block is constructed.

### L1Read.sol Contract

The `L1Read.sol` contract (located in `precompiles/L1Read.sol`) provides a Solidity interface for all the read precompiles. It includes:

- **Position queries** - Get user's perp positions with leverage and isolation status
- **Balance queries** - Get spot balances, vault equity, and withdrawable amounts
- **Staking queries** - Get delegation and staking information
- **Price queries** - Get mark prices, oracle prices, and spot prices
- **Asset metadata** - Get perp asset info, spot info, and token information

### CoreWriter Contract

A system contract is available at `0x3333333333333333333333333333333333333333` for sending transactions from the HyperEVM to HyperCore. It burns ~25,000 gas before emitting a log to be processed by HyperCore as an action. The `CoreWriter.sol` contract (located in `precompiles/CoreWriter.sol`) provides the interface for this functionality.

### Combined Functionality

The `HyperCoreWorker` contract combines both read and write capabilities, allowing you to:
- **Read HyperCore state** - Query positions, balances, prices, and metadata
- **Write HyperCore actions** - Send limit orders, vault transfers, staking operations, and more
- **Build complex DeFi applications** - Create sophisticated trading strategies and automated systems

### Example Usage

As an example, this call queries the third perp oracle price on testnet:

```bash
cast call 0x0000000000000000000000000000000000000807 0x0000000000000000000000000000000000000000000000000000000000000003 --rpc-url https://rpc.hyperliquid-testnet.xyz/evm
```

To convert to floating point numbers, divide the returned price by `10^(6 - szDecimals)` for perps and `10^(8 - base asset szDecimals)` for spot.

Precompiles called on invalid inputs such as invalid assets or vault address will return an error and consume all gas passed into the precompile call frame. Precompiles have a gas cost of `2000 + 65 * output_len`.


## Prerequisites
Ensure you have the following set up before running the script:

1. **Node.js and npm** installed
2. **TypeScript** installed globally (`npm install -g typescript`)
3. **Foundry** installed (see [Foundry Book](https://book.getfoundry.sh/getting-started/installation))
4. **Fordefi API Credentials:**
   - `FORDEFI_API_USER_TOKEN` must be set in a `.env` file
   - A private key file located at `./fordefi_secret/private.pem`
   - Your Fordefi EVM Vault address

## Installation

1. **Install project dependencies:**
   ```sh
   npm install --save-dev typescript ts-node @types/node
   npm install ethers @fordefi/web3-provider dotenv
   ```

2. **Set up environment variables:**
   - Create a `.env` file in the project root:
     ```sh
     FORDEFI_API_USER_TOKEN=your_token_here
     ```
   - Place your Fordefi API Signer private key in `./fordefi_secret/private.pem`

3. **Configure your deployment:**
   - Update the vault address in `script/deploy.ts`:
     ```typescript
     address: "0x...", // Replace with your Fordefi EVM Vault address
     ```

## Activate Big HyperEVM Blocks for your account:

Use this tool to switch to big blocks:

[https://hyperevm-block-toggle.vercel.app/](https://hyperevm-block-toggle.vercel.app/)


## Deployment Process

1. **Compile your contract with Foundry:**
   ```sh
   forge build
   ```
   This will generate the contract artifacts in the `out` directory.

2. **Deploy the contract:**
   ```sh
   npx ts-node script/deploy.ts
   ```
  
  or

  ```bash
  npm run deploy
  ```

## Network Configuration

The deployment script is configured in `script/deploy.ts`. By default, it's set up for HyperEVM Testnet (chainId: 998), but you can modify the following parameters for your target network:

```typescript
const chainId = 998;
const config = {
  // ...
  rpcUrl: "https://rpc.hyperliquid-testnet.xyz/evm"
```
## Verify Contract after deployment:

```bash
forge verify-contract \
  --rpc-url <rpc_https_endpoint> \
  <address> \
  <contract_file>:<contract_name> \
  --verifier blockscout \
  --verifier-url <blockscout_homepage_explorer_url>/api/
```
for example on HyperEVM testnet:

```bash
forge verify-contract 0x6e4DEDc15b47A2B13F14882FB5f2f7328163b512 src/HyperCoreWorker.sol:HyperCoreWorker \
  --chain-id 998 \
  --verifier sourcify \
  --verifier-url https://sourcify.parsec.finance/verify
```

on HyperEVM mainnet we would use:

```bash
forge verify-contract \
  --rpc-url https://rpc.hyperliquid.xyz/evm \
  --verifier blockscout \
  --verifier-url 'https://www.hyperscan.com/api/' \
  0x6e4DEDc15b47A2B13F14882FB5f2f7328163b512 \
  src/HyperCoreWorker.sol:HyperCoreWorker
```

Check your contract on the explorer, for example:

```bash
https://testnet.purrsec.com/address/0x6e4DEDc15b47A2B13F14882FB5f2f7328163b512/contract
```

## Troubleshooting

If you encounter errors:
1. Verify all environment variables are properly set
2. Ensure your Fordefi vault has sufficient HYPE funds for deployment and your HyperCore account has some USDC
3. Check that your Fordefi private key file is correctly formatted and accessible in the `/secret` folder
4. Verify the contract was compiled successfully (`out` directory should contain your contract artifacts)
5. Make sure the chainId and RPC URL match your target network
6. Check that the artifact path in `deploy.ts` matches your contract name