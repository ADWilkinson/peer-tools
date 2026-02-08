# peer-tools

Claude Code plugins for the [ZKP2P](https://zkp2p.xyz) peer-to-peer trading ecosystem. Query protocol data, analyze markets, and get trading guidance -- all from your terminal.

## Quick Start

```
/plugin marketplace add ADWilkinson/peer-tools
```

Then install one or both plugins:

```
/plugin install peerlytics@peer-tools
/plugin install usdctofiat@peer-tools
```

## Plugins

### peerlytics

Protocol analytics, market intelligence, and explorer data via the [Peerlytics API](https://peerlytics.xyz/developers). **Requires API key.**

```bash
export PEERLYTICS_API_KEY=pk_live_your_key_here
```

| Skill | Description |
|-------|-------------|
| `/peerlytics:analytics [range]` | Protocol volume, deposits, intents, fill times, top currencies |
| `/peerlytics:explorer [query]` | Look up addresses, deposits, intents, or transaction hashes |
| `/peerlytics:leaderboard [limit]` | Top makers and takers by volume |
| `/peerlytics:market [currency\|platform]` | Live rates, liquidity, and rate distributions |
| `/peerlytics:activity [filters]` | Recent events with natural language filtering |

All skills fetch live data from the API. Each request consumes 1 credit from your plan (free tier: 1,000/month).

### usdctofiat

Deposit guides, rate optimization, and earnings projections for [USDCtoFiat](https://usdctofiat.xyz) -- the P2P USDC on/off-ramp on Base.

| Skill | Description |
|-------|-------------|
| `/usdctofiat:create-deposit [args]` | Create USDC deposits via direct contract calls (cast/viem). No SDK required. |
| `/usdctofiat:deposit-guide` | How to create and manage USDC deposits |
| `/usdctofiat:rate-strategy [currency] [platform]` | P35 rate optimization with live market positioning |
| `/usdctofiat:earnings-calc [amount] [rate] [currency]` | Monthly earnings projections, sensitivity analysis, depletion estimates |
| `/usdctofiat:onramp-guide` | How to buy USDC with fiat via ZKP2P |

These skills use the Peerlytics API for live platform data, market rates, and FX references. Set `PEERLYTICS_API_KEY` for the best experience. Without a key, skills provide conceptual guidance.

## How It Works

Each skill is a markdown prompt that tells Claude how to fetch and present data. When you invoke a skill:

1. Claude checks for your `PEERLYTICS_API_KEY`
2. Fetches live data from the [Peerlytics API](https://peerlytics.xyz/api/v1)
3. Presents results in a clean, formatted summary
4. Suggests related skills for follow-up

No hardcoded data -- all numbers, rates, platforms, and currencies come from the API at query time.

## API Key

Get a free API key at [peerlytics.xyz/developers](https://peerlytics.xyz/developers) (1,000 requests/month). Add it to your shell profile:

```bash
# ~/.zshrc or ~/.bashrc
export PEERLYTICS_API_KEY=pk_live_your_key_here
```

## Links

| | |
|---|---|
| **USDCtoFiat** | [usdctofiat.xyz](https://usdctofiat.xyz) -- P2P USDC on/off-ramp on Base |
| **Peerlytics** | [peerlytics.xyz](https://peerlytics.xyz) -- Protocol analytics dashboard |
| **Peerlytics API** | [peerlytics.xyz/developers](https://peerlytics.xyz/developers) -- API docs and key management |
| **ZKP2P Protocol** | [zkp2p.xyz](https://zkp2p.xyz) -- The underlying P2P protocol |

## License

MIT
