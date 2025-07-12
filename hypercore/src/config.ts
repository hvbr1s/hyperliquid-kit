import { FordefiProviderConfig } from '@fordefi/web3-provider';
import fs from 'fs';
import dotenv from 'dotenv';

dotenv.config()

export interface HyperliquidConfig { 
    destination?: `0x${string}`;
    amount?: string,
    agentPk?: string
};

// Configure the Fordefi provider
export const fordefiConfig: FordefiProviderConfig = {
    chainId: 42161, // Arbitrum
    address: '0x5b7a034488f0bde8bad66f49cf9587ad40b6c757', // The Fordefi EVM Vault that will sign the message
    apiUserToken: process.env.FORDEFI_API_USER_TOKEN ?? (() => { throw new Error('FORDEFI_API_USER_TOKEN is not set'); })(), 
    apiPayloadSignKey: fs.readFileSync('./secret/private.pem', 'utf8') ?? (() => { throw new Error('PEM_PRIVATE_KEY is not set'); })(),
    rpcUrl: 'https://1rpc.io/arb',
    skipPrediction: true 
};

export const hyperliquidConfig: HyperliquidConfig = {
    destination: fordefiConfig.address, // Change to your destination address
    amount: "1",
    agentPk: process.env.HYPERCORE_API_AGENT_PK ?? (() => { throw new Error('HYPERCORE_API_AGENT_PK is not set'); })(),
};