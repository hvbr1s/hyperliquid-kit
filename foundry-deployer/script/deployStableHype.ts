import fs from "fs";
import path from "path";
import dotenv from "dotenv";
import { ethers } from "ethers";
import { FordefiWeb3Provider, FordefiProviderConfig } from "@fordefi/web3-provider";

dotenv.config();

// 1. Configure your Fordefi secrets
const FORDEFI_API_USER_TOKEN = process.env.FORDEFI_API_USER_TOKEN ?? 
  (() => { throw new Error("FORDEFI_API_USER_TOKEN is not set"); })();
const privateKeyFilePath = "./secret/private.pem";
const PEM_PRIVATE_KEY = fs.readFileSync(privateKeyFilePath, "utf8") ??
  (() => { throw new Error("PEM_PRIVATE_KEY is not set"); })();


// 2. Chain ID and network configuration
//    Example: deploying on HyperEVM Testnet (chainId=998)
//    https://rpc.hyperliquid.xyz/evm || https://rpc.hyperliquid-testnet.xyz/evm
const chainId = 999;
const fordefiEvmVaulAddress = "0x8BFCF9e2764BC84DE4BBd0a0f5AAF19F47027A73" // Your Fordefi EVM Vault address
const network = "https://rpc.hyperliquid.xyz/evm";

// 3. Deployment params
const managerAddress = "0x8BFCF9e2764BC84DE4BBd0a0f5AAF19F47027A73";

// 3. Construct FordefiWeb3Provider config
const config: FordefiProviderConfig = {
  chainId,
  address: fordefiEvmVaulAddress,
  apiUserToken: FORDEFI_API_USER_TOKEN,
  apiPayloadSignKey: PEM_PRIVATE_KEY,
  rpcUrl: network, // Fallback RPC
  skipPrediction: true
};

async function main() {
  // A) Create the Fordefi provider
  const fordefiProvider = await new FordefiWeb3Provider(config);

  // B) Wrap the fordefiProvider with Ethers.js
  const provider = new ethers.BrowserProvider(fordefiProvider);
  const signer = await provider.getSigner();

  // C) Load the Foundry artifact for HypeUSD
  const artifactPath = path.join(__dirname, "..", "out", "StableHype.sol", "HypeUSD.json");
  const artifact = JSON.parse(fs.readFileSync(artifactPath, "utf8"));

  // D) Get Foundry bytecode
  const abi = artifact.abi;
  let bytecode = artifact.bytecode;
  if (bytecode && bytecode.object) {
    bytecode = bytecode.object;
  }

  // E) Deploy the contract
  const factory = new ethers.ContractFactory(abi, bytecode, signer);
  console.log("Deploying contract...");
  console.log("Manager address:", managerAddress);

  const hypeUSD = await factory.deploy(
    managerAddress, // Constructor parameter -> manager address
    {
      gasLimit: ethers.parseUnits((10_000_000).toString(), "wei"),
      gasPrice: ethers.parseUnits("2", "gwei"),
    }
  );

  console.log("Contract deployed to:", await hypeUSD.getAddress());
  console.log("Transaction hash:", hypeUSD.deploymentTransaction()?.hash);
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("Error deploying contract: ", err);
    process.exit(1);
  });