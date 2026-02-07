# USDCtoFiat Plugin

Deposit guides, rate strategy, and earnings calculators for [USDCtoFiat](https://usdctofiat.xyz) -- the P2P USDC on/off-ramp on Base.

## Setup

1. Install:
   ```
   /plugin marketplace add ADWilkinson/peer-tools
   /plugin install usdctofiat@peer-tools
   ```
2. For live data (recommended), set your [Peerlytics API key](https://peerlytics.xyz/developers):
   ```bash
   export PEERLYTICS_API_KEY=pk_live_your_key_here
   ```

All skills fetch live platform data, market rates, and FX references from the Peerlytics API when a key is available. Without a key, skills provide conceptual guidance. The earnings calculator requires a key for accurate projections.

## Skills

### `/usdctofiat:deposit-guide`

How to create and manage USDC deposits. Fetches live platform/currency data and current market state.

```
/usdctofiat:deposit-guide
```

### `/usdctofiat:rate-strategy [currency] [platform]`

Rate optimization using the P35 percentile strategy with live market positioning.

```
/usdctofiat:rate-strategy GBP revolut
/usdctofiat:rate-strategy EUR
/usdctofiat:rate-strategy USD venmo
```

### `/usdctofiat:earnings-calc [amount] [rate] [currency]`

Monthly earnings projections, sensitivity analysis, and depletion estimates using live FX rates. **Requires API key.**

```
/usdctofiat:earnings-calc 1000 0.74 GBP
/usdctofiat:earnings-calc 5000 1.01 USD
/usdctofiat:earnings-calc 2000 0.92 EUR
```

### `/usdctofiat:onramp-guide`

How to buy USDC with fiat via USDCtoFiat. Fetches live platform availability.

```
/usdctofiat:onramp-guide
```

## Links

- [USDCtoFiat](https://usdctofiat.xyz)
- [Peerlytics API](https://peerlytics.xyz/developers) -- Get your API key
- [ZKP2P Protocol](https://zkp2p.xyz)
