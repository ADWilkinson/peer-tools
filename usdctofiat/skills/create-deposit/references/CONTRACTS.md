# Contract ABIs and Addresses

## Addresses

| Contract | Address | Chain |
|----------|---------|-------|
| USDC | `0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913` | Base (8453) |
| ZKP2P V3 Escrow | `0x2f121CDDCA6d652f35e8B3E560f9760898888888` | Base (8453) |
| Gating Service | `0x396D31055Db28C0C6f36e8b36f18FE7227248a97` | Base (8453) |
| Delegate Bot | `0x25caEcB47ABB1363BA932F5Ea05c61488604562b` | Base (8453) |

## Escrow Functions

### createDeposit

Creates a new USDC deposit in the escrow contract.

```json
{
  "name": "createDeposit",
  "type": "function",
  "stateMutability": "nonpayable",
  "inputs": [
    {
      "name": "_params",
      "type": "tuple",
      "components": [
        { "name": "token", "type": "address" },
        { "name": "amount", "type": "uint256" },
        {
          "name": "intentAmountRange",
          "type": "tuple",
          "components": [
            { "name": "min", "type": "uint256" },
            { "name": "max", "type": "uint256" }
          ]
        },
        { "name": "paymentMethods", "type": "bytes32[]" },
        {
          "name": "paymentMethodData",
          "type": "tuple[]",
          "components": [
            { "name": "intentGatingService", "type": "address" },
            { "name": "payeeDetails", "type": "bytes32" },
            { "name": "data", "type": "bytes" }
          ]
        },
        {
          "name": "currencies",
          "type": "tuple[][]",
          "components": [
            { "name": "code", "type": "bytes32" },
            { "name": "minConversionRate", "type": "uint256" }
          ]
        },
        { "name": "delegate", "type": "address" },
        { "name": "intentGuardian", "type": "address" },
        { "name": "retainOnEmpty", "type": "bool" }
      ]
    }
  ],
  "outputs": []
}
```

**Cast signature:**
```
createDeposit((address,uint256,(uint256,uint256),bytes32[],(address,bytes32,bytes)[],((bytes32,uint256)[])[],address,address,bool))
```

### getDeposit

Read deposit state by ID.

```json
{
  "name": "getDeposit",
  "type": "function",
  "stateMutability": "view",
  "inputs": [{ "name": "_depositId", "type": "uint256" }],
  "outputs": [
    {
      "type": "tuple",
      "components": [
        { "name": "depositor", "type": "address" },
        { "name": "token", "type": "address" },
        { "name": "availableBalance", "type": "uint256" },
        { "name": "lockedBalance", "type": "uint256" },
        {
          "name": "intentAmountRange",
          "type": "tuple",
          "components": [
            { "name": "min", "type": "uint256" },
            { "name": "max", "type": "uint256" }
          ]
        },
        { "name": "acceptingIntents", "type": "bool" },
        { "name": "intentCount", "type": "uint256" },
        { "name": "delegate", "type": "address" },
        { "name": "intentGuardian", "type": "address" },
        { "name": "retainOnEmpty", "type": "bool" }
      ]
    }
  ]
}
```

**Cast signature:**
```
getDeposit(uint256)((address,address,uint256,uint256,(uint256,uint256),bool,uint256,address,address,bool))
```

### addFunds

Add more USDC to an existing deposit.

```json
{
  "name": "addFunds",
  "type": "function",
  "stateMutability": "nonpayable",
  "inputs": [
    { "name": "_depositId", "type": "uint256" },
    { "name": "_amount", "type": "uint256" }
  ],
  "outputs": []
}
```

**Cast signature:**
```
addFunds(uint256,uint256)
```

### withdrawDeposit

Withdraw all available (unlocked) USDC from a deposit.

```json
{
  "name": "withdrawDeposit",
  "type": "function",
  "stateMutability": "nonpayable",
  "inputs": [{ "name": "depositId", "type": "uint256" }],
  "outputs": []
}
```

**Cast signature:**
```
withdrawDeposit(uint256)
```

### setCurrencyMinRate

Update the minimum conversion rate for a specific payment method + currency pair on a deposit.

```json
{
  "name": "setCurrencyMinRate",
  "type": "function",
  "stateMutability": "nonpayable",
  "inputs": [
    { "name": "_depositId", "type": "uint256" },
    { "name": "_paymentMethod", "type": "bytes32" },
    { "name": "_fiatCurrency", "type": "bytes32" },
    { "name": "_newMinConversionRate", "type": "uint256" }
  ],
  "outputs": []
}
```

**Cast signature:**
```
setCurrencyMinRate(uint256,bytes32,bytes32,uint256)
```

## Escrow Events

### DepositReceived

Emitted when a deposit is created successfully.

```json
{
  "type": "event",
  "name": "DepositReceived",
  "inputs": [
    { "name": "depositId", "type": "uint256", "indexed": true },
    { "name": "depositor", "type": "address", "indexed": true },
    { "name": "token", "type": "address", "indexed": true },
    { "name": "amount", "type": "uint256", "indexed": false },
    {
      "name": "intentAmountRange",
      "type": "tuple",
      "indexed": false,
      "components": [
        { "name": "min", "type": "uint256" },
        { "name": "max", "type": "uint256" }
      ]
    },
    { "name": "delegate", "type": "address", "indexed": false },
    { "name": "intentGuardian", "type": "address", "indexed": false }
  ]
}
```

**Event topic0:** Use `cast sig-event "DepositReceived(uint256,address,address,uint256,(uint256,uint256),address,address)"` to compute.

**Parsing with cast:**
```bash
# Get deposit ID from receipt logs
cast receipt $TX_HASH --rpc-url https://mainnet.base.org --json | \
  jq -r '.logs[] | select(.topics[0] == "'$(cast sig-event "DepositReceived(uint256,address,address,uint256,(uint256,uint256),address,address)")'") | .topics[1]' | \
  cast to-dec
```

## ERC20 (USDC)

### approve

```json
{
  "name": "approve",
  "type": "function",
  "stateMutability": "nonpayable",
  "inputs": [
    { "name": "spender", "type": "address" },
    { "name": "amount", "type": "uint256" }
  ],
  "outputs": [{ "type": "bool" }]
}
```

### allowance

```json
{
  "name": "allowance",
  "type": "function",
  "stateMutability": "view",
  "inputs": [
    { "name": "owner", "type": "address" },
    { "name": "spender", "type": "address" }
  ],
  "outputs": [{ "type": "uint256" }]
}
```

### balanceOf

```json
{
  "name": "balanceOf",
  "type": "function",
  "stateMutability": "view",
  "inputs": [{ "name": "account", "type": "address" }],
  "outputs": [{ "type": "uint256" }]
}
```
