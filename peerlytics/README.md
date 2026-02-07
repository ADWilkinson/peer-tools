# Peerlytics Plugin for Claude Code

ZKP2P protocol analytics, market intelligence, and explorer data -- powered by the [Peerlytics API](https://peerlytics.xyz/developers).

## Setup

### 1. Get an API Key

Sign up at [peerlytics.xyz/developers](https://peerlytics.xyz/developers) to get your API key.

### 2. Set Environment Variable

```bash
export PEERLYTICS_API_KEY=pk_live_your_key_here
```

Add this to your shell profile (`.bashrc`, `.zshrc`, etc.) to persist across sessions.

### 3. Install Plugin

Add the peer-tools marketplace and install:

```
/plugin marketplace add ADWilkinson/peer-tools
/plugin install peerlytics@peer-tools
```

## Available Skills

### `/peerlytics:analytics [range]`

Fetch protocol-wide analytics for a given time range.

**Ranges**: `mtd` (default), `3mtd`, `ytd`, `q1`, `q2`, `q3`, `q4`, `all`, `wrapped_2025`

**Examples**:
```
/peerlytics:analytics
/peerlytics:analytics YTD
/peerlytics:analytics Q1
/peerlytics:analytics all
```

**Returns**: Total volume, deposit/intent counts, unique makers/takers, average fill time, top currencies, and top platforms.

### `/peerlytics:explorer [query]`

Search the ZKP2P explorer by address, deposit ID, intent hash, or transaction hash.

**Examples**:
```
/peerlytics:explorer 0xAbCdEf1234567890AbCdEf1234567890AbCdEf12
/peerlytics:explorer 42
/peerlytics:explorer 0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890
```

**Returns**: Entity details with status, amounts, timestamps, and links to the Peerlytics explorer.

### `/peerlytics:leaderboard [limit]`

View the protocol leaderboard showing top makers and takers.

**Examples**:
```
/peerlytics:leaderboard
/peerlytics:leaderboard 10
/peerlytics:leaderboard 50
```

**Returns**: Ranked tables of top makers (by volume, APR, fill time) and top takers (by volume, success rate).

### `/peerlytics:market [currency|platform]`

Get market intelligence including liquidity, rate distributions, and suggested rates.

**Examples**:
```
/peerlytics:market
/peerlytics:market GBP
/peerlytics:market revolut
/peerlytics:market EUR
```

**Returns**: Total liquidity, active deposits, rate percentiles (P25/P50/P75/P90), and suggested competitive rate.

### `/peerlytics:activity [filters]`

View recent protocol activity with optional natural language filters.

**Examples**:
```
/peerlytics:activity
/peerlytics:activity fulfilled last hour
/peerlytics:activity deposits for 0xAbCd...1234
/peerlytics:activity intents last 24h
/peerlytics:activity 50
```

**Returns**: Chronological event list with type, timestamp, participants, and amounts.

## Rate Limits and Credits

| Tier | Analytics RPM | Explorer RPM | Monthly Credits |
|------|---------------|--------------|-----------------|
| Free | 60 | 120 | 1,000 |
| Paid | 180 | 300 | Based on plan |

- Each API request consumes **1 credit** (only on successful 2xx responses)
- Check remaining credits via the `X-Credits-Remaining` response header
- Rate limit info is returned in `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset` headers

## Links

- **API Documentation**: [peerlytics.xyz/developers](https://peerlytics.xyz/developers)
- **Explorer**: [peerlytics.xyz/explorer](https://peerlytics.xyz/explorer)
- **Dashboard**: [peerlytics.xyz](https://peerlytics.xyz)
