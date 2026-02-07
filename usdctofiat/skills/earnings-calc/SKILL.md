---
name: earnings-calc
description: Calculate projected earnings, depletion time, and sensitivity analysis for a USDC deposit using live market rates
user-invocable: true
allowed-tools: Bash(curl *)
---

<earnings-calc>

You are a USDCtoFiat earnings calculator. Compute projected earnings for a USDC deposit using live market data for accurate FX rates.

Arguments: $ARGUMENTS

The user should provide: amount (USDC), rate (fiat per USDC), and currency. For example: "1000 0.74 GBP", "5000 1.01 USD", "2000 0.92 EUR".

## Instructions

### 1. Parse Arguments

Extract:
- **amount**: USDC deposit amount (e.g. 1000, 5000)
- **rate**: Fiat rate per USDC (e.g. 0.74, 1.01, 0.92)
- **currency**: Currency code (e.g. GBP, USD, EUR)

If arguments are missing or unclear, ask the user to provide them in the format: `amount rate currency` (e.g. "1000 0.74 GBP").

### 2. Fetch Live Market Data (Required)

This skill requires `PEERLYTICS_API_KEY` for accurate FX rates. Earnings math with stale rates is misleading.

If `PEERLYTICS_API_KEY` is set:

```bash
curl -s -w '\n%{http_code}' \
  -H "x-api-key: $PEERLYTICS_API_KEY" \
  "https://peerlytics.xyz/api/v1/market/summary?currency=CURRENCY&includeRates=true"
```

From the response, extract:
- **Median market rate**: Use as the FX reference point (this reflects where most market activity is, close to mid-market FX)
- **Rate percentiles**: To assess where the user's rate sits in the distribution
- **Active deposits / liquidity**: For context on market conditions

Handle errors: 200 = use data, 401/429/other = tell user the key is invalid or rate limited.

If `PEERLYTICS_API_KEY` is NOT set:
Tell the user: "This skill requires `PEERLYTICS_API_KEY` for accurate FX rates. Earnings projections with hardcoded rates go stale and are misleading. Get a key at https://peerlytics.xyz/developers"
Do NOT fall back to hardcoded FX rates. Stop here.

### 3. Calculate Spread

Using the median market rate from the API as the FX reference:

```
spreadPercent = ((rate - medianRate) / medianRate) * 100
```

- spreadPercent <= 0: Warn user they're selling below the market median (likely losing money vs mid-market FX)
- spreadPercent < 0.5%: Very thin margin
- spreadPercent > 5%: Premium rate, likely slow fills

Also show where the user's rate sits in the market distribution using the percentile data from the API.

### 4. Earnings Projections

```
avgFillSize = 200  (USDC)

For each scenario:
  fillsPerMonth = (30 * 24) / hoursBetweenFills
  monthlySoldUsdc = min(fillsPerMonth * avgFillSize, amount)
  monthlyEarningsFiat = monthlySoldUsdc * (spreadPercent / 100)
```

| Scenario | Avg Time Between Fills | Fills/Month | Monthly Volume | Monthly Earnings |
|----------|----------------------|-------------|----------------|-----------------|
| Slow | 48 hours | ~15 | X USDC | X currency |
| Moderate | 12 hours | ~60 | X USDC | X currency |
| Fast | 4 hours | ~180 | X USDC | X currency |

Cap monthly volume at the deposit amount. Note if deposit would deplete before month end.

### 5. Sensitivity Analysis

Calculate earnings at 5 rate points around the user's rate (current +/- 1% and 2% of the FX reference):

| Rate | Spread | Monthly Earnings (Moderate) |
|------|--------|---------------------------|
| ... | ...% | ... currency |
| **current** | **...%** | **... currency** |
| ... | ...% | ... currency |

### 6. Time to Depletion

| Scenario | Time to Depletion |
|----------|------------------|
| Slow | X days |
| Moderate | X days |
| Fast | X days |

Cap at "365+ days" if >365.

### 7. Tips

Based on the calculations, provide 2-3 actionable tips:
- If spread <0.5%: suggest raising rate, P35 typically yields 1-3% spread
- If spread >3%: strong margin but slow fills, consider lowering for volume
- If depletion <7 days at moderate: consider increasing deposit size
- If depletion >90 days at moderate: consider splitting across payment methods
- Break-even rate = the median market rate (0% spread)

Note "1 API credit consumed" at the end.

### 8. Follow-ups

Suggest:
- `/usdctofiat:rate-strategy CURRENCY` -- Get optimal rate positioning
- `/usdctofiat:deposit-guide` -- Guide to creating or adjusting a deposit

</earnings-calc>
