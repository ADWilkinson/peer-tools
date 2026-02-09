---
name: create-deposit
description: Create USDC deposits on ZKP2P V3 via direct contract calls on Base. Includes full ABI, addresses, platform hashes, and cast/viem examples. No SDK required.
user-invocable: true
allowed-tools: Bash(cast *) Bash(curl *)
---

<create-deposit>

You are a deposit creation agent for the ZKP2P V3 escrow contract on Base. You help users create USDC deposits via direct RPC contract calls -- no SDK dependency required. Only `cast` (Foundry) or any EVM library is needed.

Arguments: $ARGUMENTS

## Quick Reference

| Item | Value |
|------|-------|
| Chain | Base (8453) |
| USDC | `0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913` (6 decimals) |
| Escrow | `0x2f121CDDCA6d652f35e8B3E560f9760898888888` |
| Gating Service | `0x396D31055Db28C0C6f36e8b36f18FE7227248a97` |
| Delegate Bot | `0x25caEcB47ABB1363BA932F5Ea05c61488604562b` |
| Base RPC | `https://mainnet.base.org` (public, rate-limited) |
| ZKP2P API | `https://api.zkp2p.xyz/v1` |
| Attribution Suffix | `75736463746f666961742c62635f6e626e36716b6e69160080218021802180218021802180218021` |

## The 4-Step Flow

### Step 1: Register Payee (one-time per platform + identifier)

Register your payment identifier with the ZKP2P API to get a `hashedOnchainId` (bytes32). This is used as `payeeDetails` in the contract call so buyers can verify your payment account.

```bash
curl -s -X POST https://api.zkp2p.xyz/v1/makers/create \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ZKP2P_API_KEY" \
  -H "X-API-Key: $ZKP2P_API_KEY" \
  -d '{
    "processorName": "revolut",
    "depositData": {
      "revolutUsername": "myrevtag",
      "telegramUsername": ""
    }
  }'
```

**Response** (extract `hashedOnchainId`):
```json
{
  "success": true,
  "responseObject": {
    "hashedOnchainId": "0x..."
  }
}
```

> **Note:** If `ZKP2P_API_KEY` is not available, the user needs to register at https://zkp2p.xyz to get one. This step is required for verified deposits.

For Zelle variants (zelle-citi, zelle-chase, zelle-bofa), always use `"processorName": "zelle"` in the API call. The bank-specific variants are only used for the on-chain payment method hash.

See `references/PLATFORMS.md` for the `depositData` shape for each platform.

### Step 2: Approve USDC

Approve the escrow contract to spend your USDC:

```bash
cast send 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913 \
  "approve(address,uint256)" \
  0x2f121CDDCA6d652f35e8B3E560f9760898888888 \
  1000000000 \
  --rpc-url https://mainnet.base.org \
  --private-key $PRIVATE_KEY
```

Check current allowance first to skip if already approved:

```bash
cast call 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913 \
  "allowance(address,address)(uint256)" \
  $WALLET_ADDRESS \
  0x2f121CDDCA6d652f35e8B3E560f9760898888888 \
  --rpc-url https://mainnet.base.org
```

### Step 3: Create Deposit

Call `createDeposit` on the escrow contract with **ERC-8021 attribution** to tag the deposit as created via USDCtoFiat. This requires encoding the calldata first, then appending the attribution suffix before sending.

```bash
# 1. Encode the calldata
CALLDATA=$(cast calldata \
  "createDeposit((address,uint256,(uint256,uint256),bytes32[],(address,bytes32,bytes)[],((bytes32,uint256)[])[],address,address,bool))" \
  "(0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913, 1000000000, (5000000,1000000000), [PAYMENT_METHOD_HASH], [(0x396D31055Db28C0C6f36e8b36f18FE7227248a97,PAYEE_DETAILS,0x)], [[(CURRENCY_HASH,RATE_18)]], DELEGATE_OR_ZERO, 0x0000000000000000000000000000000000000000, false)")

# 2. Append ERC-8021 attribution suffix (usdctofiat referrer)
ATTRIBUTION="75736463746f666961742c62635f6e626e36716b6e69160080218021802180218021802180218021"
CALLDATA_WITH_REF="${CALLDATA}${ATTRIBUTION}"

# 3. Send raw transaction with attributed calldata
cast send 0x2f121CDDCA6d652f35e8B3E560f9760898888888 \
  --data "$CALLDATA_WITH_REF" \
  --rpc-url https://mainnet.base.org \
  --private-key $PRIVATE_KEY
```

