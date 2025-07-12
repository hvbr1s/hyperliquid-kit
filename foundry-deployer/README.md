# Fordefi Foundry Contract Deployer

## Overview
This script deploys a smart contract on HyperEVM using Foundry for compilation and TypeScript for deployment, with Fordefi as the RPC provider and a Fordefi vault as the signer.

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

```bash
https://hyperevm-block-toggle.vercel.app/
```

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

## Network Configuration

The deployment script is configured in `script/deploy.ts`. By default, it's set up for Polygon Mainnet (chainId: 137), but you can modify the following parameters for your target network:

```typescript
const chainId = 999; // Change to your target network
const config = {
  // ...
  rpcUrl: "https://rpc.hypurrscan.io" // Change to your preferred HyperEVM fallback RPC
};
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
for example on mainnet:
```bash
forge verify-contract \
  --rpc-url https://rpc.hyperliquid.xyz/evm \
  --verifier blockscout \
  --verifier-url 'https://www.hyperscan.com/api/' \
  0x3025866DC6Cb74466e6D4ac368f1157C85F631c2 \
  src/HypercoreWorker.sol:HyperCoreInteraction
```
or on testnet:
```bash
forge verify-contract 0xd6DA4F72a934D58eED204b0E880E09bA7e832Fc0 src/CoreWriterCaller.sol:CoreWriterCaller \
  --chain-id 998 \
  --verifier sourcify \
  --verifier-url https://sourcify.parsec.finance/verify
```

Check your contract on the explorer, for example:

```bash
https://testnet.purrsec.com/address/0x9A324ec2ccB8Bd09d062F7Ba1491AB7246dB9565/contract
```

## Troubleshooting

If you encounter errors:
1. Verify all environment variables are properly set
2. Ensure your Fordefi vault has sufficient funds for deployment
3. Check that your private key file is correctly formatted and accessible
4. Verify the contract was compiled successfully (`out` directory should contain your contract artifacts)
5. Make sure the chainId and RPC URL match your target network
6. Check that the artifact path in `deploy.ts` matches your contract name