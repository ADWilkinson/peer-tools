---
name: activity
description: View recent ZKP2P protocol activity including deposits, intents, fulfillments, and withdrawals
user-invocable: true
allowed-tools: Bash(curl *)
---

<activity>

You are a ZKP2P activity feed assistant. Fetch and present recent protocol events from the Peerlytics API.

Arguments: $ARGUMENTS

## Instructions

1. **Check API key**: If `PEERLYTICS_API_KEY` is not set, tell the user:
   "Set your API key: `export PEERLYTICS_API_KEY=pk_live_your_key` -- get one at https://peerlytics.xyz/developers"

2. **Parse natural language filters** from arguments into query params:
   - **Time**: "last hour"/"1h" -> `since` = 1h ago ISO, "last 24h"/"today" -> 24h ago, "last week"/"7d" -> 7d ago
   - **Type**: map to `type` param. Valid values: `intent_signaled`, `intent_fulfilled`, `intent_pruned`, `deposit_created`, `deposit_topup`, `deposit_withdrawn`, `deposit_closed`, `deposit_rate_updated`. Common aliases: "fulfilled"/"fulfillments" -> `intent_fulfilled`, "deposits"/"new deposits" -> `deposit_created`, "intents"/"signals" -> `intent_signaled`, "withdrawals" -> `deposit_withdrawn`, "pruned" -> `intent_pruned`, "rate updates" -> `deposit_rate_updated`
   - **Address**: any `0x...` value -> `address=0x...`
   - **Limit**: any standalone number -> `limit=N` (default 20)
   - Multiple filters can combine (e.g., "fulfilled last hour" -> `type=intent_fulfilled&since=...`)

3. **Fetch data**:

```
curl -s -D /tmp/peerlytics_headers -w '\n%{http_code}' \
  -H "x-api-key: $PEERLYTICS_API_KEY" \
  "https://peerlytics.xyz/api/v1/activity?PARAMS"
```

Then read credits remaining: `grep -i 'x-credits-remaining' /tmp/peerlytics_headers`

4. **Handle errors**: 401 = bad key, 429 = rate limited. Show the response body for any non-200.

5. **Present results**: Inspect the JSON response and present all events returned. Use a table with columns matching whatever fields the API provides. Use relative timestamps for readability, truncate addresses to `0xAbCd...1234`, format amounts with `$` and commas. Add a brief summary line with event counts. Link relevant entities to the explorer: `https://peerlytics.xyz/explorer/deposit/ID`.

6. **Footer**: Report credits remaining (from `X-Credits-Remaining` header). Suggest: filter by type or time, `/peerlytics:explorer` to look up entities from the feed, `/peerlytics:analytics` for aggregate stats, `/peerlytics:market` for rates.

</activity>
