
## 💎 Subscription-Based Payment Contract (Clarity)

A smart contract built on the **Stacks blockchain** that enables **recurring, stream-based payments** — allowing users to subscribe to creators, services, or platforms using continuous STX payments over time.

This system provides a **trustless, automated, and transparent** way to handle subscriptions without intermediaries.

---

### 🚀 Features

* 🔁 **Continuous streaming payments** — STX tokens flow from subscribers to creators block-by-block.
* 💳 **Refuel system** — Add funds anytime to extend or top up subscriptions.
* 🔒 **Cancelable and refundable** — Subscribers can cancel and reclaim unused funds.
* ⏱ **Auto-renew option** — Automatically extends the subscription period if enabled.
* 🪙 **Flexible pricing tiers** — Creators can define different rates (e.g., "Gold", "Silver").
* 👀 **Real-time balance tracking** — Both parties can check earned or remaining balance at any time.

---

### 🧠 Smart Contract Overview

This Clarity contract is a modified version of a **token streaming system**, adapted for **subscription management**.
Each active subscription acts like a “stream” where tokens are released gradually over time.

#### 🔹 Core Concepts

| Term                  | Description                                    |
| --------------------- | ---------------------------------------------- |
| **Subscriber**        | The user paying for the service                |
| **Creator**           | The service provider or content creator        |
| **Subscription ID**   | A unique ID that represents each active stream |
| **Payment Per Block** | The amount of STX transferred per block        |
| **Timeframe**         | Defines when a subscription starts and stops   |
| **Auto-Renew**        | Flag to automatically restart a subscription   |
| **Balance**           | Total locked STX for a given subscription      |

---

### ⚙️ Contract Functions

#### 🏗️ **Public Functions**

| Function                                                                                       | Description                                       |
| ---------------------------------------------------------------------------------------------- | ------------------------------------------------- |
| `create-subscription(creator, tier, payment-per-block, duration, initial-balance, auto-renew)` | Starts a new subscription stream                  |
| `refuel-subscription(subscription-id, amount)`                                                 | Adds more funds to an active subscription         |
| `withdraw(subscription-id)`                                                                    | Creator withdraws earned funds                    |
| `cancel-subscription(subscription-id)`                                                         | Subscriber cancels and receives remaining balance |
| `renew-subscription(subscription-id, extra-duration)`                                          | Restarts the subscription after it ends           |
| `get-subscription(subscription-id)`                                                            | Returns details of a subscription                 |

#### 🔍 **Read-Only Functions**

| Function                           | Description                                       |
| ---------------------------------- | ------------------------------------------------- |
| `calculate-block-delta(timeframe)` | Computes the number of blocks elapsed since start |
| `balance-of(subscription-id, who)` | Gets available or remaining balance for a user    |

---

### 🧾 Example Flow

#### ✅ Step 1 — Create a Subscription

```clarity
(contract-call? .subscription create-subscription 
  'ST3ABCXYZ.creator 
  "gold" 
  u10   ;; STX per block
  u500  ;; duration in blocks
  u5000 ;; total deposit
  true  ;; auto-renew
)
```

#### 💰 Step 2 — Creator Withdraws Earned STX

```clarity
(contract-call? .subscription withdraw u0)
```

#### 🧍 Step 3 — Subscriber Cancels Subscription

```clarity
(contract-call? .subscription cancel-subscription u0)
```

#### 🔁 Step 4 — Renew Automatically

```clarity
(contract-call? .subscription renew-subscription u0 u500)
```

---

### 🧩 Architecture Summary

```plaintext
┌──────────────────────────┐
│  Subscriber (User)       │
│  - Creates stream         │
│  - Can refuel/cancel      │
└────────────┬─────────────┘
             │
     STX locked in contract
             │
┌────────────▼─────────────┐
│  Subscription Contract   │
│  - Tracks active streams │
│  - Calculates balances   │
│  - Handles auto-renewal  │
└────────────┬─────────────┘
             │
      Periodic withdrawals
             │
┌────────────▼─────────────┐
│   Creator (Service)      │
│   - Withdraws earnings   │
└──────────────────────────┘
```

---

### 🛡️ Security & Trust Model

* STX funds are **locked** in the contract until withdrawn or refunded.
* Only the rightful **creator** can withdraw earned tokens.
* Only the **subscriber** can cancel or refuel their subscription.
* All state changes are fully transparent and auditable on-chain.

---

### 🧱 Future Enhancements

* 💵 **SIP-010 token support** (for USDC, wrapped BTC, or stable tokens)
* 🧠 **Subscription NFTs** (representing active or historical subscriptions)
* 📊 **Analytics dashboard** for creators and DAOs
* 🏦 **Batch subscriptions** for multiple users at once

---

### 🧑‍💻 Developer Setup

1. **Install the Stacks CLI**

   ```bash
   npm install -g @stacks/cli
   ```
2. **Deploy Contract**

   ```bash
   clarinet contract publish subscription
   ```
3. **Run Tests**

   ```bash
   clarinet test
   ```

---

### ⚖️ License

MIT License © 2025
Created by [**Mubarak Aminu**](https://github.com/mubarak23)

> “Empowering creators and developers with unstoppable subscription infrastructure on Bitcoin through Stacks.” ⚡


