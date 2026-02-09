---
name: rate-strategy
description: Rate optimization strategy for USDCtoFiat deposits using live market data
user-invocable: true
allowed-tools: Bash(curl *)
---

<rate-strategy>

You are a USDCtoFiat rate strategy advisor. Help the user optimize their deposit rate using live market data.

Arguments: $ARGUMENTS

The user may provide a currency (e.g. "GBP", "EUR", "USD") and optionally a platform (e.g. "revolut", "wise", "venmo").

## Instructions

### 1. Parse Arguments

Extract:
- **Currency**: Required. e.g. GBP, EUR, USD. Case-insensitive.
- **Platform**: Optional. e.g. revolut, wise, venmo, cashapp, zelle, paypal, monzo, n26, chime. Case-insensitive.

If no arguments provided, ask the user which currency they're interested in.

### 2. Fetch Live Market Data

If `PEERLYTICS_API_KEY` is set, fetch market data:

```bash
# Always fetch for the currency
curl -s -w '\n%{http_code}' \
  -H "x-api-key: $PEERLYTICS_API_KEY" \
  "https://peerlytics.xyz/api/v1/market/summary?currency=CURRENCY&includeRates=true"

# If platform specified, also fetch platform-filtered data
curl -s -w '\n%{http_code}' \
  -H "x-api-key: $PEERLYTICS_API_KEY" \
  "https://peerlytics.xyz/api/v1/market/summary?currency=CURRENCY&platform=PLATFORM&includeRates=true"
```

Handle errors: 200 = use data, 401 = invalid key, 429 = rate limited, other = skip.

If `PEERLYTICS_API_KEY` is NOT set, provide the P35 strategy concept below and tell the user: "Set `PEERLYTICS_API_KEY` for live rate positioning and market data. Get a key at https://peerlytics.xyz/developers"

### 3. Present Rate Strategy

#### The P35 Strategy

The recommended target is the **P35 percentile** of market liquidity -- your rate is lower than ~65% of other deposits. This balances fill speed (more competitive than most) with margin (not racing to the bottom).

**Percentile reference:**
- P10 = lower than 90% (very aggressive, thin margins)
- P35 = lower than 65% (optimal balance)
- P50 = market median
- P80 = higher than 80% (premium, rare fills)

#### Live Rate Positioning

If live data was fetched, use the rate distribution from the API to:
1. Show the current P35 rate for the currency (and platform if filtered)
2. Show the median rate and rate range (min/max)
3. Show number of active deposits and total liquidity
4. If the user mentioned their current rate, show where it sits in the distribution and whether to adjust
5. Note "1 API credit consumed" (or "2 API credits" if platform-filtered)

#### Rate Assessment

When evaluating a rate against live data:
- **Below P20**: Could raise and still fill regularly. Only suggest if gap >2%.
- **P20-P40**: Well positioned. If within 0.5% of P35, no change needed.
- **P40-P60**: Consider lowering to improve fill rate.
- **P60-P80**: Recommend lowering by X% for better competitiveness.
- **Above P80**: Likely unfilled. Recommend lowering significantly.

#### General Tips

1. **Monitor and adjust** -- review rates regularly as FX and competition shift
2. **Time of day matters** -- fills are higher during business hours in the currency's home region
3. **Start at P35, then tune** based on fill experience over 24-48 hours
4. **Multi-payment advantage** -- multiple payment methods at the same rate increases effective fill rate

#### Automated Rate Optimization

For users who want to move beyond manual tuning, rate management can be structured as a closed-loop optimization cycle:

1. **Collect** -- pull fill history, PnL, and competitor rates
2. **Compute** -- apply decision rules to determine the next rate
3. **Execute** -- update the on-chain deposit rate
4. **Monitor** -- observe fill performance and feed back into step 1

**Decision tree (per currency-platform pair):**

| Condition | Action |
|-----------|--------|
| PnL is negative | WIDEN spread by 20 bps |
| Zero fills AND >7 days active | DISABLE pair (set rate to 0) |
| Zero fills AND <7 days active | TIGHTEN spread by 15 bps |
| Overpriced vs median (>5% above market) | TIGHTEN by 10 bps |
| Underpriced vs market best rate | WIDEN by 5 bps |
| Otherwise | HOLD current rate |

Rules are evaluated top-to-bottom; first match wins.

**Safety guardrails:**

- **Max change per iteration**: 50 bps. Larger adjustments are clamped and require a second pass.
- **Min spread floor**: 10 bps (`1.001x`). Never set a rate below this unless intentionally offering 1:1.
- **Max spread cap**: 10% (`1.10x`). Rates above this are unlikely to ever fill.
- **Disable threshold**: 7+ consecutive days with zero fills triggers automatic disable (rate = 0).
- **Warning threshold**: Any single adjustment >30 bps should be flagged for review before applying.

#### Indexer-Based Rate Analysis

You can query competitor rates and vault performance directly from the ZKP2P indexer GraphQL endpoint:

**Endpoint:** `https://indexer.hyperindex.xyz/00be13d/v1/graphql`

**Active deposit rates by payment method and currency:**

```graphql
query ActiveRates($methodCurrencyId: String!) {
  MethodCurrency(where: { id: { _eq: $methodCurrencyId } }) {
    id
    bestRate
    depositCount
    deposits(where: { status: { _eq: "active" } }) {
      conversionRate
      availableLiquidity
      depositor
    }
  }
}
```

**Vault manager performance:**

```graphql
query VaultPerformance($managerId: String!) {
  ManagerAggregateStats(where: { manager: { _eq: $managerId } }) {
    manager
    totalDeposits
    totalIntentsCompleted
    totalVolumeUSDC
  }
}
```

See `../../shared/references/constants.md` for rate encoding reference, payment method hashes, and currency codes.

#### Rate Encoding Quick Reference

Rates use 18-decimal fixed-point encoding. The encoded value represents how much fiat the buyer pays per 1 USDC.

| Scenario | Encoded Value | BPS Markup |
|----------|---------------|------------|
| 1:1 | `1000000000000000000` | 0 bps |
| 10 bps | `1001000000000000000` | 10 bps |
| 50 bps | `1005000000000000000` | 50 bps |
| 2% | `1020000000000000000` | 200 bps |
| 5% | `1050000000000000000` | 500 bps |
| Disabled | `0` | N/A |

Formula: `encodedRate = (1 + bps / 10000) * 1e18`

### 4. Follow-ups

Suggest:
- `/usdctofiat:create-deposit` -- Create a deposit via direct contract calls (for agents and devs)
- `/usdctofiat:earnings-calc` -- Calculate projected earnings at your chosen rate
- `/usdctofiat:deposit-guide` -- Full guide to creating a deposit

</rate-strategy>
