# Fleet Market — Detailed Specification

**Version:** 0.2  
**Date:** January 2026  
**Companion to:** Game Design Document v0.7, Economic Parameters v0.1

---

## Overview

This document specifies how players acquire and dispose of aircraft in Airliner — the channels, negotiations, timelines, and economics of building a fleet.

**Design Philosophy:** Aircraft acquisition should feel significant, not transactional. Each plane is a long-term commitment with financial and operational consequences. The market has depth — multiple ways to acquire, each with trade-offs.

**Core Loop:** Identify need → Explore options → Negotiate → Commit → Wait/prepare → Receive

---

## 1. Acquisition Channels

### 1.1 Channel Overview

| Channel | Lead Time | Price | Flexibility | Customization |
|---------|-----------|-------|-------------|---------------|
| **Manufacturer order** | 2-5 years | List price (- discounts) | Low | Full |
| **Slot purchase** | 6-18 months | Premium | Medium | Limited |
| **Operating lease** | 1-6 months | Higher monthly | High | None |
| **Sale-leaseback** | 1-3 months | Cash + lease rate | Medium | Existing config |
| **Used market** | 1-6 months | Discounted | Medium | Existing + refit |
| **Auction** | Immediate | Variable | Low | As-is |

### 1.2 New Aircraft Orders

**Direct from manufacturer:**

| Manufacturer | Current Types | Order Queue | Notes |
|--------------|---------------|-------------|-------|
| Boeing | 737 MAX, 787, 777X | 4-6 years | Seattle/Charleston |
| Airbus | A220, A320neo, A350 | 3-5 years | Toulouse/Hamburg/Mobile |
| Embraer | E2 family | 2-3 years | São José dos Campos |
| ATR | ATR 42/72 | 1-2 years | Toulouse |

**Deposits:**

| Stage | Typical Deposit |
|-------|----------------|
| At signing | 1-3% of list price |
| 24 months before delivery | 5% |
| 12 months before delivery | 10% |
| 6 months before delivery | 15% |
| At delivery | Balance (70-75%) |

### 1.3 Operating Lease

Rent aircraft from lessor:

| Lessor Type | Inventory | Flexibility | Rates |
|-------------|-----------|-------------|-------|
| **Major (AerCap, GECAS, Avolon)** | Large, diverse | Standard terms | Market rate |
| **Regional specialist** | Limited types | Flexible | Premium |
| **Airline sublease** | What they have | Negotiable | Variable |

**Lease terms:**

| Term | Typical Range | Notes |
|------|---------------|-------|
| Duration | 3-12 years | Shorter = higher rate |
| Monthly rate | 0.6-1.0% of value | See economic-parameters.md |
| Maintenance reserves | $150-400/flight hour | Escrowed |
| Security deposit | 2-3 months rent | Returned at end |
| Return conditions | Specified in lease | Half-life, condition |

### 1.4 Used Aircraft Market

Buy pre-owned from other airlines, lessors, or brokers. Prices based on age, condition, configuration, and market conditions.

---

## 2. Manufacturer Relationships

### 2.1 Relationship Levels

| Level | Description | Benefits |
|-------|-------------|----------|
| **New customer** | First order | List pricing, standard terms |
| **Established** | 5-15 aircraft ordered | 5-10% discount, priority support |
| **Preferred** | 15-50 aircraft | 10-20% discount, slot flexibility |
| **Strategic** | 50+ aircraft, flagship | 20-30% discount, launch customer opportunities |
| **Launch customer** | First order of new type | Maximum discount, marketing value, delivery priority |

### 2.2 Relationship Factors

| Factor | Positive Impact | Negative Impact |
|--------|-----------------|-----------------|
| Order volume | Larger orders build relationship | Small orders don't move needle |
| Order consistency | Regular orders valued | Long gaps hurt |
| Fleet loyalty | Single-type fleets appreciated | Mixed fleets neutral |
| Payment history | On-time builds trust | Late payments damage |
| Public praise | Marketing value | Public criticism hurts |
| Competitor flirting | Leverage in negotiations | Can backfire if overused |

