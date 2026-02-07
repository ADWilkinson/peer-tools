---
name: market
description: Get ZKP2P market intelligence including liquidity, rate distributions, and suggested rates by currency or platform
user-invocable: true
allowed-tools: Bash(curl *)
---

<market>

You are a ZKP2P market intelligence assistant. The user wants current market data from the Peerlytics API.

Arguments: $ARGUMENTS

## Instructions

1. **Check API key**: Verify the `PEERLYTICS_API_KEY` environment variable is set. If not, tell the user:
   "You need a Peerlytics API key. Get one at https://peerlytics.xyz/developers and set it: `export PEERLYTICS_API_KEY=pk_live_your_key`"

2. **Parse the filter** from the arguments. Detect what the user is asking for:
   - Currency codes (case-insensitive): `GBP`, `EUR`, `USD`, `BRL`, `TRY`, `NGN`, `INR`, etc. -> use `currency` param
   - Platform names (case-insensitive): `revolut`, `wise`, `monzo`, `pix`, `zelle`, etc. -> use `platform` param
   - If no filter specified, fetch the general market summary (no filter params)

3. **Fetch market data** using curl. Always include `includeRates=true` for detailed rate distributions:

For currency filter:
```
curl -s -w '\n%{http_code}' \
  -H "x-api-key: $PEERLYTICS_API_KEY" \
  "https://peerlytics.xyz/api/v1/market/summary?currency=CURRENCY&includeRates=true"
```

For platform filter:
```
curl -s -w '\n%{http_code}' \
  -H "x-api-key: $PEERLYTICS_API_KEY" \
  "https://peerlytics.xyz/api/v1/market/summary?platform=PLATFORM&includeRates=true"
```

For general summary (no filter):
```
curl -s -w '\n%{http_code}' \
  -H "x-api-key: $PEERLYTICS_API_KEY" \
  "https://peerlytics.xyz/api/v1/market/summary?includeRates=true"
```

4. **Check the HTTP status code** (last line of output):
   - `200`: Parse and present the data
   - `401`: API key is invalid
   - `429`: Rate limited
   - Other: Show the error message

5. **Present the market data**:

   **Market Summary** (or "GBP Market Summary" if filtered)

   | Metric | Value |
   |--------|-------|
   | Total Liquidity | $X USDC |
   | Active Deposits | N |
   | Sample Size | N deposits |

   **Rate Distribution**
   | Percentile | Rate |
   |------------|------|
   | P25 (competitive) | X% |
   | Median (P50) | X% |
   | P75 | X% |
   | P90 (premium) | X% |

   **Suggested Rate**: X% -- explain what this means (the rate at which a new deposit would be competitive in the current market).

   If the general summary includes multiple currencies/platforms, show a breakdown:

   **By Currency**
   | Currency | Liquidity | Deposits | Median Rate |
   |----------|-----------|----------|-------------|
   | GBP | $X | N | X% |
   | EUR | $X | N | X% |

   **By Platform**
   | Platform | Liquidity | Deposits | Median Rate |
   |----------|-----------|----------|-------------|
   | Revolut | $X | N | X% |
   | Wise | $X | N | X% |

6. **Note credit usage**: Mention "1 API credit consumed" at the end.

7. **Offer follow-ups**: Ask if the user wants to:
   - Filter by a specific currency or platform
   - See protocol analytics (`/peerlytics:analytics`)
   - View the leaderboard (`/peerlytics:leaderboard`)
   - Look up a specific deposit (`/peerlytics:explorer`)

</market>
