import { HyperliquidConfig, fordefiConfig, hyperliquidConfig } from './config'
import * as hl from "@nktkas/hyperliquid";
import { ethers } from 'ethers';

export async function activateBigBlocks(hyperliquidConfig: HyperliquidConfig) {
    try {
        const agentWallet = new ethers.Wallet(hyperliquidConfig.agentPk || "");

        const transport = new hl.HttpTransport({
            isTestnet: hyperliquidConfig.isTestnet
        });

        const exchClient = new hl.ExchangeClient({ wallet: agentWallet, transport: transport });
        
        console.log("Exchange client created successfully");
        console.log("Submitting action to activate big blocks...");

        const result = await exchClient.evmUserModify({
            usingBigBlocks: true
        });

        console.log("Big blocks activation successful:", result);
        console.log("Your HyperEVM transactions will now be directed to big blocks (30M gas limit, 1 minute duration)");
        
        return result;
        
    } catch (error: any) {
        console.error("Error activating big blocks:", error.message || String(error));
        console.error("Full error:", error);
        throw error;
    }
}

export async function deactivateBigBlocks(hyperliquidConfig: HyperliquidConfig) {
    try {
        const agentWallet = new ethers.Wallet(hyperliquidConfig.agentPk || "")

        const httpTransport = new hl.HttpTransport({
            isTestnet: hyperliquidConfig.isTestnet
        });

        const exchClient = new hl.ExchangeClient({ wallet: agentWallet, transport: httpTransport });
        
        console.log("Exchange client created successfully");
        console.log("Submitting action to deactivate big blocks...");

        // Submit the action to deactivate big blocks using the new API
        const result = await exchClient.evmUserModify({
            usingBigBlocks: false
        });

        console.log("Big blocks deactivation successful:", result);
        console.log("Your HyperEVM transactions will now be directed to small blocks (2M gas limit, 1 second duration)");
        
        return result;
        
    } catch (error: any) {
        console.error("Error deactivating big blocks:", error.message || String(error));
        throw error;
    }
}