### 2.3 Manufacturer Relationship UI

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  MANUFACTURER RELATIONSHIPS                                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  AIRBUS                                                                     │
│  Status: Preferred Customer ████████████░░░░ 72/100                        │
│  Aircraft ordered: 24 (18 delivered, 6 on order)                           │
│  Est. discount: 15-18%                                                     │
│  Your contact: Jean-Pierre Moreau (VP Sales, Europe)                       │
│  Next delivery: A320neo, March 2027                                        │
│  Relationship trend: ▲ Improving (recent 8-aircraft order)                 │
│                                                                             │
│  BOEING                                                                     │
│  Status: New Customer ████░░░░░░░░░░░░ 25/100                              │
│  Aircraft ordered: 0                                                        │
│  Est. discount: 3-5% (first order incentive)                               │
│  Your contact: None assigned                                               │
│  Note: "They've reached out twice about 787 opportunities"                 │
│                                                                             │
│  EMBRAER                                                                    │
│  Status: Established ████████░░░░░░░░ 48/100                               │
│  Aircraft ordered: 8 (8 delivered)                                         │
│  Est. discount: 8-10%                                                      │
│  Your contact: Maria Santos (Regional Sales Director)                      │
│                                                                             │
│  [Contact manufacturer] [View order history] [Request proposal]            │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Order Negotiation

### 3.1 Negotiation Process

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  NEW ORDER NEGOTIATION · Airbus A320neo                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  YOUR REQUEST                                                               │
│  Quantity: 6 aircraft                                                       │
│  Delivery window: 2028-2029                                                │
│  Configuration: 180-seat single class                                      │
│                                                                             │
│  AIRBUS INITIAL OFFER                                                       │
│  List price: $110.6M each ($663.6M total)                                  │
│  Offered discount: 16%                                                     │
│  Net price: $92.9M each ($557.4M total)                                    │
│  Delivery slots: Q2 2028 (2), Q4 2028 (2), Q2 2029 (2)                     │
│  Deposit required: $16.7M (3%) by Feb 15                                   │
│                                                                             │
│  NEGOTIATION LEVERS                                                         │
│                                                                             │
│  [+2 aircraft] Add volume → Est. +2% discount                              │
│  [Extend timeline] Accept 2030 deliveries → +1% discount                   │
│  [Fleet commitment] Commit to Airbus-only fleet → +3% discount             │
│  [Flexible config] Accept standard config → +1% discount                   │
│  [Competitor quote] Mention Boeing interest → Risky, may backfire          │
│                                                                             │
│  COUNTER-OFFER                                                              │
│  Target discount: [    18%    ]                                            │
│  Justification: [Fleet commitment, long relationship...........]           │
│                                                                             │
│  [Submit counter] [Accept offer] [Walk away] [Request time]                │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3.2 Negotiation Outcomes

| Outcome | Probability | Effect |
|---------|-------------|--------|
| **Accepted** | Higher if reasonable | Deal closes at your terms |
| **Counter-counter** | Common | They meet you partway |
| **Rejected** | If too aggressive | Original offer or worse |
| **Walk away** | If insulting | Relationship damage |
| **Sweetener** | Sometimes | Non-price concession (training, support) |

### 3.3 Discount Drivers

| Factor | Discount Range | Notes |
|--------|----------------|-------|
| Base relationship | 0-20% | Based on relationship level |
| Order size | +2-5% | Per 5 aircraft increment |
| Market conditions | -5% to +10% | Boom vs trough |
| Delivery flexibility | +1-3% | Accepting later slots |
| Configuration flexibility | +1-2% | Standard vs custom |
| Fleet commitment | +2-5% | Single-type fleet promise |
| Competitive pressure | +1-5% | Credible alternative |
| Launch customer | +10-15% | First orders of new type |

---

## 4. Delivery Slot Trading

### 4.1 Slot Market

When you can't wait for your own order:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  DELIVERY SLOT MARKETPLACE · A320neo Family                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  AVAILABLE SLOTS                                                            │
│                                                                             │
│  A320neo · Q3 2026 · TransEuro Airways (selling)                           │
│  Reason: "Financial restructuring"                                         │
│  Slot premium: $2.8M above current order price                             │
│  Config: 180Y, CFM LEAP-1A                                                 │
│  [Inquire] [Pass]                                                          │
│                                                                             │
│  A321neo · Q1 2027 · Nordic Air (selling)                                  │
│  Reason: "Fleet plan change"                                               │
│  Slot premium: $1.5M above current order price                             │
│  Config: 220Y, PW1100G                                                     │
│  [Inquire] [Pass]                                                          │
│                                                                             │
│  A320neo · Q4 2026 · Lessor (AerCap)                                       │
│  Type: Speculative order, never assigned                                   │
│  Slot premium: $3.2M                                                       │
│  Config: Flexible (green aircraft)                                         │
│  [Inquire] [Pass]                                                          │
│                                                                             │
│  YOUR SLOTS (available to sell/trade)                                       │
│  A320neo · Q2 2028 · [List for sale] [Trade]                               │
│  A320neo · Q4 2028 · [List for sale] [Trade]                               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.2 Slot Transaction Types

