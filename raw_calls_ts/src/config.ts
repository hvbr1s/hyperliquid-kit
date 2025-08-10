import { FordefiProviderConfig } from '@fordefi/web3-provider';
import dotenv from 'dotenv';
import fs from 'fs'

dotenv.config();

export const CONTRACT_ADDRESS = "0x4926125d40787157c77A02899CE95dAe60CdaADb";

// This call data transfers USDC from your Spot to your Perps account on HyperEVM testnet
export const CALL_DATA = "0xdf42f68f00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000086010000070000000000000000000000000000000000000000000000000de0b6b3a764000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"

export const fordefiConfig: FordefiProviderConfig = {
    chainId: 999,
    address: '0x8BFCF9e2764BC84DE4BBd0a0f5AAF19F47027A73', // The Fordefi EVM Vault that will call the contract
    apiUserToken: process.env.FORDEFI_API_USER_TOKEN ?? (() => { throw new Error('FORDEFI_API_USER_TOKEN is not set'); })(), 
    apiPayloadSignKey: fs.readFileSync('./secret/private.pem', 'utf8') ?? (() => { throw new Error('PEM_PRIVATE_KEY is not set'); })(),
    rpcUrl: 'https://rpc.hyperliquid.xyz/evm',
    skipPrediction: false
};