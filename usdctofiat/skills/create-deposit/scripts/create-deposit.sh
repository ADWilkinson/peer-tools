#!/usr/bin/env bash
set -euo pipefail

# create-deposit.sh -- Create a USDC deposit on ZKP2P V3 via cast (Foundry)
# Usage: ./create-deposit.sh --amount 100 --platform revolut --currency GBP --identifier myrevtag --rate 0.74
# Optional: --delegate, --min-intent, --max-intent, --rpc-url

# --- Constants ---
USDC="0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913"
ESCROW="0x2f121CDDCA6d652f35e8B3E560f9760898888888"
GATING="0x396D31055Db28C0C6f36e8b36f18FE7227248a97"
DELEGATE_BOT="0x25caEcB47ABB1363BA932F5Ea05c61488604562b"
ZERO_ADDR="0x0000000000000000000000000000000000000000"
ZERO_BYTES32="0x0000000000000000000000000000000000000000000000000000000000000000"
RPC="https://mainnet.base.org"
API_URL="https://api.zkp2p.xyz/v1"

# --- Payment Method Hashes ---
declare -A METHOD_HASHES=(
  [venmo]="0x90262a3db0edd0be2369c6b28f9e8511ec0bac7136cefbada0880602f87e7268"
  [cashapp]="0x10940ee67cfb3c6c064569ec92c0ee934cd7afa18dd2ca2d6a2254fcb009c17d"
  [chime]="0x5908bb0c9b87763ac6171d4104847667e7f02b4c47b574fe890c1f439ed128bb"
  [revolut]="0x617f88ab82b5c1b014c539f7e75121427f0bb50a4c58b187a238531e7d58605d"
  [wise]="0x554a007c2217df766b977723b276671aee5ebb4adaea0edb6433c88b3e61dac5"
  [zelle-citi]="0x817260692b75e93c7fbc51c71637d4075a975e221e1ebc1abeddfabd731fd90d"
  [zelle-chase]="0x6aa1d1401e79ad0549dced8b1b96fb72c41cd02b32a7d9ea1fed54ba9e17152e"
  [zelle-bofa]="0x4bc42b322a3ad413b91b2fde30549ca70d6ee900eded1681de91aaf32ffd7ab5"
  [paypal]="0x3ccc3d4d5e769b1f82dc4988485551dc0cd3c7a3926d7d8a4dde91507199490f"
  [monzo]="0x62c7ed738ad3e7618111348af32691b5767777fbaf46a2d8943237625552645c"
  [n26]="0xd9ff4fd6b39a3e3dd43c41d05662a5547de4a878bc97a65bcb352ade493cdc6b"
)