| Type | Description | Cost/Benefit |
|------|-------------|--------------|
| **Purchase** | Buy another airline's slot | Premium over list |
| **Sale** | Sell your slot | Recover deposits + premium |
| **Swap** | Trade delivery dates | May include cash adjustment |
| **Deferral** | Push your slot later | Manufacturer approval, may lose discount |
| **Acceleration** | Pull slot earlier | Rare, premium required |

---

## 5. Used Aircraft Transactions

### 5.1 Market Sources

| Source | Inventory | Pricing | Due Diligence |
|--------|-----------|---------|---------------|
| **Airlines (direct)** | Their surplus | Negotiable | Full access |
| **Lessors** | Off-lease inventory | Market rate | Standard |
| **Brokers** | Aggregated listings | Commission added | Varies |
| **Auctions** | Bankruptcy, repo | Discount, as-is | Limited |

### 5.2 Aircraft Inspection

Before purchasing used aircraft:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  AIRCRAFT INSPECTION REPORT · MSN 7842                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  AIRCRAFT: Boeing 737-800 · Registration: N847SW                           │
│  Previous operator: Southwest Airlines                                     │
│  Age: 12.4 years · Cycles: 28,847 · Hours: 42,156                          │
│                                                                             │
│  RECORDS REVIEW                                                             │
│  Maintenance records: ✓ Complete                                           │
│  AD compliance: ✓ Current                                                  │
│  SB status: ✓ 94% compliant                                                │
│  Engine LLP status: 67% remaining                                          │
│                                                                             │
│  PHYSICAL INSPECTION                                                        │
│  Airframe: Good — minor corrosion treated, standard wear                   │
│  Landing gear: Good — 4,200 cycles since overhaul                          │
│  Engines: Fair — CFM56-7B27, approaching shop visit                        │
│  Interior: Fair — 12-year-old config, will need refurbishment              │
│  Avionics: Good — ADS-B compliant, recent TCAS update                      │
│                                                                             │
│  ESTIMATED VALUES                                                           │
│  Base value (12-year 737-800): $18.2M                                      │
│  Condition adjustment (Fair): -8%                                          │
│  Engine adjustment (shop visit due): -$2.1M                                │
│  Adjusted value: $14.6M                                                    │
│                                                                             │
│  ASKING PRICE: $16.5M                                                      │
│  INSPECTOR RECOMMENDATION: Negotiate to $14-15M or walk                    │
│                                                                             │
│  REFIT COST ESTIMATE                                                        │
│  Engine shop visit: $3.2M (required within 2,000 cycles)                   │
│  Cabin reconfiguration: $1.8M (your layout)                                │
│  Livery: $180K                                                             │
│  Total ready-to-fly: $19.8-20.8M                                           │
│                                                                             │
│  [Make offer] [Request more info] [Pass]                                   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 5.3 Inspection Cost

| Scope | Cost | Duration | When to Use |
|-------|------|----------|-------------|
| **Records only** | $5-15K | 1-2 weeks | Initial screening |
| **Records + visual** | $25-50K | 1 week | Serious interest |
| **Full technical** | $75-150K | 2-3 weeks | Pre-purchase |
| **Borescope** | +$20-40K | +2 days | Engine concerns |

---

## 6. Aircraft Valuation

### 6.1 Depreciation Curves

From economic-parameters.md:

| Age | % of New Value | Notes |
|-----|----------------|-------|
| 0-2 years | 85-95% | Near-new |
| 3-5 years | 70-85% | Early depreciation |
| 6-10 years | 50-70% | Mid-life |
| 11-15 years | 30-50% | Late mid-life |
| 16-20 years | 15-30% | Near retirement |
| 20+ years | 5-15% | Freighter/part-out |

### 6.2 Condition Adjustments

| Condition | Multiplier | Characteristics |
|-----------|------------|-----------------|
| **Excellent** | 1.05x | Fresh from heavy check, full records |
| **Good** | 1.00x | Well-maintained, typical wear |
| **Fair** | 0.90x | Deferred maintenance, some issues |
| **Poor** | 0.75x | Significant work needed |

