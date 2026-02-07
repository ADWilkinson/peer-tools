---
name: onramp-guide
description: Guide to buying USDC via USDCtoFiat - payment methods, verification flow, and troubleshooting
user-invocable: true
allowed-tools:
---

<onramp-guide>

You are a USDCtoFiat onramp guide assistant. Provide a comprehensive guide for buying USDC (onramping) through USDCtoFiat (https://usdctofiat.xyz).

## Guide

Present the following information in a clear, structured format:

### What is Onramping?

Onramping is converting fiat currency (USD, GBP, EUR, etc.) into USDC via the USDCtoFiat peer-to-peer marketplace. Instead of using a centralized exchange, you buy directly from individual sellers (depositors) at competitive rates. Payment verification is handled by zero-knowledge proofs -- no intermediary holds your funds.

### How It Works (Overview)

1. You choose how much USDC you want to buy
2. The system matches you with the best available deposit(s)
3. You send fiat to the seller via a supported payment platform
4. A zero-knowledge proof verifies your payment on-chain
5. USDC is released from escrow directly to your wallet
6. The seller receives your fiat in their payment account

No KYC. No centralized custody. Fully peer-to-peer.

### Step-by-Step: Buying USDC

1. **Connect your wallet** at https://usdctofiat.xyz
   - Smart wallet (created in-app), cross-app wallet, or external EOA
   - Make sure you're on Base network

2. **Navigate to "Buy USDC"**

3. **Enter the amount you want to buy**
   - Amount in USDC or fiat equivalent
   - Choose your payment currency

4. **Select a payment method**
   - The system shows available deposits sorted by best rate (cheapest first)
   - You'll see the rate, payment platform, and available amount for each listing

5. **Signal intent**
   - This locks the seller's liquidity for your purchase
   - You have approximately **30 minutes** to complete payment
   - If you don't pay in time, the intent expires and the liquidity unlocks

6. **Send payment to the seller**
   - **Desktop**: Use the PeerAuth browser extension to complete payment
   - **Mobile**: Use the Peer Mobile app
   - Pay the exact amount shown to the seller's payment account
   - Do NOT round up/down -- the exact amount matters for ZK verification

7. **Payment verification**
   - The ZK proof system verifies your payment automatically
   - This typically takes 1-5 minutes after payment
   - USDC is released from escrow to your wallet

8. **Done!**
   - USDC appears in your wallet on Base
   - A 1% referral fee (ERC-8081) is applied to the transaction

### Payment Verification Tools

| Tool | Platform | What It Does |
|------|----------|-------------|
| **PeerAuth Extension** | Desktop (Chrome) | Browser extension that generates ZK proofs from your payment confirmation emails/screens |
| **Peer Mobile** | iOS / Android | Mobile app for payment verification on the go |

Both tools work by generating a zero-knowledge proof that you made the payment, without revealing your personal financial data.

### Payment Methods Available

| Platform | Currencies | Best For |
|----------|-----------|----------|
| Venmo | USD | US users, social payments |
| Cash App | USD | US users, instant transfers |
| Chime | USD | US users |
| Zelle | USD | US users, bank-linked |
| PayPal | USD, EUR, GBP, SGD, NZD, AUD, CAD | International users |
| Revolut | USD, EUR, GBP + 20 more | European/international users |
| Wise | USD, EUR, GBP + 25 more | International transfers, best currency coverage |
| Monzo | GBP | UK users |
| N26 | EUR | EU users |

### What to Expect: Typical Timeline

| Step | Typical Duration |
|------|-----------------|
| Finding a deposit & signaling intent | 1-2 minutes |
| Sending fiat payment | 1-5 minutes (depends on platform) |
| ZK proof generation & verification | 1-5 minutes |
| USDC received in wallet | Instant after verification |
| **Total end-to-end** | **5-15 minutes** |

### Fees

- **Network gas**: Negligible on Base (<$0.01)
- **Referral fee**: 1% of transaction (ERC-8081 standard)
- **Rate spread**: Built into the seller's rate (this is how sellers earn). A rate of 1.02 USD/USDC means you pay $1.02 per USDC

### Troubleshooting

**Intent expired (30 minute timeout)**
- If you didn't pay in time, the intent expires automatically
- Your fiat was NOT sent (or if sent, the seller still has your fiat -- contact support)
- You can signal a new intent and try again

**Payment verification stuck**
- Make sure you used the exact amount shown (not rounded)
- Ensure you sent to the correct payment account/identifier
- Try refreshing the PeerAuth extension or Peer Mobile app
- ZK proof generation can take up to 5 minutes -- be patient

**"No deposits available"**
- Try a different payment method or currency
- Check back later -- new deposits are created regularly
- Consider less common payment methods which may have more availability

**Wrong amount sent**
- If you sent the wrong amount, the ZK proof will fail
- Contact the seller directly or wait for the intent to expire
- The seller can manually release if they confirm receipt

**Transaction on wrong network**
- Make sure your wallet is connected to Base (chain ID 8453)
- USDCtoFiat only operates on Base L2

### Tips for Buyers

1. **Compare rates**: Lower rates mean cheaper USDC. The system sorts by best rate automatically
2. **Have your payment app ready**: The 30-minute window starts when you signal intent. Be prepared to pay immediately
3. **Use the right tool**: PeerAuth extension for desktop, Peer Mobile for mobile
4. **Start small**: Try a small amount first to get familiar with the flow
5. **Check availability by platform**: Some platforms have more liquidity than others. Revolut GBP and Venmo USD tend to have the most

### Follow-ups

- `/usdctofiat:deposit-guide` -- Want to sell USDC instead? Learn how to create a deposit
- `/usdctofiat:rate-strategy` -- Understand how rates work across the platform
- `/usdctofiat:earnings-calc` -- Calculate potential earnings as a seller

</onramp-guide>
