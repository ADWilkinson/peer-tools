# Platforms and Currencies Reference

## Payment Platforms

### venmo

| Field | Value |
|-------|-------|
| Hash | `0x90262a3db0edd0be2369c6b28f9e8511ec0bac7136cefbada0880602f87e7268` |
| Field Type | Username (no @) |
| Validation | `^[a-zA-Z0-9_-]+$` |
| Currencies | USD |
| depositData | `{"venmoUsername": "...", "telegramUsername": ""}` |

### cashapp

| Field | Value |
|-------|-------|
| Hash | `0x10940ee67cfb3c6c064569ec92c0ee934cd7afa18dd2ca2d6a2254fcb009c17d` |
| Field Type | Cashtag (no $) |
| Validation | `^[a-zA-Z0-9]+$` |
| Currencies | USD |
| depositData | `{"cashtag": "...", "telegramUsername": ""}` |

### chime

| Field | Value |
|-------|-------|
| Hash | `0x5908bb0c9b87763ac6171d4104847667e7f02b4c47b574fe890c1f439ed128bb` |
| Field Type | ChimeSign (with $, lowercase) |
| Validation | `^\$[a-zA-Z0-9]+$` (must start with $) |
| Transform | Lowercase, prepend $ if missing |
| Currencies | USD |
| depositData | `{"chimesign": "$...", "telegramUsername": ""}` |

### revolut

| Field | Value |
|-------|-------|
| Hash | `0x617f88ab82b5c1b014c539f7e75121427f0bb50a4c58b187a238531e7d58605d` |
| Field Type | Revtag (no @) |
| Validation | `^[a-zA-Z0-9]+$` |
| Currencies | USD, EUR, GBP, SGD, NZD, AUD, CAD, HKD, MXN, SAR, AED, THB, TRY, PLN, CHF, ZAR, CZK, CNY, DKK, HUF, NOK, RON, SEK |
| depositData | `{"revolutUsername": "...", "telegramUsername": ""}` |

### wise

| Field | Value |
|-------|-------|
| Hash | `0x554a007c2217df766b977723b276671aee5ebb4adaea0edb6433c88b3e61dac5` |
| Field Type | Wisetag (no @) |
| Validation | `^[a-zA-Z0-9_-]+$` |
| Currencies | USD, CNY, EUR, GBP, AUD, NZD, CAD, AED, CHF, ZAR, SGD, ILS, HKD, JPY, PLN, TRY, IDR, KES, MYR, MXN, THB, VND, UGX, CZK, DKK, HUF, INR, NOK, PHP, RON, SEK |
| depositData | `{"wisetag": "...", "telegramUsername": ""}` |

### zelle-citi

| Field | Value |
|-------|-------|
| Hash | `0x817260692b75e93c7fbc51c71637d4075a975e221e1ebc1abeddfabd731fd90d` |
| Field Type | Email |
| Validation | Valid email format |
| Currencies | USD |
| API processorName | `zelle` (use canonical name for API registration) |
| depositData | `{"zelleEmail": "...", "telegramUsername": ""}` |

### zelle-chase

| Field | Value |
|-------|-------|
| Hash | `0x6aa1d1401e79ad0549dced8b1b96fb72c41cd02b32a7d9ea1fed54ba9e17152e` |
| Field Type | Email |
| Validation | Valid email format |
| Currencies | USD |
| API processorName | `zelle` |
| depositData | `{"zelleEmail": "...", "telegramUsername": ""}` |

### zelle-bofa

| Field | Value |
|-------|-------|
| Hash | `0x4bc42b322a3ad413b91b2fde30549ca70d6ee900eded1681de91aaf32ffd7ab5` |
| Field Type | Email |
| Validation | Valid email format |
| Currencies | USD |
| API processorName | `zelle` |
| depositData | `{"zelleEmail": "...", "telegramUsername": ""}` |

### paypal

| Field | Value |
|-------|-------|
| Hash | `0x3ccc3d4d5e769b1f82dc4988485551dc0cd3c7a3926d7d8a4dde91507199490f` |
| Field Type | Email |
| Validation | Valid email format |
| Currencies | USD, EUR, GBP, SGD, NZD, AUD, CAD |
| depositData | `{"paypalEmail": "...", "telegramUsername": ""}` |

### monzo

| Field | Value |
|-------|-------|
| Hash | `0x62c7ed738ad3e7618111348af32691b5767777fbaf46a2d8943237625552645c` |
| Field Type | Monzo.me username |
| Validation | `^[a-zA-Z0-9_-]+$` |
| Currencies | GBP |
| depositData | `{"monzoMeUsername": "...", "telegramUsername": ""}` |

### n26

| Field | Value |
|-------|-------|
| Hash | `0xd9ff4fd6b39a3e3dd43c41d05662a5547de4a878bc97a65bcb352ade493cdc6b` |
| Field Type | IBAN (uppercase, no spaces) |
| Validation | `^[A-Z]{2}[0-9]{2}[A-Z0-9]+$`, 15-34 chars |
| Transform | Remove spaces, uppercase |
| Currencies | EUR |
| depositData | `{"iban": "...", "telegramUsername": ""}` |

### mercadopago (disabled)