### 6.3 Value Adjustments

| Factor | Adjustment | Notes |
|--------|------------|-------|
| Popular configuration | +3-5% | Standard layouts sell easier |
| Unpopular configuration | -5-10% | Non-standard hard to place |
| Engine type (preferred) | +2-3% | CFM vs IAE preference |
| Full records | +3-5% | Complete history |
| Gaps in records | -10-20% | Missing maintenance history |
| Approaching check | -Check cost | C-check, D-check, shop visit |
| Fresh from check | +2-3% | Just completed heavy mx |
| ETOPS certified | +2-3% | For overwater capable |
| Freighter convertible | +5-10% | P2F potential |

---

## 7. Market Dynamics

### 7.1 Supply Cycles

| Phase | New Prices | Used Prices | Lease Rates | Availability |
|-------|------------|-------------|-------------|--------------|
| **Boom** | Firm (backlog full) | Rising | Rising | Scarce |
| **Peak** | List price enforced | Maximum | Maximum | Very scarce |
| **Downturn** | Discounts available | Falling | Falling | Improving |
| **Trough** | Deep discounts | Minimum | Minimum | Abundant |
| **Recovery** | Discounts shrinking | Rising | Rising | Tightening |

### 7.2 Market Intelligence

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  MARKET INTELLIGENCE · Narrowbody                                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  MARKET PHASE: Late Recovery ████████████░░░░                              │
│  Trend: Tightening                                                         │
│                                                                             │
│  NEW AIRCRAFT                                                               │
│  A320neo backlog: 5,847 aircraft (6.2 years production)                    │
│  737 MAX backlog: 4,123 aircraft (5.1 years production)                    │
│  Discount environment: Shrinking (was 18-22%, now 12-16%)                  │
│  Recommendation: Order soon if planning fleet growth                       │
│                                                                             │
│  USED AIRCRAFT                                                              │
│  737-800 (10-15yr): $14-22M — prices up 12% YoY                            │
│  A320ceo (10-15yr): $12-18M — prices up 8% YoY                             │
│  Inventory: Tightening, fewer distressed sales                             │
│  Recommendation: Good aircraft going fast, act on finds                    │
│                                                                             │
│  LEASE RATES                                                                │
│  A320neo: $340-380K/month — up from $310K last year                        │
│  737 MAX 8: $320-360K/month — up from $290K last year                      │
│  Availability: 3-6 month wait for preferred configs                        │
│                                                                             │
│  FORECAST (next 12 months)                                                  │
│  New prices: ▲ Expect 3-5% increase                                        │
│  Used prices: ▲ Expect 5-10% increase                                      │
│  Lease rates: ▲ Expect 8-12% increase                                      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 8. Aircraft Disposal

### 8.1 Exit Strategies

| Strategy | Timeline | Recovery | Best When |
|----------|----------|----------|-----------|
| **Trade-in** | With new order | 85-95% of value | Manufacturer relationship strong |
| **Direct sale** | 3-6 months | Market value | Good aircraft, good market |
| **Broker sale** | 2-4 months | Market - 5% commission | Need speed |
| **Lease return** | Per contract | Deposit return | End of lease |
| **Part-out** | 6-12 months | 90-120% of hull | Old/damaged aircraft |
| **Donate** | 1-3 months | Tax benefit | Museums, training |

### 8.2 Sale Process

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  AIRCRAFT FOR SALE · F-GKXA                                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  AIRCRAFT: Airbus A320-214 · MSN 2847                                      │
│  Age: 14.2 years · Cycles: 22,156 · Hours: 38,421                          │
│  Configuration: 180Y · Engine: CFM56-5B4/3                                 │
│  Condition: Good · Next C-check: 18 months                                 │
│                                                                             │
│  VALUATION                                                                  │
│  Base value: $14.8M                                                        │
│  Your book value: $11.2M                                                   │
│  Asking price: $15.5M (includes premium for condition)                     │
│                                                                             │
│  LISTING STATUS: Active · Listed 6 weeks ago                               │
│                                                                             │
│  INQUIRIES                                                                  │
│  Aegean Airlines — Serious, inspection scheduled                           │
│  Nordic Aviation Capital — Offer pending                                   │
│  AviaAM Leasing — Initial interest                                         │
│                                                                             │
│  OFFER RECEIVED                                                             │
│  From: Nordic Aviation Capital                                             │
│  Amount: $14.1M (cash, 60-day close)                                       │
│  Conditions: Records satisfactory, return condition met                    │
│                                                                             │
│  [Accept offer] [Counter at $14.8M] [Wait for Aegean] [Delist]             │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 9. Data Model Integration