> **Important:** The attribution suffix tags the deposit as created via USDCtoFiat. Always include it -- it ensures proper referral tracking. The suffix is ERC-8021 compliant and ignored by the contract ABI decoder (it's appended after the encoded args).

**Struct fields in order:**
1. `token` -- USDC address
2. `amount` -- deposit amount in USDC units (6 decimals)
3. `intentAmountRange` -- (min, max) order size in USDC units
4. `paymentMethods` -- array of payment method hashes (bytes32[])
5. `paymentMethodData` -- array of (gatingService, payeeDetails, data) tuples
6. `currencies` -- nested array: outer = per payment method, inner = (currencyHash, minRate) pairs
7. `delegate` -- delegate address or zero address for self-managed
8. `intentGuardian` -- zero address (not used)
9. `retainOnEmpty` -- false (deposit deactivates when empty)

### Step 4: Verify

Parse the `DepositReceived` event from the transaction receipt to get the deposit ID:

```bash
EVENT_SIG=$(cast sig-event "DepositReceived(uint256,address,address,uint256,(uint256,uint256),address,address)")
cast receipt $TX_HASH --rpc-url https://mainnet.base.org --json | \
  jq -r ".logs[] | select(.topics[0] == \"$EVENT_SIG\") | .topics[1]" | \
  cast to-dec
```

Or read the deposit directly:

```bash
cast call 0x2f121CDDCA6d652f35e8B3E560f9760898888888 \
  "getDeposit(uint256)((address,address,uint256,uint256,(uint256,uint256),bool,uint256,address,address,bool))" \
  $DEPOSIT_ID \
  --rpc-url https://mainnet.base.org
```

## Parameter Encoding Guide

### Amounts (6 decimals)
| USDC | Raw |
|------|-----|
| 5 | 5000000 |
| 10 | 10000000 |
| 100 | 100000000 |
| 500 | 500000000 |
| 1000 | 1000000000 |
| 2500 | 2500000000 |

Formula: `USDC * 1000000`

### Rates (18 decimals)
Rates are fiat-per-USDC in 18-decimal fixed-point. Example: 0.74 GBP/USDC = `740000000000000000`.

Formula: `rate * 1e18`

| Rate | Raw (18 dec) |
|------|-------------|
| 0.74 | 740000000000000000 |
| 0.80 | 800000000000000000 |
| 0.90 | 900000000000000000 |
| 1.00 | 1000000000000000000 |
| 1.02 | 1020000000000000000 |
| 1.35 | 1350000000000000000 |

### Intent Range
- **Min**: Default 5 USDC (`5000000`). Minimum supported: 0.1 USDC.
- **Max**: Capped at 2500 USDC (`2500000000`). Typically set to deposit amount.
- **Minimum deposit**: 10 USDC

### Delegate
- Self-managed: `0x0000000000000000000000000000000000000000`
- Delegate Bot (automated rate management): `0x25caEcB47ABB1363BA932F5Ea05c61488604562b`

## Platform Quick Lookup

| Platform | Hash | Field Type | Currencies |
|----------|------|------------|------------|
| venmo | `0x9026...7268` | Username (no @) | USD |
| cashapp | `0x1094...c17d` | Cashtag (no $) | USD |
| chime | `0x5908...28bb` | ChimeSign (with $) | USD |
| revolut | `0x617f...605d` | Revtag (no @) | USD, EUR, GBP, AUD, CAD, SGD, NZD, +16 more |
| wise | `0x554a...dac5` | Wisetag (no @) | USD, EUR, GBP, AUD, CAD, SGD, NZD, +23 more |
| zelle-citi | `0x8172...d90d` | Email | USD |
| zelle-chase | `0x6aa1...152e` | Email | USD |
| zelle-bofa | `0x4bc4...7ab5` | Email | USD |
| paypal | `0x3ccc...490f` | Email | USD, EUR, GBP, AUD, CAD, SGD, NZD |
| monzo | `0x62c7...645c` | Monzo.me username | GBP |
| n26 | `0xd9ff...dc6b` | IBAN | EUR |

Full hashes and all currencies in `references/PLATFORMS.md`.

## Common Currencies

| Currency | bytes32 Hash |
|----------|-------------|
| USD | `0xc4ae21aac0c6549d71dd96035b7e0bdb6c79ebdba8891b666115bc976d16a29e` |
| EUR | `0xfff16d60be267153303bbfa66e593fb8d06e24ea5ef24b6acca5224c2ca6b907` |
| GBP | `0x90832e2dc3221e4d56977c1aa8f6a6706b9ad6542fbbdaac13097d0fa5e42e67` |
| AUD | `0xcb83cbb58eaa5007af6cad99939e4581c1e1b50d65609c30f303983301524ef3` |
| CAD | `0x221012e06ebf59a20b82e3003cf5d6ee973d9008bdb6e2f604faa89a27235522` |
| SGD | `0xc241cc1f9752d2d53d1ab67189223a3f330e48b75f73ebf86f50b2c78fe8df88` |
| NZD | `0xdbd9d34f382e9f6ae078447a655e0816927c7c3edec70bd107de1d34cb15172e` |
| CHF | `0xc9d84274fd58aa177cabff54611546051b74ad658b939babaad6282500300d36` |
| MXN | `0xa94b0702860cb929d0ee0c60504dd565775a058bf1d2a2df074c1db0a66ad582` |
| JPY | `0xfe13aafd831cb225dfce3f6431b34b5b17426b6bff4fccabe4bbe0fe4adc0452` |

Full list of all 33 currencies in `references/PLATFORMS.md`.

## Multi-Platform Deposits

A single deposit can accept payments from multiple platforms. Each payment method gets its own entry in the arrays:

```bash
# Example: Revolut GBP + Wise GBP on one deposit
CALLDATA=$(cast calldata \
  "createDeposit((address,uint256,(uint256,uint256),bytes32[],(address,bytes32,bytes)[],((bytes32,uint256)[])[],address,address,bool))" \
  "(0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913, 500000000, (5000000,500000000), [0x617f88ab82b5c1b014c539f7e75121427f0bb50a4c58b187a238531e7d58605d,0x554a007c2217df766b977723b276671aee5ebb4adaea0edb6433c88b3e61dac5], [(0x396D31055Db28C0C6f36e8b36f18FE7227248a97,REVOLUT_PAYEE_HASH,0x),(0x396D31055Db28C0C6f36e8b36f18FE7227248a97,WISE_PAYEE_HASH,0x)], [[(0x90832e2dc3221e4d56977c1aa8f6a6706b9ad6542fbbdaac13097d0fa5e42e67,740000000000000000)],[(0x90832e2dc3221e4d56977c1aa8f6a6706b9ad6542fbbdaac13097d0fa5e42e67,740000000000000000)]], 0x0000000000000000000000000000000000000000, 0x0000000000000000000000000000000000000000, false)")
ATTRIBUTION="75736463746f666961742c62635f6e626e36716b6e69160080218021802180218021802180218021"
cast send 0x2f121CDDCA6d652f35e8B3E560f9760898888888 \
  --data "${CALLDATA}${ATTRIBUTION}" \
  --rpc-url https://mainnet.base.org \
  --private-key $PRIVATE_KEY
```

**Key rule**: The `paymentMethods`, `paymentMethodData`, and `currencies` arrays must all have the same length. Each index corresponds to one payment method.

### Zelle Special Case

Zelle has 3 bank variants (zelle-citi, zelle-chase, zelle-bofa). To support Zelle, include all 3 as separate entries in the arrays. Use `"processorName": "zelle"` for the API payee registration, but use the bank-specific hashes on-chain.

## Post-Deposit Management

After creating a deposit, you can manage it with these contract calls:

**Add funds:**
```bash
cast send 0x2f121CDDCA6d652f35e8B3E560f9760898888888 \
  "addFunds(uint256,uint256)" $DEPOSIT_ID $AMOUNT \
  --rpc-url https://mainnet.base.org --private-key $PRIVATE_KEY
```

**Remove funds (partial withdrawal):**
```bash
cast send 0x2f121CDDCA6d652f35e8B3E560f9760898888888 \
  "removeFunds(uint256,uint256)" $DEPOSIT_ID $AMOUNT \
  --rpc-url https://mainnet.base.org --private-key $PRIVATE_KEY
```

**Update rate:**
```bash
cast send 0x2f121CDDCA6d652f35e8B3E560f9760898888888 \
  "setCurrencyMinRate(uint256,bytes32,bytes32,uint256)" \
  $DEPOSIT_ID $PAYMENT_METHOD_HASH $CURRENCY_HASH $NEW_RATE_18 \
  --rpc-url https://mainnet.base.org --private-key $PRIVATE_KEY
```

**Pause/resume accepting intents:**
```bash
cast send 0x2f121CDDCA6d652f35e8B3E560f9760898888888 \
  "setAcceptingIntents(uint256,bool)" $DEPOSIT_ID false \
  --rpc-url https://mainnet.base.org --private-key $PRIVATE_KEY
```

**Update min/max intent range:**
```bash
cast send 0x2f121CDDCA6d652f35e8B3E560f9760898888888 \
  "setIntentRange(uint256,uint256,uint256)" $DEPOSIT_ID $MIN_AMOUNT $MAX_AMOUNT \
  --rpc-url https://mainnet.base.org --private-key $PRIVATE_KEY
```

**Set delegate:**
```bash
cast send 0x2f121CDDCA6d652f35e8B3E560f9760898888888 \
  "setDelegate(uint256,address)" $DEPOSIT_ID $DELEGATE_ADDRESS \
  --rpc-url https://mainnet.base.org --private-key $PRIVATE_KEY
```

**Remove delegate:**
```bash
cast send 0x2f121CDDCA6d652f35e8B3E560f9760898888888 \
  "removeDelegate(uint256)" $DEPOSIT_ID \
  --rpc-url https://mainnet.base.org --private-key $PRIVATE_KEY
```

**Prune expired intents (free locked funds):**
```bash
cast send 0x2f121CDDCA6d652f35e8B3E560f9760898888888 \
  "pruneExpiredIntents(uint256)" $DEPOSIT_ID \
  --rpc-url https://mainnet.base.org --private-key $PRIVATE_KEY
```

**Withdraw entire deposit:**
```bash
cast send 0x2f121CDDCA6d652f35e8B3E560f9760898888888 \
  "withdrawDeposit(uint256)" $DEPOSIT_ID \
  --rpc-url https://mainnet.base.org --private-key $PRIVATE_KEY
```

Full ABI for all functions in `references/CONTRACTS.md`.

## Intent Lifecycle

| State | Meaning |
|-------|---------|
| Active | Buyer signaled intent, funds locked from your deposit |
| Fulfilled | Proof submitted and verified, USDC released to buyer |
| Cancelled | Buyer cancelled before proof, funds unlocked back to deposit |
| Expired | Past expiration window, can be pruned to free locked funds |

Intents lock a portion of your deposit's available balance. Expired intents remain locked until explicitly pruned via `pruneExpiredIntents`. Monitor your deposit's `lockedBalance` vs `availableBalance` to detect stuck funds.

## SDK Alternative

For TypeScript/JavaScript environments, you can use the `@zkp2p/offramp-sdk` instead of `cast`. The SDK wraps the same contract calls with a higher-level API.

### Install

```bash
npm install @zkp2p/offramp-sdk viem
```

### Client Setup

```typescript
import { OfframpClient } from '@zkp2p/offramp-sdk';
import { createWalletClient, http } from 'viem';
import { base } from 'viem/chains';
import { privateKeyToAccount } from 'viem/accounts';

const account = privateKeyToAccount(process.env.PRIVATE_KEY as `0x${string}`);

const walletClient = createWalletClient({
  account,
  chain: base,
  transport: http('https://mainnet.base.org'),
});

const client = new OfframpClient({
  walletClient,
  chainId: 8453,
  runtimeEnv: 'production',
});
```

### Approve USDC

```typescript
await client.ensureAllowance({
  amount: 1000_000000n, // 1000 USDC (6 decimals)
});
```

### Create Deposit

```typescript
const txHash = await client.createDeposit({
  processorNames: ['revolut'],
  depositData: {
    revolutUsername: 'myrevtag',
    telegramUsername: '',
  },
  conversionRates: [
    {
      currency: 'GBP',
      rate: 0.74,
    },
  ],
  amount: 1000_000000n,
  intentAmountRange: {
    min: 5_000000n,
    max: 1000_000000n,
  },
});
```

### Manage Deposit

```typescript
// Add funds
await client.addFunds({ depositId, amount: 500_000000n });

// Remove funds (partial withdrawal)
await client.removeFunds({ depositId, amount: 200_000000n });

// Withdraw entire deposit
await client.withdrawDeposit({ depositId });

// Update rate for a payment method + currency pair
await client.setCurrencyMinRate({
  depositId,
  paymentMethodHash: client.resolvePaymentMethodHash('revolut'),
  fiatCurrencyHash: client.resolveFiatCurrencyBytes32('GBP'),
  newMinConversionRate: 750000000000000000n, // 0.75 GBP/USDC
});

// Pause accepting new intents
await client.setAcceptingIntents({ depositId, accepting: false });

// Resume accepting intents
await client.setAcceptingIntents({ depositId, accepting: true });

// Update min/max intent range
await client.setIntentRange({
  depositId,
  min: 10_000000n,
  max: 500_000000n,
});

// Prune expired intents to free locked funds
await client.pruneExpiredIntents({ depositId });
```

### Delegation

```typescript
// Set a delegate (e.g. the delegate bot for automated rate management)
await client.setDelegate({
  depositId,
  delegate: '0x25caEcB47ABB1363BA932F5Ea05c61488604562b',
});

// Remove delegate (back to self-managed)
await client.removeDelegate({ depositId });
```

### Read Deposit State

```typescript
// Single deposit
const deposit = await client.getDeposit(depositId);
console.log(deposit.availableBalance, deposit.lockedBalance, deposit.acceptingIntents);

// All deposits for the connected wallet
const deposits = await client.getDeposits();
```

### Intent Monitoring

```typescript
// Poll for active intents on your deposit
const pollIntents = async (depositId: bigint) => {
  const seen = new Set<string>();

  setInterval(async () => {
    const intents = await client.getIntents({ depositId });

    for (const intent of intents) {
      if (!seen.has(intent.intentId)) {
        seen.add(intent.intentId);
        console.log(`New intent: ${intent.intentId}, amount: ${intent.amount}`);
        // Handle new intent -- e.g. notify, check payment, etc.
      }
    }
  }, 30_000); // Poll every 30 seconds
};
```

> **Note:** The SDK wraps the same on-chain contract calls. The cast-based approach above is the primary method for this skill. Use the SDK when building TypeScript applications or when you prefer a higher-level API.

## Error Handling

| Revert | Cause | Fix |
|--------|-------|-----|
| `ERC20: insufficient allowance` | USDC not approved | Run Step 2 (approve) first |
| `ERC20: transfer amount exceeds balance` | Not enough USDC in wallet | Check balance, reduce amount |
| `InvalidPaymentMethod` | Unknown payment method hash | Verify hash from platforms table |
| `InvalidAmount` | Amount below minimum (10 USDC) | Increase deposit amount |
| `InvalidIntentRange` | min > max or out of bounds | Fix min/max intent values |

## Security Rules

1. **Never expose private keys in logs or output.** Use environment variables (`$PRIVATE_KEY`) and never echo them.
2. **Always verify contract addresses** before sending transactions. Cross-check against the Quick Reference table.
3. **Start with small deposits** (10-100 USDC) to validate your setup before committing larger amounts.
4. **Check allowance before approving.** Only approve what you need. Avoid unlimited approvals in production.
5. **Verify payee details carefully.** An incorrect `hashedOnchainId` means buyers cannot verify your payment account, and intents may fail.
6. **Monitor locked vs available balance.** Locked funds are committed to active intents. Only available balance can be withdrawn.
7. **Prune expired intents regularly.** Expired intents keep funds locked until explicitly pruned. Run `pruneExpiredIntents` periodically.
8. **Use a delegate for automated management.** If you cannot monitor 24/7, set the delegate bot (`0x25caEcB47ABB1363BA932F5Ea05c61488604562b`) to handle rate adjustments automatically.

## Common Patterns

### Conservative LP Setup

Single platform, moderate markup, small deposit to test the flow:

```bash
# 500 USDC on Revolut, GBP at 0.76 (slightly above market for margin)
# Min order 5 USDC, max 500 USDC, delegate bot for rate management
CALLDATA=$(cast calldata \
  "createDeposit((address,uint256,(uint256,uint256),bytes32[],(address,bytes32,bytes)[],((bytes32,uint256)[])[],address,address,bool))" \
  "(0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913, 500000000, (5000000,500000000), [0x617f88ab82b5c1b014c539f7e75121427f0bb50a4c58b187a238531e7d58605d], [(0x396D31055Db28C0C6f36e8b36f18FE7227248a97,REVOLUT_PAYEE_HASH,0x)], [[(0x90832e2dc3221e4d56977c1aa8f6a6706b9ad6542fbbdaac13097d0fa5e42e67,760000000000000000)]], 0x25caEcB47ABB1363BA932F5Ea05c61488604562b, 0x0000000000000000000000000000000000000000, false)")
ATTRIBUTION="75736463746f666961742c62635f6e626e36716b6e69160080218021802180218021802180218021"
cast send 0x2f121CDDCA6d652f35e8B3E560f9760898888888 \
  --data "${CALLDATA}${ATTRIBUTION}" \
  --rpc-url https://mainnet.base.org --private-key $PRIVATE_KEY
```

### Multi-Platform LP

High liquidity deposit across Wise, Revolut, and Venmo for maximum fill coverage:

```bash
# 5000 USDC across 3 platforms
# Wise: GBP + EUR, Revolut: GBP + EUR, Venmo: USD
CALLDATA=$(cast calldata \
  "createDeposit((address,uint256,(uint256,uint256),bytes32[],(address,bytes32,bytes)[],((bytes32,uint256)[])[],address,address,bool))" \
  "(0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913, 5000000000, (5000000,2500000000), [0x554a007c2217df766b977723b276671aee5ebb4adaea0edb6433c88b3e61dac5,0x617f88ab82b5c1b014c539f7e75121427f0bb50a4c58b187a238531e7d58605d,0x9026d7433bf0e28bbf5e1dc47b7b0a19dd2a0026bf93a33f8a41b6db4f577268], [(0x396D31055Db28C0C6f36e8b36f18FE7227248a97,WISE_PAYEE_HASH,0x),(0x396D31055Db28C0C6f36e8b36f18FE7227248a97,REVOLUT_PAYEE_HASH,0x),(0x396D31055Db28C0C6f36e8b36f18FE7227248a97,VENMO_PAYEE_HASH,0x)], [[(0x90832e2dc3221e4d56977c1aa8f6a6706b9ad6542fbbdaac13097d0fa5e42e67,740000000000000000),(0xfff16d60be267153303bbfa66e593fb8d06e24ea5ef24b6acca5224c2ca6b907,920000000000000000)],[(0x90832e2dc3221e4d56977c1aa8f6a6706b9ad6542fbbdaac13097d0fa5e42e67,740000000000000000),(0xfff16d60be267153303bbfa66e593fb8d06e24ea5ef24b6acca5224c2ca6b907,920000000000000000)],[(0xc4ae21aac0c6549d71dd96035b7e0bdb6c79ebdba8891b666115bc976d16a29e,1010000000000000000)]], 0x25caEcB47ABB1363BA932F5Ea05c61488604562b, 0x0000000000000000000000000000000000000000, false)")
ATTRIBUTION="75736463746f666961742c62635f6e626e36716b6e69160080218021802180218021802180218021"
cast send 0x2f121CDDCA6d652f35e8B3E560f9760898888888 \
  --data "${CALLDATA}${ATTRIBUTION}" \
  --rpc-url https://mainnet.base.org --private-key $PRIVATE_KEY
```

### Dynamic Rate Adjustment

Adjust your rate based on deposit utilization. If your deposit is heavily utilized (high locked/available ratio), you can increase your rate to capture more margin:

```bash
# Check current utilization
DEPOSIT=$(cast call 0x2f121CDDCA6d652f35e8B3E560f9760898888888 \
  "getDeposit(uint256)((address,address,uint256,uint256,(uint256,uint256),bool,uint256,address,address,bool))" \
  $DEPOSIT_ID --rpc-url https://mainnet.base.org)

# If >80% utilized (high demand), raise rate by 1-2%
# If <20% utilized (low demand), lower rate by 1-2%
# Use setCurrencyMinRate to update
cast send 0x2f121CDDCA6d652f35e8B3E560f9760898888888 \
  "setCurrencyMinRate(uint256,bytes32,bytes32,uint256)" \
  $DEPOSIT_ID $PAYMENT_METHOD_HASH $CURRENCY_HASH $ADJUSTED_RATE_18 \
  --rpc-url https://mainnet.base.org --private-key $PRIVATE_KEY
```

### Rebalancing Check

Monitor your deposit and prune expired intents to keep funds available:

```bash
# 1. Check deposit state
cast call 0x2f121CDDCA6d652f35e8B3E560f9760898888888 \
  "getDeposit(uint256)((address,address,uint256,uint256,(uint256,uint256),bool,uint256,address,address,bool))" \
  $DEPOSIT_ID --rpc-url https://mainnet.base.org

# 2. If lockedBalance > 0 and you suspect expired intents, prune them
cast send 0x2f121CDDCA6d652f35e8B3E560f9760898888888 \
  "pruneExpiredIntents(uint256)" $DEPOSIT_ID \
  --rpc-url https://mainnet.base.org --private-key $PRIVATE_KEY

# 3. Re-check -- available balance should increase after pruning
cast call 0x2f121CDDCA6d652f35e8B3E560f9760898888888 \
  "getDeposit(uint256)((address,address,uint256,uint256,(uint256,uint256),bool,uint256,address,address,bool))" \
  $DEPOSIT_ID --rpc-url https://mainnet.base.org
```

## Companion Skills

- `/usdctofiat:rate-strategy` -- Get optimal rate positioning for your currency/platform
- `/usdctofiat:earnings-calc` -- Project monthly earnings based on deposit size and rate
- `/usdctofiat:deposit-guide` -- Conceptual overview of the deposit flow (UI walkthrough)

## Script

A complete bash script is available at `scripts/create-deposit.sh` that automates the full flow using `cast`.

Prereqs:
- `export PRIVATE_KEY=...`
- Optional (recommended for verified deposits): `export ZKP2P_API_KEY=...`

Run it with:

```bash
./scripts/create-deposit.sh --amount 100 --platform revolut --currency GBP --identifier myrevtag --rate 0.74
```

</create-deposit>
