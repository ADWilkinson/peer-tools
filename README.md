# peer-tools

Claude Code plugins for the ZKP2P P2P trading ecosystem.

## Plugins

### [peerlytics](./peerlytics/)

Protocol analytics, market intelligence, and explorer data via the [Peerlytics API](https://peerlytics.xyz/developers). Requires API key.

**Skills**: `/peerlytics:analytics`, `/peerlytics:explorer`, `/peerlytics:leaderboard`, `/peerlytics:market`, `/peerlytics:activity`

### [usdctofiat](./usdctofiat/)

Deposit guides, rate strategy, and earnings calculators for [USDCtoFiat](https://usdctofiat.xyz). Free -- no API key required.

**Skills**: `/usdctofiat:deposit-guide`, `/usdctofiat:rate-strategy`, `/usdctofiat:earnings-calc`, `/usdctofiat:onramp-guide`

## Install

```
/plugin marketplace add ADWilkinson/peer-tools
/plugin install peerlytics@peer-tools
/plugin install usdctofiat@peer-tools
```

## Links

- [USDCtoFiat](https://usdctofiat.xyz) -- P2P USDC on/off-ramp on Base
- [Peerlytics](https://peerlytics.xyz) -- Protocol analytics dashboard
- [Peerlytics API](https://peerlytics.xyz/developers) -- API docs and key management
- [ZKP2P Protocol](https://zkp2p.xyz) -- The underlying technology
