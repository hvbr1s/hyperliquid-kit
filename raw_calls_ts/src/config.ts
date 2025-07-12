import { FordefiProviderConfig } from '@fordefi/web3-provider';
import dotenv from 'dotenv';
import fs from 'fs'

dotenv.config();

export const CONTRACT_ADDRESS = process.env.CONTRACT_ADDRESS;

export const CALL_DATA = "0x0efe6a8b000000000000000000000000a0b86991c6218b36c1d19d4a2e9eb0ce3606eb4800000000000000000000000000000000000000000000000000000000000186a00000000000000000000000000000000000000000000000000000000000000000"

export const fordefiConfig: FordefiProviderConfig = {
    chainId: 999,
    address: '0x5b7a034488f0bde8bad66f49cf9587ad40b6c757', // The Fordefi EVM Vault that will call the contract
    apiUserToken: process.env.FORDEFI_API_USER_TOKEN ?? (() => { throw new Error('FORDEFI_API_USER_TOKEN is not set'); })(), 
    apiPayloadSignKey: fs.readFileSync('./ecret/private.pem', 'utf8') ?? (() => { throw new Error('PEM_PRIVATE_KEY is not set'); })(),
    rpcUrl: 'https://rpc.hypurrscan.io',
    skipPrediction: false
};