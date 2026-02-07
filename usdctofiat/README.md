# USDCtoFiat Plugin for Claude Code

Guides, rate strategy, and earnings calculators for [USDCtoFiat](https://usdctofiat.xyz) -- the peer-to-peer USDC on/off-ramp on Base.

## What's Included

| Skill | Command | Description |
|-------|---------|-------------|
| Deposit Guide | `/usdctofiat:deposit-guide` | Step-by-step guide to creating USDC deposits, platform comparison, rate tips |
| Rate Strategy | `/usdctofiat:rate-strategy` | Rate optimization using the P35 percentile strategy, platform-specific advice |
| Earnings Calculator | `/usdctofiat:earnings-calc` | Monthly earnings projections, sensitivity analysis, depletion estimates |
| Onramp Guide | `/usdctofiat:onramp-guide` | How to buy USDC via USDCtoFiat, payment methods, troubleshooting |

All skills are **free** -- no API key required. They use built-in domain knowledge about the USDCtoFiat platform, ZKP2P protocol, and P2P trading strategies.

## Installation

Add the peer-tools marketplace and install:

```
/plugin marketplace add ADWilkinson/peer-tools
/plugin install usdctofiat@peer-tools
```

## Usage

### Deposit Guide

Get a comprehensive guide to creating and managing USDC deposits:

```
/usdctofiat:deposit-guide
```

Covers: wallet setup, deposit creation flow, supported platforms and currencies, rate strategies, multi-payment tips, common mistakes, and gas fees on Base.

### Rate Strategy

Get rate optimization advice for a specific currency and platform:

```
/usdctofiat:rate-strategy GBP revolut
/usdctofiat:rate-strategy EUR
/usdctofiat:rate-strategy USD venmo
```

Explains the P35 percentile strategy, when to raise or lower rates, and platform-specific tips. Optionally fetches live market data if `PEERLYTICS_API_KEY` is set.

### Earnings Calculator

Project your monthly earnings based on deposit size, rate, and currency:

```
/usdctofiat:earnings-calc 1000 0.74 GBP
/usdctofiat:earnings-calc 5000 1.01 USD
/usdctofiat:earnings-calc 2000 0.92 EUR
```

Outputs: monthly earnings at slow/moderate/fast fill velocities, sensitivity table at +/-2% rate, time to depletion, and break-even rate.

### Onramp Guide

Learn how to buy USDC through USDCtoFiat:

```
/usdctofiat:onramp-guide
```

Covers: step-by-step buy flow, PeerAuth extension vs Peer Mobile, payment method comparison, typical timeline, fees, and troubleshooting.

## Optional: Live Market Data

The `rate-strategy` skill can optionally fetch live market data from the Peerlytics API. To enable this:

1. Get an API key at https://peerlytics.xyz/developers
2. Set the environment variable:

```bash
export PEERLYTICS_API_KEY=pk_live_your_key
```

Without the key, rate-strategy still provides general guidance based on embedded knowledge. No other skills require an API key.

## Links

- **USDCtoFiat**: https://usdctofiat.xyz
- **Peerlytics** (analytics): https://peerlytics.xyz
- **ZKP2P Protocol**: https://zkp2p.xyz
