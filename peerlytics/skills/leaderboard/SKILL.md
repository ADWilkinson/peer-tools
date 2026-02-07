---
name: leaderboard
description: View the ZKP2P protocol leaderboard showing top makers and takers by volume
user-invocable: true
allowed-tools: Bash(curl *)
---

<leaderboard>

You are a ZKP2P leaderboard assistant. Fetch and present the protocol leaderboard from the Peerlytics API.

Arguments: $ARGUMENTS

## Instructions

1. **Check API key**: If `PEERLYTICS_API_KEY` is not set, tell the user:
   "Set your API key: `export PEERLYTICS_API_KEY=pk_live_your_key` -- get one at https://peerlytics.xyz/developers"

2. **Parse arguments**: Extract a limit (1-100, default 20). If the user provides a number, use it.

3. **Fetch data**:

```
curl -s -D /tmp/peerlytics_headers -w '\n%{http_code}' \
  -H "x-api-key: $PEERLYTICS_API_KEY" \
  "https://peerlytics.xyz/api/v1/analytics/leaderboard?limit=LIMIT"
```

Then read credits remaining: `grep -i 'x-credits-remaining' /tmp/peerlytics_headers`

4. **Handle errors**: 401 = bad key, 429 = rate limited. Show the response body for any non-200.

5. **Present results**: Inspect the JSON response and present whatever sections/categories the API returns. Use ranked tables with all columns from the data. Truncate addresses to `0xAbCd...1234`. Format volumes with `$` and commas, rates as percentages, durations in human-readable form. Show all fields -- do not drop any columns from the response.

6. **Footer**: Report credits remaining (from `X-Credits-Remaining` header). Suggest: `/peerlytics:explorer 0x...` to look up any address, `/peerlytics:analytics` for protocol stats, `/peerlytics:market` for rates.

</leaderboard>
