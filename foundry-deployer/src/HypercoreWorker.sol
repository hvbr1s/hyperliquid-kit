// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interface for the CoreWriter system contract
interface ICoreWriter {
    function sendRawAction(bytes calldata data) external;
}

// Import the actual L1Read contract structures and interface
import "../precompiles/L1Read.sol";

contract HyperCoreInteraction {
    // System contract addresses
    ICoreWriter constant CORE_WRITER = ICoreWriter(0x3333333333333333333333333333333333333333);
    L1Read constant L1_READ = L1Read(0x0000000000000000000000000000000000000800);
    
    // Events for tracking actions
    event LimitOrderPlaced(uint32 asset, bool isBuy, uint64 limitPx, uint64 sz);
    event VaultTransferExecuted(address vault, bool isDeposit, uint64 usd);
    event TokenDelegated(address validator, uint64 amount, bool isUndelegate);
    event StakingDeposit(uint64 amount);
    event StakingWithdraw(uint64 amount);
    event SpotSent(address destination, uint64 token, uint64 amount);
    event USDClassTransfer(uint64 ntl, bool toPerp);
    event EVMContractFinalized(uint64 token, uint8 variant, uint64 createNonce);
    event APIWalletAdded(address wallet, string name);

    // Encoding version (currently only version 1 supported)
    uint8 constant ENCODING_VERSION = 0x01;

    // TIF (Time In Force) encodings
    uint8 constant TIF_ALO = 1;  // Add Liquidity Only
    uint8 constant TIF_GTC = 2;  // Good Till Cancel
    uint8 constant TIF_IOC = 3;  // Immediate or Cancel

    // Finalize EVM Contract variants
    uint8 constant FINALIZE_CREATE = 1;
    uint8 constant FINALIZE_FIRST_STORAGE_SLOT = 2;
    uint8 constant FINALIZE_CUSTOM_STORAGE_SLOT = 3;

    // Helper function to create action data
    function _createActionData(uint8 actionId, bytes memory encodedAction) internal pure returns (bytes memory) {
        bytes memory data = new bytes(4 + encodedAction.length);
        data[0] = bytes1(ENCODING_VERSION);
        data[1] = bytes1(0x00);
        data[2] = bytes1(0x00);
        data[3] = bytes1(actionId);
        
        for (uint256 i = 0; i < encodedAction.length; i++) {
            data[4 + i] = encodedAction[i];
        }
        
        return data;
    }

    // ===== TRADING ACTIONS =====

    /**
     * @dev Place a limit order
     * @param asset Asset ID
     * @param isBuy True for buy, false for sell
     * @param limitPx Limit price (scaled by 10^8)
     * @param sz Size (scaled by 10^8)
     * @param reduceOnly True if reduce-only order
     * @param tif Time in force (1=ALO, 2=GTC, 3=IOC)
     * @param cloid Client order ID (0 for no cloid)
     */
    function placeLimitOrder(
        uint32 asset,
        bool isBuy,
        uint64 limitPx,
        uint64 sz,
        bool reduceOnly,
        uint8 tif,
        uint128 cloid
    ) public {
        bytes memory encodedAction = abi.encode(asset, isBuy, limitPx, sz, reduceOnly, tif, cloid);
        bytes memory actionData = _createActionData(1, encodedAction);
        
        CORE_WRITER.sendRawAction(actionData);
        emit LimitOrderPlaced(asset, isBuy, limitPx, sz);
    }

    /**
     * @dev Transfer to/from vault
     * @param vault Vault address
     * @param isDeposit True for deposit, false for withdraw
     * @param usd Amount in USD
     */
    function vaultTransfer(address vault, bool isDeposit, uint64 usd) external {
        bytes memory encodedAction = abi.encode(vault, isDeposit, usd);
        bytes memory actionData = _createActionData(2, encodedAction);
        
        CORE_WRITER.sendRawAction(actionData);
        emit VaultTransferExecuted(vault, isDeposit, usd);
    }

    // ===== STAKING ACTIONS =====

    /**
     * @dev Delegate or undelegate tokens to/from validator
     * @param validator Validator address
     * @param amount Amount in wei
     * @param isUndelegate True to undelegate, false to delegate
     */
    function tokenDelegate(address validator, uint64 amount, bool isUndelegate) external {
        bytes memory encodedAction = abi.encode(validator, amount, isUndelegate);
        bytes memory actionData = _createActionData(3, encodedAction);
        
        CORE_WRITER.sendRawAction(actionData);
        emit TokenDelegated(validator, amount, isUndelegate);
    }

    /**
     * @dev Deposit tokens for staking
     * @param amount Amount in wei
     */
    function stakingDeposit(uint64 amount) external {
        bytes memory encodedAction = abi.encode(amount);
        bytes memory actionData = _createActionData(4, encodedAction);
        
        CORE_WRITER.sendRawAction(actionData);
        emit StakingDeposit(amount);
    }

    /**
     * @dev Withdraw tokens from staking
     * @param amount Amount in wei
     */
    function stakingWithdraw(uint64 amount) external {
        bytes memory encodedAction = abi.encode(amount);
        bytes memory actionData = _createActionData(5, encodedAction);
        
        CORE_WRITER.sendRawAction(actionData);
        emit StakingWithdraw(amount);
    }

    // ===== TRANSFER ACTIONS =====

    /**
     * @dev Send spot tokens to another address
     * @param destination Destination address
     * @param token Token ID
     * @param amount Amount in wei
     */
    function spotSend(address destination, uint64 token, uint64 amount) external {
        bytes memory encodedAction = abi.encode(destination, token, amount);
        bytes memory actionData = _createActionData(6, encodedAction);
        
        CORE_WRITER.sendRawAction(actionData);
        emit SpotSent(destination, token, amount);
    }

    /**
     * @dev Transfer USD between classes
     * @param ntl Notional amount
     * @param toPerp True to transfer to perp, false to transfer to spot
     */
    function usdClassTransfer(uint64 ntl, bool toPerp) external {
        bytes memory encodedAction = abi.encode(ntl, toPerp);
        bytes memory actionData = _createActionData(7, encodedAction);
        
        CORE_WRITER.sendRawAction(actionData);
        emit USDClassTransfer(ntl, toPerp);
    }

    // ===== CONTRACT MANAGEMENT =====

    /**
     * @dev Finalize EVM contract
     * @param token Token ID
     * @param variant Finalize variant (1=Create, 2=FirstStorageSlot, 3=CustomStorageSlot)
     * @param createNonce Create nonce (used if variant is Create)
     */
    function finalizeEvmContract(uint64 token, uint8 variant, uint64 createNonce) external {
        bytes memory encodedAction = abi.encode(token, variant, createNonce);
        bytes memory actionData = _createActionData(8, encodedAction);
        
        CORE_WRITER.sendRawAction(actionData);
        emit EVMContractFinalized(token, variant, createNonce);
    }

    /**
     * @dev Add API wallet
     * @param wallet API wallet address
     * @param name API wallet name (empty string makes it main API wallet)
     */
    function addApiWallet(address wallet, string memory name) external {
        bytes memory encodedAction = abi.encode(wallet, name);
        bytes memory actionData = _createActionData(9, encodedAction);
        
        CORE_WRITER.sendRawAction(actionData);
        emit APIWalletAdded(wallet, name);
    }

    // ===== READ FUNCTIONS =====

    /**
     * @dev Get perpetual oracle price
     * @param asset Asset ID
     * @return price Oracle price
     */
    function getPerpOraclePrice(uint32 asset) external view returns (uint64 price) {
        return L1_READ.oraclePx(asset);
    }

    /**
     * @dev Get spot oracle price
     * @param asset Asset ID
     * @return price Oracle price
     */
    function getSpotOraclePrice(uint32 asset) external view returns (uint64 price) {
        return L1_READ.spotPx(asset);
    }

    /**
     * @dev Get perpetual position
     * @param user User address
     * @param asset Asset ID
     * @return size Position size
     * @return entryPx Entry price
     * @return unrealizedPnl Unrealized PnL
     */
    function getPerpPosition(address user, uint32 asset) 
        external 
        view 
        returns (int64 size, uint64 entryPx, uint64 unrealizedPnl) 
    {
        L1Read.Position memory pos = L1_READ.position(user, uint16(asset));
        return (pos.szi, pos.entryNtl, 0); // unrealizedPnl not available in position struct
    }

    /**
     * @dev Get spot balance
     * @param user User address
     * @param token Token ID
     * @return balance Spot balance
     */
    function getSpotBalance(address user, uint32 token) external view returns (uint64 balance) {
        L1Read.SpotBalance memory spot = L1_READ.spotBalance(user, uint64(token));
        return spot.total;
    }

    /**
     * @dev Get vault equity
     * @param vault Vault address
     * @return equity Vault equity
     */
    function getVaultEquity(address vault) external view returns (uint64 equity) {
        L1Read.UserVaultEquity memory vaultEquity = L1_READ.userVaultEquity(address(0), vault);
        return vaultEquity.equity;
    }

    /**
     * @dev Get staking delegation
     * @param user User address
     * @param validator Validator address
     * @return delegation Delegation amount
     */
    function getStakingDelegation(address user, address validator) external view returns (uint64 delegation) {
        L1Read.Delegation[] memory delegations = L1_READ.delegations(user);
        for (uint i = 0; i < delegations.length; i++) {
            if (delegations[i].validator == validator) {
                return delegations[i].amount;
            }
        }
        return 0;
    }

    /**
     * @dev Get L1 block number
     * @return blockNumber L1 block number
     */
    function getL1BlockNumber() external view returns (uint64 blockNumber) {
        return L1_READ.l1BlockNumber();
    }

    // ===== CONVENIENCE FUNCTIONS =====

    /**
     * @dev Place a simple market buy order using IOC
     * @param asset Asset ID
     * @param sz Size (scaled by 10^8)
     * @param maxPrice Maximum price to pay (scaled by 10^8)
     */
    function marketBuy(uint32 asset, uint64 sz, uint64 maxPrice) external {
        placeLimitOrder(asset, true, maxPrice, sz, false, TIF_IOC, 0);
    }

    /**
     * @dev Place a simple market sell order using IOC
     * @param asset Asset ID
     * @param sz Size (scaled by 10^8)
     * @param minPrice Minimum price to accept (scaled by 10^8)
     */
    function marketSell(uint32 asset, uint64 sz, uint64 minPrice) external {
        placeLimitOrder(asset, false, minPrice, sz, false, TIF_IOC, 0);
    }

    /**
     * @dev Get comprehensive account information
     * @param user User address
     * @param perpAsset Perpetual asset ID to check (uint16)
     * @param spotToken Spot token ID to check
     * @return position Complete position information
     * @return spotBalance Complete spot balance information
     * @return withdrawable Withdrawable amounts
     * @return delegatorSummary Staking summary
     */
    function getAccountInfo(address user, uint16 perpAsset, uint64 spotToken)
        external
        view
        returns (
            L1Read.Position memory position,
            L1Read.SpotBalance memory spotBalance,
            L1Read.Withdrawable memory withdrawable,
            L1Read.DelegatorSummary memory delegatorSummary
        )
    {
        position = L1_READ.position(user, perpAsset);
        spotBalance = L1_READ.spotBalance(user, spotToken);
        withdrawable = L1_READ.withdrawable(user);
        delegatorSummary = L1_READ.delegatorSummary(user);
    }

    /**
     * @dev Get market data for an asset
     * @param assetIndex Asset index
     * @return markPrice Current mark price
     * @return oraclePrice Current oracle price
     * @return assetInfo Asset information (if it's a perp)
     */
    function getMarketData(uint32 assetIndex)
        external
        view
        returns (
            uint64 markPrice,
            uint64 oraclePrice,
            L1Read.PerpAssetInfo memory assetInfo
        )
    {
        markPrice = L1_READ.markPx(assetIndex);
        oraclePrice = L1_READ.oraclePx(assetIndex);
        
        // Try to get perp asset info (will revert if not a perp)
        try L1_READ.perpAssetInfo(assetIndex) returns (L1Read.PerpAssetInfo memory info) {
            assetInfo = info;
        } catch {
            // If it fails, return empty struct
            assetInfo = L1Read.PerpAssetInfo("", 0, 0, 0, false);
        }
    }

    /**
     * @dev Check if user has sufficient balance for an order
     * @param user User address
     * @param token Token to check
     * @param requiredAmount Required amount
     * @return hasBalance True if user has sufficient balance
     * @return availableBalance Available balance (total - hold)
     */
    function checkSufficientBalance(address user, uint64 token, uint64 requiredAmount)
        external
        view
        returns (bool hasBalance, uint64 availableBalance)
    {
        L1Read.SpotBalance memory balance = L1_READ.spotBalance(user, token);
        availableBalance = balance.total - balance.hold;
        hasBalance = availableBalance >= requiredAmount;
    }
}