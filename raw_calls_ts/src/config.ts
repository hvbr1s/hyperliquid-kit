import { FordefiProviderConfig } from '@fordefi/web3-provider';
import dotenv from 'dotenv';
import fs from 'fs'

dotenv.config();

export const CONTRACT_ADDRESS = "0xd6DA4F72a934D58eED204b0E880E09bA7e832Fc0";

// This call data transfers USDC from your Spot to your Perps account on HyperEVM testnet
export const CALL_DATA = "0x2d9d5db600000000000000000000000000000000000000000000000000000000000000320000000000000000000000000000000000000000000000000000000000000001"

export const fordefiConfig: FordefiProviderConfig = {
    chainId: 998,
    address: '0x5b7a034488f0bde8bad66f49cf9587ad40b6c757', // The Fordefi EVM Vault that will call the contract
    apiUserToken: process.env.FORDEFI_API_USER_MACBOOK_PRO_BOT ?? (() => { throw new Error('FORDEFI_API_USER_TOKEN is not set'); })(), 
    apiPayloadSignKey: fs.readFileSync('./secret/private.pem', 'utf8') ?? (() => { throw new Error('PEM_PRIVATE_KEY is not set'); })(),
    rpcUrl: 'https://rpc.hyperliquid-testnet.xyz/evm',
    skipPrediction: false
};