# --- Currency Hashes ---
declare -A CURRENCY_HASHES=(
  [USD]="0xc4ae21aac0c6549d71dd96035b7e0bdb6c79ebdba8891b666115bc976d16a29e"
  [EUR]="0xfff16d60be267153303bbfa66e593fb8d06e24ea5ef24b6acca5224c2ca6b907"
  [GBP]="0x90832e2dc3221e4d56977c1aa8f6a6706b9ad6542fbbdaac13097d0fa5e42e67"
  [AUD]="0xcb83cbb58eaa5007af6cad99939e4581c1e1b50d65609c30f303983301524ef3"
  [CAD]="0x221012e06ebf59a20b82e3003cf5d6ee973d9008bdb6e2f604faa89a27235522"
  [SGD]="0xc241cc1f9752d2d53d1ab67189223a3f330e48b75f73ebf86f50b2c78fe8df88"
  [NZD]="0xdbd9d34f382e9f6ae078447a655e0816927c7c3edec70bd107de1d34cb15172e"
  [CHF]="0xc9d84274fd58aa177cabff54611546051b74ad658b939babaad6282500300d36"
  [MXN]="0xa94b0702860cb929d0ee0c60504dd565775a058bf1d2a2df074c1db0a66ad582"
  [JPY]="0xfe13aafd831cb225dfce3f6431b34b5b17426b6bff4fccabe4bbe0fe4adc0452"
  [AED]="0x4dab77a640748de8588de6834d814a344372b205265984b969f3e97060955bfa"
  [ARS]="0x8fd50654b7dd2dc839f7cab32800ba0c6f7f66e1ccf89b21c09405469c2175ec"
  [CNY]="0xfaaa9c7b2f09d6a1b0971574d43ca62c3e40723167c09830ec33f06cec921381"
  [CZK]="0xd783b199124f01e5d0dde2b7fc01b925e699caea84eae3ca92ed17377f498e97"
  [DKK]="0x5ce3aa5f4510edaea40373cbe83c091980b5c92179243fe926cb280ff07d403e"
  [HKD]="0xa156dad863111eeb529c4b3a2a30ad40e6dcff3b27d8f282f82996e58eee7e7d"
  [HUF]="0x7766ee347dd7c4a6d5a55342d89e8848774567bcf7a5f59c3e82025dbde3babb"
  [IDR]="0xc681c4652bae8bd4b59bec1cdb90f868d93cc9896af9862b196843f54bf254b3"
  [ILS]="0x313eda7ae1b79890307d32a78ed869290aeb24cc0e8605157d7e7f5a69fea425"
  [INR]="0xaad766fbc07fb357bed9fd8b03b935f2f71fe29fc48f08274bc2a01d7f642afc"
  [KES]="0x589be49821419c9c2fbb26087748bf3420a5c13b45349828f5cac24c58bbaa7b"
  [MYR]="0xf20379023279e1d79243d2c491be8632c07cfb116be9d8194013fb4739461b84"
  [NOK]="0x8fb505ed75d9d38475c70bac2c3ea62d45335173a71b2e4936bd9f05bf0ddfea"
  [PHP]="0xe6c11ead4ee5ff5174861adb55f3e8fb2841cca69bf2612a222d3e8317b6ae06"
  [PLN]="0x9a788fb083188ba1dfb938605bc4ce3579d2e085989490aca8f73b23214b7c1d"
  [RON]="0x2dd272ddce846149d92496b4c3e677504aec8d5e6aab5908b25c9fe0a797e25f"
  [SAR]="0xf998cbeba8b7a7e91d4c469e5fb370cdfa16bd50aea760435dc346008d78ed1f"
  [SEK]="0x8895743a31faedaa74150e89d06d281990a1909688b82906f0eb858b37f82190"
  [THB]="0x326a6608c2a353275bd8d64db53a9d772c1d9a5bc8bfd19dfc8242274d1e9dd4"
  [TRY]="0x128d6c262d1afe2351c6e93ceea68e00992708cfcbc0688408b9a23c0c543db2"
  [UGX]="0x1fad9f8ddef06bf1b8e0e28c11b97ca0df51b03c268797e056b7c52e9048cfd1"
  [VND]="0xe85548baf0a6732cfcc7fc016ce4fd35ce0a1877057cfec6e166af4f106a3728"
  [ZAR]="0x53611f0b3535a2cfc4b8deb57fa961ca36c7b2c272dfe4cb239a29c48e549361"
)

# --- Parse Args ---
AMOUNT="" PLATFORM="" CURRENCY="" IDENTIFIER="" RATE=""
DELEGATE="$ZERO_ADDR" MIN_INTENT="5" MAX_INTENT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --amount) AMOUNT="$2"; shift 2 ;;
    --platform) PLATFORM="$2"; shift 2 ;;
    --currency) CURRENCY="$2"; shift 2 ;;
    --identifier) IDENTIFIER="$2"; shift 2 ;;
    --rate) RATE="$2"; shift 2 ;;
    --delegate) DELEGATE="$2"; shift 2 ;;
    --min-intent) MIN_INTENT="$2"; shift 2 ;;
    --max-intent) MAX_INTENT="$2"; shift 2 ;;
    --rpc-url) RPC="$2"; shift 2 ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

# --- Validate ---
[[ -z "$AMOUNT" ]] && echo "Error: --amount required" && exit 1
[[ -z "$PLATFORM" ]] && echo "Error: --platform required" && exit 1
[[ -z "$CURRENCY" ]] && echo "Error: --currency required" && exit 1
[[ -z "$IDENTIFIER" ]] && echo "Error: --identifier required" && exit 1
[[ -z "$RATE" ]] && echo "Error: --rate required" && exit 1
[[ -z "$PRIVATE_KEY" ]] && echo "Error: PRIVATE_KEY env var required" && exit 1

METHOD_HASH="${METHOD_HASHES[$PLATFORM]:-}"
[[ -z "$METHOD_HASH" ]] && echo "Error: unknown platform '$PLATFORM'" && exit 1

CURRENCY_HASH="${CURRENCY_HASHES[$CURRENCY]:-}"
[[ -z "$CURRENCY_HASH" ]] && echo "Error: unknown currency '$CURRENCY'" && exit 1

# --- Compute values ---
AMOUNT_UNITS=$(echo "$AMOUNT * 1000000" | bc | cut -d. -f1)
MIN_UNITS=$(echo "$MIN_INTENT * 1000000" | bc | cut -d. -f1)
MAX_INTENT="${MAX_INTENT:-$AMOUNT}"
MAX_UNITS=$(echo "$MAX_INTENT * 1000000" | bc | cut -d. -f1)
RATE_18=$(echo "$RATE * 1000000000000000000" | bc | cut -d. -f1)

