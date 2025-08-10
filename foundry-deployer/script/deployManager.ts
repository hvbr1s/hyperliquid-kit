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
const chainId = 999;
const fordefiEvmVaulAddress = "0x8BFCF9e2764BC84DE4BBd0a0f5AAF19F47027A73";
const network = "https://rpc.hyperliquid.xyz/evm";

// 3. Deployment parameters for Manager contract
const KHYPE_ADDRESS = "0xfD739d4e423301CE9385c1fb8850539D657C296D";
const HYPE_USD_ADDRESS = "0xD032D91b02123DAE424923EA36eA5126c2f6f5e5";
const ORACLE_ADDRESS = "0x"; // TODO: Replace with oracle contract address

// 4. Construct FordefiWeb3Provider config
const config: FordefiProviderConfig = {
  chainId,
  address: fordefiEvmVaulAddress,
  apiUserToken: FORDEFI_API_USER_TOKEN,
  apiPayloadSignKey: PEM_PRIVATE_KEY,
  rpcUrl: network,
  skipPrediction: true
};

async function main() {
  // A) Create the Fordefi provider
  const fordefiProvider = await new FordefiWeb3Provider(config);

  // B) Wrap the fordefiProvider with Ethers.js
  const provider = new ethers.BrowserProvider(fordefiProvider);
  const signer = await provider.getSigner();

  // C) Load the Foundry artifact for Manager
  const artifactPath = path.join(__dirname, "..", "out", "Manager.sol", "Manager.json");
  const artifact = JSON.parse(fs.readFileSync(artifactPath, "utf8"));

  // D) Get Foundry bytecode
  const abi = artifact.abi;
  let bytecode = artifact.bytecode;
  if (bytecode && bytecode.object) {
    bytecode = bytecode.object;
  }

  // E) Deploy Manager contract
  const factory = new ethers.ContractFactory(abi, bytecode, signer);
  console.log("Deploying Manager contract...");
  console.log("kHYPE address:", KHYPE_ADDRESS);
  console.log("HypeUSD address:", HYPE_USD_ADDRESS);
  console.log("Oracle address:", ORACLE_ADDRESS);
  
  const manager = await factory.deploy(
    KHYPE_ADDRESS,    
    HYPE_USD_ADDRESS, 
    ORACLE_ADDRESS,   
    {
      gasLimit: ethers.parseUnits((10_000_000).toString(), "wei"),
      gasPrice: ethers.parseUnits("2", "gwei"),
    }
  );

  console.log("Manager contract deployed to:", await manager.getAddress());
  console.log("Transaction hash:", manager.deploymentTransaction()?.hash);

}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("Error deploying Manager contract:", err);
    process.exit(1);
  });

// Deploy command -> npx ts-node script/deployManager.ts
