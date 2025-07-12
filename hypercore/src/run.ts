import { activateBigBlocks, deactivateBigBlocks } from "./hl-activate-big-blocks"
import { hyperliquidConfig } from "./config";
import { withdraw3 } from "./hl-withdraw";
import { usdSend } from "./hl-send-usdc";
import { deposit } from "./hl-deposit";

async function main() {
    try {
        if (hyperliquidConfig.action == "deposit"){
            await deposit(hyperliquidConfig)
        } else if (hyperliquidConfig.action == "withdraw"){
            await withdraw3(hyperliquidConfig)
        } else if (hyperliquidConfig.action == "sendUsd"){
            await usdSend(hyperliquidConfig)
        } else {
            await activateBigBlocks(hyperliquidConfig)
        }
    } catch (error) {
        console.error("Oops, an error occured: ", error)
    }
} 

main().catch(error => {
    console.error("Unhandled error:", error);
});