| Field | Value |
|-------|-------|
| Hash | `0xa5418819c024239299ea32e09defae8ec412c03e58f5c75f1b2fe84c857f5483` |
| Field Type | CVU (22-digit number) |
| Validation | `^\d{22}$` |
| Currencies | ARS |
| depositData | `{"cvu": "...", "telegramUsername": ""}` |
| Status | **Disabled** -- do not use |

## All Currency Hashes

| Code | Name | bytes32 Hash |
|------|------|-------------|
| AED | UAE Dirham | `0x4dab77a640748de8588de6834d814a344372b205265984b969f3e97060955bfa` |
| ARS | Argentine Peso | `0x8fd50654b7dd2dc839f7cab32800ba0c6f7f66e1ccf89b21c09405469c2175ec` |
| AUD | Australian Dollar | `0xcb83cbb58eaa5007af6cad99939e4581c1e1b50d65609c30f303983301524ef3` |
| CAD | Canadian Dollar | `0x221012e06ebf59a20b82e3003cf5d6ee973d9008bdb6e2f604faa89a27235522` |
| CHF | Swiss Franc | `0xc9d84274fd58aa177cabff54611546051b74ad658b939babaad6282500300d36` |
| CNY | Chinese Yuan | `0xfaaa9c7b2f09d6a1b0971574d43ca62c3e40723167c09830ec33f06cec921381` |
| CZK | Czech Koruna | `0xd783b199124f01e5d0dde2b7fc01b925e699caea84eae3ca92ed17377f498e97` |
| DKK | Danish Krone | `0x5ce3aa5f4510edaea40373cbe83c091980b5c92179243fe926cb280ff07d403e` |
| EUR | Euro | `0xfff16d60be267153303bbfa66e593fb8d06e24ea5ef24b6acca5224c2ca6b907` |
| GBP | British Pound | `0x90832e2dc3221e4d56977c1aa8f6a6706b9ad6542fbbdaac13097d0fa5e42e67` |
| HKD | Hong Kong Dollar | `0xa156dad863111eeb529c4b3a2a30ad40e6dcff3b27d8f282f82996e58eee7e7d` |
| HUF | Hungarian Forint | `0x7766ee347dd7c4a6d5a55342d89e8848774567bcf7a5f59c3e82025dbde3babb` |
| IDR | Indonesian Rupiah | `0xc681c4652bae8bd4b59bec1cdb90f868d93cc9896af9862b196843f54bf254b3` |
| ILS | Israeli New Shekel | `0x313eda7ae1b79890307d32a78ed869290aeb24cc0e8605157d7e7f5a69fea425` |
| INR | Indian Rupee | `0xaad766fbc07fb357bed9fd8b03b935f2f71fe29fc48f08274bc2a01d7f642afc` |
| JPY | Japanese Yen | `0xfe13aafd831cb225dfce3f6431b34b5b17426b6bff4fccabe4bbe0fe4adc0452` |
| KES | Kenyan Shilling | `0x589be49821419c9c2fbb26087748bf3420a5c13b45349828f5cac24c58bbaa7b` |
| MXN | Mexican Peso | `0xa94b0702860cb929d0ee0c60504dd565775a058bf1d2a2df074c1db0a66ad582` |
| MYR | Malaysian Ringgit | `0xf20379023279e1d79243d2c491be8632c07cfb116be9d8194013fb4739461b84` |
| NOK | Norwegian Krone | `0x8fb505ed75d9d38475c70bac2c3ea62d45335173a71b2e4936bd9f05bf0ddfea` |
| NZD | New Zealand Dollar | `0xdbd9d34f382e9f6ae078447a655e0816927c7c3edec70bd107de1d34cb15172e` |
| PHP | Philippine Peso | `0xe6c11ead4ee5ff5174861adb55f3e8fb2841cca69bf2612a222d3e8317b6ae06` |
| PLN | Polish Zloty | `0x9a788fb083188ba1dfb938605bc4ce3579d2e085989490aca8f73b23214b7c1d` |
| RON | Romanian Leu | `0x2dd272ddce846149d92496b4c3e677504aec8d5e6aab5908b25c9fe0a797e25f` |
| SAR | Saudi Riyal | `0xf998cbeba8b7a7e91d4c469e5fb370cdfa16bd50aea760435dc346008d78ed1f` |
| SEK | Swedish Krona | `0x8895743a31faedaa74150e89d06d281990a1909688b82906f0eb858b37f82190` |
| SGD | Singapore Dollar | `0xc241cc1f9752d2d53d1ab67189223a3f330e48b75f73ebf86f50b2c78fe8df88` |
| THB | Thai Baht | `0x326a6608c2a353275bd8d64db53a9d772c1d9a5bc8bfd19dfc8242274d1e9dd4` |
| TRY | Turkish Lira | `0x128d6c262d1afe2351c6e93ceea68e00992708cfcbc0688408b9a23c0c543db2` |
| UGX | Ugandan Shilling | `0x1fad9f8ddef06bf1b8e0e28c11b97ca0df51b03c268797e056b7c52e9048cfd1` |
| USD | US Dollar | `0xc4ae21aac0c6549d71dd96035b7e0bdb6c79ebdba8891b666115bc976d16a29e` |
| VND | Vietnamese Dong | `0xe85548baf0a6732cfcc7fc016ce4fd35ce0a1877057cfec6e166af4f106a3728` |
| ZAR | South African Rand | `0x53611f0b3535a2cfc4b8deb57fa961ca36c7b2c272dfe4cb239a29c48e549361` |
