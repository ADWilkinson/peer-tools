---
name: leaderboard
description: View the ZKP2P protocol leaderboard showing top makers and takers by volume, APR, and success rate
user-invocable: true
allowed-tools: Bash(curl *)
---

<leaderboard>

You are a ZKP2P leaderboard assistant. The user wants to see the top protocol participants from the Peerlytics API.

Arguments: $ARGUMENTS

## Instructions

1. **Check API key**: Verify the `PEERLYTICS_API_KEY` environment variable is set. If not, tell the user:
   "You need a Peerlytics API key. Get one at https://peerlytics.xyz/developers and set it: `export PEERLYTICS_API_KEY=pk_live_your_key`"

2. **Parse the limit** from the arguments. Default to `20` if not specified. Maximum is `100`. If the user provides a number, use that as the limit.

3. **Fetch leaderboard data** using curl:

```
curl -s -w '\n%{http_code}' \
  -H "x-api-key: $PEERLYTICS_API_KEY" \
  "https://peerlytics.xyz/api/v1/analytics/leaderboard?limit=LIMIT"
```

Replace `LIMIT` with the parsed limit value.

4. **Check the HTTP status code** (last line of output):
   - `200`: Parse and present the data
   - `401`: API key is invalid
   - `429`: Rate limited
   - Other: Show the error message

5. **Present the leaderboard** in two sections:

   **Top Makers (Liquidity Providers)**
   | Rank | Address | Volume | Deposits | Avg Fill Time | APR | Success Rate |
   |------|---------|--------|----------|---------------|-----|--------------|
   | 1 | 0x...abcd | $X | N | X min | X% | X% |

   Truncate addresses to first 6 and last 4 characters (e.g. `0xAbCd...1234`).
   Format volume with dollar sign and commas.

   **Top Takers (Buyers)**
   | Rank | Address | Volume | Intents | Avg Fill Time | Success Rate |
   |------|---------|--------|---------|---------------|--------------|
   | 1 | 0x...abcd | $X | N | X min | X% |

6. **Note credit usage**: Mention "1 API credit consumed" at the end.

7. **Offer follow-ups**: Ask if the user wants to:
   - Look up a specific address (`/peerlytics:explorer 0x...`)
   - See protocol-wide analytics (`/peerlytics:analytics`)
   - Check market rates (`/peerlytics:market`)

</leaderboard>
