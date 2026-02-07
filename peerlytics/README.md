# Peerlytics Plugin

ZKP2P protocol analytics, market intelligence, and explorer data via the [Peerlytics API](https://peerlytics.xyz/developers).

## Setup

1. Get a free API key at [peerlytics.xyz/developers](https://peerlytics.xyz/developers)
2. Add to your shell profile:
   ```bash
   export PEERLYTICS_API_KEY=pk_live_your_key_here
   ```
3. Install:
   ```
   /plugin marketplace add ADWilkinson/peer-tools
   /plugin install peerlytics@peer-tools
   ```

## Skills

### `/peerlytics:analytics [range]`

Protocol metrics for a time range. Ranges: `mtd` (default), `3mtd`, `ytd`, `q1`-`q4`, `all`, `wrapped_2025`. Supports currency and platform filters.

```
/peerlytics:analytics
/peerlytics:analytics YTD
/peerlytics:analytics Q1 GBP
```

### `/peerlytics:explorer [query]`

Look up any on-chain entity. Auto-detects addresses, deposit IDs, intent hashes, and transaction hashes.

```
/peerlytics:explorer 0xAbCd...1234
/peerlytics:explorer 42
```

### `/peerlytics:leaderboard [limit]`

Top makers and takers ranked by volume. Default: 20, max: 100.

```
/peerlytics:leaderboard
/peerlytics:leaderboard 50
```

### `/peerlytics:market [currency|platform]`

Live rates, liquidity, and rate distributions. Filter by currency or platform.

```
/peerlytics:market GBP
/peerlytics:market revolut
```

### `/peerlytics:activity [filters]`

Recent protocol events with natural language filtering.

```
/peerlytics:activity
/peerlytics:activity fulfilled last hour
/peerlytics:activity deposits for 0xAbCd...1234
```

## Credits

Each request consumes 1 credit (free tier: 1,000/month). Credits are only consumed on successful responses.

| Tier | Analytics RPM | Explorer RPM | Monthly Credits |
|------|---------------|--------------|-----------------|
| Free | 60 | 120 | 1,000 |
| Paid | 180 | 300 | Based on plan |

## Links

- [Peerlytics Dashboard](https://peerlytics.xyz)
- [API Docs](https://peerlytics.xyz/developers)
- [Explorer](https://peerlytics.xyz/explorer)