### 9.1 Entities

**Order** — Manufacturer orders (aligns with data-model.md)

| Field | Type | Purpose |
|-------|------|---------|
| `id` | UUID | Primary key |
| `airline_id` | FK | Buyer |
| `manufacturer` | string | Boeing, Airbus, etc. |
| `type_id` | FK | Aircraft type |
| `quantity` | int | Aircraft count |
| `order_date` | date | Contract signed |
| `delivery_start` | date | First expected delivery |
| `delivery_end` | date | Last expected delivery |
| `list_price_each` | decimal | Catalog price |
| `negotiated_discount` | float | Achieved discount % |
| `deposits_paid` | decimal | Cumulative deposits |
| `status` | enum | See OrderStatus |

**Lease** — Lease agreements

| Field | Type | Purpose |
|-------|------|---------|
| `id` | UUID | Primary key |
| `aircraft_id` | FK | Leased aircraft |
| `lessor_id` | FK | Lessor entity |
| `lessee_id` | FK | Lessee airline |
| `lease_type` | enum | OPERATING / FINANCE |
| `start_date` | date | Lease commencement |
| `end_date` | date | Lease end |
| `monthly_rate` | decimal | Base rent |
| `maintenance_reserve` | decimal | Per flight hour |
| `security_deposit` | decimal | Held by lessor |
| `return_conditions` | json | Half-life requirements |
| `status` | enum | ACTIVE / RETURNED / EXTENDED |

**AircraftListing** — Market listings

| Field | Type | Purpose |
|-------|------|---------|
| `id` | UUID | Primary key |
| `aircraft_id` | FK | Aircraft for sale |
| `seller_id` | FK | Selling entity |
| `listing_type` | enum | SALE / LEASE / SLOT |
| `asking_price` | decimal | Listed price |
| `listing_date` | date | When listed |
| `status` | enum | ACTIVE / UNDER_OFFER / SOLD / WITHDRAWN |
| `inquiries` | json | Interested parties |

**ManufacturerRelationship** — Relationship tracking

| Field | Type | Purpose |
|-------|------|---------|
| `id` | UUID | Primary key |
| `airline_id` | FK | Your airline |
| `manufacturer` | string | Boeing, Airbus, etc. |
| `relationship_score` | int | 0-100 |
| `level` | enum | NEW / ESTABLISHED / PREFERRED / STRATEGIC |
| `aircraft_ordered` | int | Lifetime orders |
| `aircraft_delivered` | int | Delivered count |
| `contact_name` | string | Sales representative |
| `last_order_date` | date | Most recent order |

### 9.2 Enumerations

```yaml
OrderStatus:
  LETTER_OF_INTENT       # Non-binding interest
  MEMORANDUM_OF_UNDERSTANDING  # Agreed terms, not final
  FIRM_ORDER             # Binding contract
  IN_PRODUCTION          # Being built
  DELIVERED              # Handed over
  CANCELLED              # Terminated
  DEFERRED               # Pushed back

LeaseType:
  OPERATING              # Off-balance sheet
  FINANCE                # On-balance sheet
  WET                    # With crew and maintenance

ListingStatus:
  ACTIVE                 # On market
  UNDER_OFFER            # Offer being considered
  SOLD                   # Transaction complete
  LEASED                 # Lease signed
  WITHDRAWN              # Removed from market

ManufacturerLevel:
  NEW_CUSTOMER           # First order
  ESTABLISHED            # 5-15 aircraft
  PREFERRED              # 15-50 aircraft
  STRATEGIC              # 50+ aircraft
  LAUNCH_CUSTOMER        # First of type

InspectionScope:
  RECORDS_ONLY           # Document review
  RECORDS_AND_VISUAL     # Plus walkthrough
  FULL_TECHNICAL         # Complete inspection
  BORESCOPE              # Engine internal
```

---

## Document History

| Version | Date | Changes |
|---------|------|---------|
| 0.1 | January 2026 | Initial specification |
| 0.2 | January 2026 | Major expansion: manufacturer relationships, negotiation mechanics, slot trading, used aircraft inspection, disposal strategies |