echo "=== ZKP2P Deposit Creation ==="
echo "Amount: $AMOUNT USDC ($AMOUNT_UNITS units)"
echo "Platform: $PLATFORM"
echo "Currency: $CURRENCY"
echo "Rate: $RATE ($RATE_18 wei)"
echo "Intent range: $MIN_INTENT - $MAX_INTENT USDC"
echo "Delegate: $DELEGATE"
echo ""

# --- Platform-specific depositData field names ---
declare -A DEPOSIT_DATA_KEYS=(
  [venmo]="venmoUsername"
  [cashapp]="cashtag"
  [chime]="chimesign"
  [revolut]="revolutUsername"
  [wise]="wisetag"
  [zelle-citi]="zelleEmail"
  [zelle-chase]="zelleEmail"
  [zelle-bofa]="zelleEmail"
  [paypal]="paypalEmail"
  [monzo]="monzoMeUsername"
  [n26]="iban"
)

# --- Step 1: Register payee (if API key available) ---
PAYEE_DETAILS="$ZERO_BYTES32"
if [[ -n "${ZKP2P_API_KEY:-}" ]]; then
  echo "Step 1: Registering payee details..."
  API_PROCESSOR="$PLATFORM"
  [[ "$PLATFORM" == zelle-* ]] && API_PROCESSOR="zelle"

  DATA_KEY="${DEPOSIT_DATA_KEYS[$PLATFORM]:-}"
  [[ -z "$DATA_KEY" ]] && echo "Error: no depositData key for '$PLATFORM'" && exit 1

  RESPONSE=$(curl -s -X POST "$API_URL/makers/create" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $ZKP2P_API_KEY" \
    -H "X-API-Key: $ZKP2P_API_KEY" \
    -d "{\"processorName\":\"$API_PROCESSOR\",\"depositData\":{\"$DATA_KEY\":\"$IDENTIFIER\",\"telegramUsername\":\"\"}}")

  PAYEE_DETAILS=$(echo "$RESPONSE" | jq -r '.responseObject.hashedOnchainId // empty')
  if [[ -z "$PAYEE_DETAILS" ]]; then
    echo "Warning: Could not get hashedOnchainId. Response: $RESPONSE"
    echo "Proceeding with zero payee details (deposit will work but buyers can't verify payment)."
    PAYEE_DETAILS="$ZERO_BYTES32"
  else
    echo "Payee registered: $PAYEE_DETAILS"
  fi
else
  echo "Step 1: Skipping payee registration (ZKP2P_API_KEY not set)"
  echo "Warning: Without payee registration, buyers cannot verify your payment details."
fi
echo ""

# --- Step 2: Approve USDC ---
echo "Step 2: Approving USDC..."
APPROVE_TX=$(cast send "$USDC" \
  "approve(address,uint256)" \
  "$ESCROW" "$AMOUNT_UNITS" \
  --rpc-url "$RPC" \
  --private-key "$PRIVATE_KEY" \
  --json | jq -r '.transactionHash')
echo "Approval tx: $APPROVE_TX"
echo ""

# --- Step 3: Create deposit ---
echo "Step 3: Creating deposit..."

# Handle delegate: use delegate bot address if --delegate flag passed
[[ "$DELEGATE" == "delegate" ]] && DELEGATE="$DELEGATE_BOT"

DEPOSIT_TX=$(cast send "$ESCROW" \
  "createDeposit((address,uint256,(uint256,uint256),bytes32[],(address,bytes32,bytes)[],((bytes32,uint256)[])[],address,address,bool))" \
  "($USDC, $AMOUNT_UNITS, ($MIN_UNITS,$MAX_UNITS), [$METHOD_HASH], [($GATING,$PAYEE_DETAILS,0x)], [[($CURRENCY_HASH,$RATE_18)]], $DELEGATE, $ZERO_ADDR, false)" \
  --rpc-url "$RPC" \
  --private-key "$PRIVATE_KEY" \
  --json | jq -r '.transactionHash')
echo "Deposit tx: $DEPOSIT_TX"
echo ""

# --- Step 4: Parse deposit ID from receipt ---
echo "Step 4: Parsing deposit ID..."
sleep 2

EVENT_SIG=$(cast sig-event "DepositReceived(uint256,address,address,uint256,(uint256,uint256),address,address)")
DEPOSIT_ID=$(cast receipt "$DEPOSIT_TX" --rpc-url "$RPC" --json | \
  jq -r ".logs[] | select(.topics[0] == \"$EVENT_SIG\") | .topics[1]" | \
  cast to-dec 2>/dev/null || echo "")

if [[ -n "$DEPOSIT_ID" ]]; then
  echo "Deposit created successfully!"
  echo "Deposit ID: $DEPOSIT_ID"
  echo "View: https://usdctofiat.xyz (connect wallet to see deposit)"
else
  echo "Deposit created but could not parse ID from receipt."
  echo "Check tx on basescan: https://basescan.org/tx/$DEPOSIT_TX"
fi
