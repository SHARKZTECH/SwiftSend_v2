# SwiftSend Technical System Overview

## 1. Informal Address Resolution System

SwiftSend uses a **multi-layered address resolution system** designed for Kenya's addressing challenges:

### Methods:

| Method                | Description                                                          |
| --------------------- | -------------------------------------------------------------------- |
| **Landmark Database** | 50,000+ indexed landmarks (Java House, schools, petrol stations)     |
| **Community Data**    | Successful delivery endpoints stored anonymously for future matching |
| **AI Interpretation** | ML model trained on 100K+ Kenyan delivery descriptions               |

### Address Parsing:

- Input: "opposite Java House, Kimathi Street"
- Parsed: `RELATIVE_TO: Java House Kimathi` + `DIRECTION: opposite`
- Output: GPS coordinates with 50m accuracy zone

### Ambiguity Handling:

- **Confidence scoring**: High → auto-resolve, Low → trigger verification call
- **Map confirmation**: Sender adjusts pin before confirming
- **Photo reference**: Senders upload landmark photos for complex locations

---

## 2. M-Pesa Integration

### Escrow-Based Payment Flow:

```
Customer pays → Funds held in escrow → Rider delivers + captures POD →
Customer has 2hr dispute window → Funds auto-release to rider wallet
```

### Features:

| Feature             | Implementation                           |
| ------------------- | ---------------------------------------- |
| Escrow              | Funds held until POD confirmed           |
| Split payments      | 85% rider / 15% platform                 |
| Conditional release | POD (photo + signature) triggers release |
| Dispute handling    | Auto-freeze with resolution process      |

### Rider Payout:

- Earnings accumulate in wallet
- Withdraw to M-Pesa anytime
- No minimum withdrawal amount

---

## 3. Courier Matching Algorithm

### Weighted Matching Criteria:

| Factor                | Weight |
| --------------------- | ------ |
| Proximity to pickup   | 30%    |
| Rider rating          | 20%    |
| Vehicle-package match | 20%    |
| Acceptance rate       | 15%    |
| Current load          | 10%    |
| Traffic patterns      | 5%     |

### Flow:

1. Filter online riders within 5km radius
2. Filter by vehicle type vs package size
3. Score using weighted algorithm
4. Send to top 3 riders simultaneously
5. First to accept wins
6. No acceptance in 60s → expand radius

---

## 4. Unique Kenyan Adaptations

### Matatu Integration (Long-Distance):

- **Sacco partnerships**: 2NK, Super Metro, Mash East
- **Flow**: Local pickup → matatu transit → local delivery
- **Tracking**: Conductor check-ins at stages

### Informal Settlement Deliveries:

- **500+ community agents** in Kibera, Mathare, Mukuru
- Agents = local shops as pickup points
- Recipients collect within 48 hours
- Agent earns KES 30 per package

### Pickup Point Network:

- Petrol stations, M-Pesa agents, supermarkets
- 24/7 availability at select locations

---

## 5. Offline Functionality

### Offline Capabilities:

| Action                   | Works Offline        |
| ------------------------ | -------------------- |
| View assigned deliveries | ✅                   |
| Navigation               | ✅ (downloaded maps) |
| Capture POD              | ✅                   |
| Mark delivered           | ✅ (queued)          |
| Accept new jobs          | ❌                   |

### Sync Mechanism:

- POD data cached locally (SQLite)
- Background sync when connectivity restored
- SMS fallback for critical updates

---

## 6. Multi-modal Delivery

### Transport Modes:

| Mode       | Package Size | Max Distance | Base Price |
| ---------- | ------------ | ------------ | ---------- |
| Walking    | Small        | 2km          | KES 100    |
| Bicycle    | Small-Medium | 5km          | KES 150    |
| Motorcycle | Any          | 20km         | KES 200    |
| Car/SUV    | Large-XL     | 50km         | KES 400    |
| Van        | Bulk/XL      | 100km        | KES 800    |

### Auto-Selection Logic:

- Small + <3km → Bicycle (eco-friendly)
- Large/XL → Car or Van
- Fragile → Car (safer)
- Default → Motorcycle (fastest)

---

## Summary

| Challenge           | SwiftSend Solution                     |
| ------------------- | -------------------------------------- |
| Informal addresses  | AI + landmarks + community data        |
| Payment trust       | Escrow with conditional release        |
| Courier matching    | 6-factor weighted algorithm            |
| Long-distance       | Matatu sacco partnerships              |
| Hard-to-reach areas | 500+ community agents                  |
| Poor connectivity   | Local cache + SMS fallback             |
| Package variety     | 5 transport modes with smart selection |
