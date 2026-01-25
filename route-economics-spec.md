# Route Economics — Detailed Specification

**Version:** 0.1  
**Date:** January 2026  
**Companion to:** Game Design Document v0.7, Economic Parameters v0.1

---

## Overview

This document specifies how route demand, pricing, and competition work in Airliner. It defines the core revenue-generating loop that determines whether your airline makes money or bleeds cash.

**Design Philosophy:** Routes are the fundamental unit of airline business. Every route has demand that responds to price, competition that responds to you, and economics that reward understanding over luck.

**Core Loop:** Analyze demand → Set capacity → Price tickets → Compete → Observe results → Adjust

---

## 1. Demand Model

### 1.1 Demand Components

Total demand on a route = Base Demand × Modifiers

| Component | Description | Volatility |
|-----------|-------------|------------|
| **Base Demand** | Structural market size | Low (changes yearly) |
| **Seasonal Modifier** | Monthly fluctuations | Medium (predictable) |
| **Day-of-Week Modifier** | Business vs leisure patterns | Low (predictable) |
| **Economic Modifier** | GDP, recession effects | Medium (event-driven) |
| **Event Modifier** | Conferences, holidays, disasters | High (spiky) |
| **Competition Modifier** | Response to market capacity | Medium |

### 1.2 Base Demand Calculation

Base demand is generated per route based on:

```
Base_Demand = f(Origin_Pop, Dest_Pop, Distance, Connection_Type)
```

| Factor | Impact | Notes |
|--------|--------|-------|
| Origin population | +++ | Larger cities = more travelers |
| Destination population | ++ | Affects both ends |
| Distance | Mixed | Short-haul = frequent; Long-haul = less frequent but higher yield |
| Connection type | +++ | Business hub = high; Resort = seasonal |
| Historical traffic | Calibration | Based on real OAG data where available |

### 1.3 Demand Categories

Demand splits into passenger segments:

| Segment | Characteristics | Price Sensitivity | Booking Window |
|---------|-----------------|-------------------|----------------|
| **Business** | Time-sensitive, flexible | Low | 0-14 days |
| **Premium Leisure** | Quality-focused, planned | Medium | 14-60 days |
| **Leisure** | Price-sensitive, flexible dates | High | 30-180 days |
| **VFR** | Visiting friends/relatives | Medium | 14-90 days |
| **Budget** | Lowest price wins | Very high | 0-365 days |

### 1.4 Segment Distribution by Route Type

| Route Type | Business | Prem Leisure | Leisure | VFR | Budget |
|------------|----------|--------------|---------|-----|--------|
| Business hub-hub | 55% | 15% | 15% | 10% | 5% |
| Capital-capital | 45% | 20% | 20% | 10% | 5% |
| Hub-secondary | 35% | 15% | 25% | 15% | 10% |
| Hub-resort | 10% | 30% | 40% | 5% | 15% |
| Regional | 25% | 10% | 20% | 35% | 10% |
| LCC route | 5% | 10% | 30% | 15% | 40% |

---

## 2. Seasonal Patterns

### 2.1 Seasonal Indices

Monthly demand multipliers (1.0 = average):

| Month | Business | Leisure | Resort | Notes |
|-------|----------|---------|--------|-------|
| January | 0.95 | 0.70 | 0.80 | Post-holiday lull |
| February | 1.00 | 0.75 | 0.85 | Ski season |
| March | 1.05 | 0.90 | 1.00 | Spring break |
| April | 1.05 | 1.10 | 1.10 | Easter |
| May | 1.00 | 1.15 | 1.20 | Early summer |
| June | 0.90 | 1.35 | 1.40 | Summer begins |
| July | 0.70 | 1.50 | 1.60 | Peak summer |
| August | 0.65 | 1.45 | 1.55 | Peak summer |
| September | 1.05 | 1.00 | 1.10 | Back to business |
| October | 1.10 | 0.95 | 0.90 | Conference season |
| November | 1.05 | 0.85 | 0.75 | Pre-holiday |
| December | 0.85 | 1.20 | 1.30 | Holiday travel |

### 2.2 Day-of-Week Patterns

| Day | Business | Leisure |
|-----|----------|---------|
| Monday | 1.30 | 0.70 |
| Tuesday | 1.20 | 0.75 |
| Wednesday | 1.15 | 0.80 |
| Thursday | 1.25 | 0.85 |
| Friday | 1.10 | 1.20 |
| Saturday | 0.50 | 1.40 |
| Sunday | 0.70 | 1.30 |

---

## 3. Price Elasticity

### 3.1 Elasticity by Segment

Price elasticity = % change in demand / % change in price

| Segment | Elasticity | Interpretation |
|---------|------------|----------------|
| Business | -0.3 to -0.6 | Inelastic — will pay for convenience |
| Premium Leisure | -0.8 to -1.2 | Moderate — balance of price/quality |
| Leisure | -1.5 to -2.5 | Elastic — shops for deals |
| VFR | -1.0 to -1.5 | Moderate — must travel but budget-conscious |
| Budget | -2.5 to -4.0 | Highly elastic — lowest price wins |

### 3.2 Demand Curve

For each segment:

```
Demand(Price) = Base_Demand × (Reference_Price / Price)^Elasticity
```

**Example:** Leisure segment with elasticity -2.0, base demand 1000 at $200:
- At $200: 1000 passengers
- At $180 (-10%): 1000 × (200/180)^2 = 1235 passengers (+23.5%)
- At $220 (+10%): 1000 × (200/220)^2 = 826 passengers (-17.4%)

### 3.3 Price Floors and Ceilings

| Constraint | Effect |
|------------|--------|
| **Price floor** | Below variable cost = losing money per passenger |
| **Price ceiling** | Above willingness-to-pay = zero demand |
| **Reference price** | Market expectation based on route/competition |

---

## 4. Capacity and Load Factor

### 4.1 Load Factor Calculation

```
Load_Factor = Passengers_Carried / Seats_Available
```

### 4.2 Load Factor Targets

| Airline Type | Target Load Factor | Break-even (typical) |
|--------------|-------------------|----------------------|
| Legacy carrier | 80-85% | 72-78% |
| LCC | 85-92% | 78-84% |
| Regional | 70-80% | 65-72% |
| Premium/boutique | 65-75% | 60-68% |

### 4.3 Spill and Spoilage

| Phenomenon | Description | Cost |
|------------|-------------|------|
| **Spill** | Demand exceeds capacity; passengers lost | Lost revenue opportunity |
| **Spoilage** | Capacity exceeds demand; empty seats | Fixed costs unrecovered |

**Optimal strategy:** Balance spill and spoilage through frequency and pricing.

---

## 5. Competition Model

### 5.1 Market Share Calculation

Market share is calculated using a logit choice model:

```
Utility(Airline_i) = β₁×Price_i + β₂×Frequency_i + β₃×Quality_i + β₄×Connection_i + ε
Market_Share_i = exp(Utility_i) / Σexp(Utility_j)
```

### 5.2 Utility Factors

| Factor | Weight (β) | Description |
|--------|------------|-------------|
| **Price** | -0.015 | Lower price = higher utility |
| **Frequency** | +0.10 | More flights = higher utility |
| **Quality score** | +0.05 | Brand, service, comfort |
| **Connection time** | -0.02 | Shorter connections preferred |
| **Departure time** | +0.03 | Preferred times (7-9am, 5-7pm) |
| **Loyalty** | +0.20 | FFP membership bonus |

### 5.3 Competition Response

AI competitors respond to your actions:

| Your Action | Competitor Response | Delay |
|-------------|---------------------|-------|
| Enter route | Monitor (1-3 months), then match or ignore | 1-6 months |
| Price cut | Match if >15% below, ignore if <10% | 1-4 weeks |
| Frequency increase | Match if threatens share >5% | 1-3 months |
| Exit route | May increase prices, add capacity | Immediate |
| Quality improvement | Slow response (harder to copy) | 6-18 months |

### 5.4 Price War Dynamics

Price wars trigger when:
- Multiple carriers are unprofitable on route
- One carrier cuts >20% below market
- New entrant with aggressive pricing

Price war effects:
- Yields collapse 30-50%
- Load factors increase but revenue decreases
- Duration: 3-18 months typically
- Resolution: Competitor exit or pricing discipline

---

## 6. Route Economics

### 6.1 Revenue Calculation

```
Route_Revenue = Passengers × Average_Fare + Cargo_Revenue + Ancillary_Revenue
```

| Component | Typical % of Total |
|-----------|-------------------|
| Passenger revenue | 75-90% |
| Cargo/mail | 5-15% |
| Ancillary (bags, etc.) | 5-20% |

### 6.2 Cost Allocation

Costs attributed to routes:

| Cost Category | Allocation Method |
|---------------|-------------------|
| **Fuel** | Direct — based on distance and aircraft |
| **Crew** | Direct — block hours × crew rate |
| **Landing fees** | Direct — per departure |
| **Navigation fees** | Direct — distance-based |
| **Ground handling** | Direct — per turnaround |
| **Aircraft ownership** | Allocated — block hours share |
| **Maintenance** | Allocated — cycles and hours |
| **Sales & distribution** | Allocated — revenue share |
| **Overhead** | Allocated — ASK share |

### 6.3 Route Profitability Metrics

| Metric | Formula | Target |
|--------|---------|--------|
| **RASK** | Revenue / ASK | $0.08-0.15 |
| **CASK** | Cost / ASK | $0.06-0.12 |
| **Yield** | Passenger Revenue / RPK | $0.10-0.20 |
| **Contribution margin** | (Revenue - Variable Cost) / Revenue | 25-40% |
| **Route profit** | Revenue - Total Allocated Cost | >0 |

### 6.4 Route Profitability Display

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  ROUTE ECONOMICS · LYS → CDG                                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  MARKET                          YOUR PERFORMANCE                           │
│  Total demand: 2,400/week        Passengers: 840/week                      │
│  Competitors: 3                  Market share: 35%                         │
│  Avg market fare: $142           Your avg fare: $138                       │
│                                                                             │
│  WEEKLY FINANCIALS                                                          │
│  Revenue                                                                    │
│    Passenger         $115,920                                              │
│    Cargo               $4,200                                              │
│    Ancillary           $8,400                                              │
│    Total             $128,520                                              │
│                                                                             │
│  Costs                                                                      │
│    Fuel               $32,400    ████████░░░░░░░░ 28%                      │
│    Crew               $18,200    █████░░░░░░░░░░░ 16%                      │
│    Landing/handling   $12,800    ████░░░░░░░░░░░░ 11%                      │
│    Aircraft           $24,500    ██████░░░░░░░░░░ 21%                      │
│    Other allocated    $28,100    ███████░░░░░░░░░ 24%                      │
│    Total             $116,000                                              │
│                                                                             │
│  ROUTE PROFIT         $12,520    Margin: 9.7%    ● Profitable             │
│                                                                             │
│  TRENDS                                                                     │
│  Load factor: 78% (▲ +3%)        Yield: $0.138 (▼ -2%)                     │
│  Recommendation: Consider frequency increase to capture spill              │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 7. Yield Management

### 7.1 Fare Classes

Typical fare class structure:

| Class | Code | Restrictions | Price vs Full Y |
|-------|------|--------------|-----------------|
| First | F, A | Full flex, premium | 400-800% |
| Business | J, C, D | Full flex | 300-600% |
| Premium Economy | W, P | Moderate flex | 150-250% |
| Full Economy | Y, B | Full flex | 100% (reference) |
| Discount Economy | M, H, K | Some restrictions | 70-90% |
| Deep Discount | L, Q, V | Non-refundable | 40-70% |
| Promo | T, X | Heavy restrictions | 20-50% |

### 7.2 Booking Curve

Demand arrives over time:

| Days Before Departure | % of Demand | Typical Segment |
|-----------------------|-------------|-----------------|
| 180-90 | 5% | Early leisure |
| 90-60 | 10% | Planned leisure |
| 60-30 | 25% | Mixed |
| 30-14 | 25% | Business + leisure |
| 14-7 | 20% | Business heavy |
| 7-0 | 15% | Last-minute business |

### 7.3 Pricing Strategies

| Strategy | Description | Best For |
|----------|-------------|----------|
| **Skim** | Start high, lower as departure approaches | Low competition |
| **Penetrate** | Start low, raise as seats fill | New routes, market entry |
| **Dynamic** | Adjust continuously based on demand | Sophisticated revenue management |
| **Match** | Follow competitor pricing | Mature, stable markets |

### 7.4 Simplified Yield Management

For player usability, yield management is abstracted to:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  PRICING STRATEGY · LYS → CDG                                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  STRATEGY                                                                   │
│  ○ Aggressive    Lower prices, maximize load factor                        │
│  ● Balanced      Market-rate pricing, optimize revenue                     │
│  ○ Premium       Higher prices, accept lower loads                         │
│  ○ Custom        Set manual price targets                                  │
│                                                                             │
│  PRICE TARGETS (vs market average)                                         │
│  Economy:        [====●====] 100%  ($142)                                  │
│  Business:       [====●====] 100%  ($485)                                  │
│                                                                             │
│  PROJECTED IMPACT                                                           │
│  Load factor: 78% → 78%    Revenue: $128K → $128K                          │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 8. Network Effects

### 8.1 Hub Premium

Hub airports generate additional value:

| Effect | Magnitude | Mechanism |
|--------|-----------|-----------|
| **Frequency premium** | +5-15% yield | Passengers pay for convenience |
| **Connection value** | +20-40% demand | Feed from spoke routes |
| **Loyalty capture** | +10-20% share | FFP benefits |
| **Schedule dominance** | +5-10% share | Best departure times |

### 8.2 Network Connectivity

Routes feed each other:

```
Connecting_Demand(A→C) = f(Demand(A→B), Demand(B→C), Connection_Quality)
```

| Connection Quality Factor | Impact |
|--------------------------|--------|
| Connection time <60 min | +++ |
| Connection time 60-120 min | ++ |
| Connection time >120 min | — |
| Terminal change required | – |
| Same airline | +++ |
| Alliance partner | ++ |
| Interline only | + |

### 8.3 Route Interdependence

When evaluating a route, consider:

| Factor | Consideration |
|--------|---------------|
| **Feeder value** | Does this route bring passengers to hub connections? |
| **Beyond value** | Does this route carry connecting passengers? |
| **Strategic value** | Does presence on this route protect other routes? |
| **Brand value** | Does this route matter for prestige/visibility? |

---

## 9. Cargo Revenue

### 9.1 Overview

Belly cargo = freight carried in the lower hold of passenger aircraft. Typically 5-15% of revenue for legacy carriers, higher on long-haul international routes. Freighter operations (cargo-only aircraft) not covered in v1.0.

### 9.2 Cargo Demand Model

| Route Type | Typical Cargo Demand | Key Drivers |
|------------|---------------------|-------------|
| **Domestic short-haul** | Low (5-15% capacity) | Express parcels, mail |
| **Domestic long-haul** | Medium (20-40%) | E-commerce, perishables |
| **International short** | Medium (25-45%) | Cross-border e-commerce |
| **International long** | High (50-80%) | High-value goods, manufacturing |
| **Transpacific** | Very high (70-100%) | Electronics, fashion, perishables |
| **To/from hubs** | High | Consolidated freight |

### 9.3 Cargo Capacity

| Aircraft Category | Typical Belly Capacity | Revenue Potential |
|-------------------|----------------------|-------------------|
| **Regional** (ATR, CRJ) | 500-1,500 kg | Minimal |
| **Narrowbody** (A320, 737) | 2,000-4,000 kg | $500-2,000/flight |
| **Widebody** (787, A350) | 15,000-25,000 kg | $5,000-25,000/flight |
| **Large widebody** (777, A380) | 25,000-40,000 kg | $10,000-50,000/flight |

### 9.4 Cargo Economics

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  CARGO ECONOMICS · LYS-JFK                                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  AIRCRAFT: A350-900 · Belly capacity: 18,000 kg                            │
│                                                                             │
│  ROUTE CARGO DEMAND                                                         │
│  Westbound (LYS→JFK): High — wine, cheese, luxury goods                    │
│  Eastbound (JFK→LYS): Medium — electronics, pharmaceuticals                │
│                                                                             │
│  CURRENT PERFORMANCE                                                        │
│  Avg load: 14,200 kg (79% utilization)                                     │
│  Revenue per flight: $18,400                                               │
│  Revenue per kg: $1.30                                                     │
│  Weekly cargo revenue: $128,800                                            │
│                                                                             │
│  CARGO CONTRACTS                                                            │
│  FedEx block space: 3,000 kg/flight @ $1.45/kg = $4,350/flight            │
│  DHL express: 500 kg/flight @ $2.80/kg = $1,400/flight                     │
│  Spot market: ~10,700 kg @ $1.18/kg = $12,650/flight                       │
│                                                                             │
│  [View contracts] [Adjust allocation] [Market rates]                       │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 9.5 Cargo Contracts

| Contract Type | Commitment | Rate | Flexibility |
|---------------|------------|------|-------------|
| **Block space** | Guaranteed capacity | Fixed rate | Low — must honor |
| **ACMI** | Aircraft + crew | Per block hour | None — full aircraft |
| **Spot** | Per-shipment | Market rate | High — no commitment |
| **Interline** | Partner network | Revenue share | Medium |

**Contract terms:**

| Term | Typical Range |
|------|---------------|
| Duration | 6 months - 3 years |
| Volume commitment | 500-5,000 kg/week |
| Penalty for shortfall | 30-50% of committed revenue |
| Rate escalation | CPI-linked or fixed |

### 9.6 Cargo Pricing

| Product | Rate Range | Transit Time |
|---------|------------|--------------|
| **General cargo** | $0.80-1.50/kg | 3-7 days |
| **Express** | $2.00-4.00/kg | 1-2 days |
| **Perishables** | $1.50-3.00/kg | Priority handling |
| **Dangerous goods** | $2.50-5.00/kg | Special handling |
| **Live animals** | $3.00-8.00/kg | Premium care |
| **Valuables** | $4.00-10.00/kg | Security escort |

### 9.7 Cargo Strategy Settings

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  CARGO STRATEGY                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  PRIORITY                                                                   │
│  [●] Passenger baggage first (default)                                     │
│  [ ] Cargo revenue optimization                                            │
│  [ ] Contract obligations first                                            │
│                                                                             │
│  CAPACITY ALLOCATION                                                        │
│  Block space contracts: max [40%   ] of capacity                           │
│  Express premium:       reserve [10%  ] for high-yield                     │
│  Spot market:           fill remaining                                     │
│                                                                             │
│  ROUTE OVERRIDES                                                            │
│  LYS-JFK: High-value cargo focus (+15% rate target)                        │
│  LYS-CDG: Passenger priority (minimal cargo)                               │
│                                                                             │
│  DELEGATION                                                                 │
│  [ ] Delegate cargo decisions to CCO                                       │
│  [●] Alert me for contracts >$50K annually                                 │
│                                                                             │
│  [Apply] [Reset to defaults]                                               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 9.8 Cargo Data Model

**CargoContract entity:**

| Field | Type | Purpose |
|-------|------|---------|
| `id` | UUID | Primary key |
| `airline_id` | FK | Your airline |
| `customer_name` | string | FedEx, DHL, etc. |
| `contract_type` | enum | BLOCK_SPACE / ACMI / INTERLINE |
| `routes` | FK[] | Applicable routes |
| `volume_kg_weekly` | int | Committed volume |
| `rate_per_kg` | decimal | Contracted rate |
| `start_date` | date | Contract start |
| `end_date` | date | Contract end |
| `penalty_rate` | decimal | For under-delivery |
| `status` | enum | ACTIVE / EXPIRED / TERMINATED |

**Route cargo fields** (extend Route entity):

| Field | Type | Purpose |
|-------|------|---------|
| `cargo_demand_kg` | int | Weekly cargo demand |
| `cargo_rate_avg` | decimal | Average yield per kg |
| `cargo_seasonality` | json | Monthly multipliers |
| `cargo_competition` | json | Competitor capacity |

---

## 10. Ancillary Revenue

### 9.1 Overview

Ancillary revenue = non-ticket revenue from passengers. Critical for LCCs (15-40% of revenue), increasingly important for legacy carriers (5-15%).

### 9.2 Ancillary Products

| Product | Typical Price | Attach Rate | Margin |
|---------|--------------|-------------|--------|
| **Checked baggage** | $25-50/bag | 30-60% | 90%+ |
| **Seat selection** | $5-50 | 20-40% | 95%+ |
| **Extra legroom** | $30-100 | 5-15% | 95%+ |
| **Priority boarding** | $10-25 | 10-20% | 95%+ |
| **Onboard WiFi** | $10-30 | 15-30% | 70% |
| **Buy-on-board meals** | $8-20 | 20-40% | 60% |
| **Travel insurance** | $15-40 | 5-15% | 40% (commission) |
| **Lounge access** | $40-75 | 2-5% | 50% |
| **Fast track security** | $10-20 | 5-10% | 30% (fee share) |

### 9.3 Ancillary Strategy

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  ANCILLARY REVENUE SETTINGS                                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  BAGGAGE POLICY                                                             │
│  Included bags:  [0 ▼] (Economy)  [1 ▼] (Business)                         │
│  First bag fee:  [$35        ]                                             │
│  Second bag fee: [$50        ]                                             │
│  Overweight fee: [$75        ]                                             │
│                                                                             │
│  SEAT SELECTION                                                             │
│  Standard seats:     [Free    ▼]                                           │
│  Preferred seats:    [$25     ▼]                                           │
│  Extra legroom:      [$65     ▼]                                           │
│  Exit row:           [$45     ▼]                                           │
│                                                                             │
│  ONBOARD SERVICES                                                           │
│  WiFi pricing:       [$12/flight ▼]                                        │
│  Meal service:       [Buy-on-board ▼]                                      │
│  Beverage service:   [Complimentary ▼]                                     │
│                                                                             │
│  PROJECTED IMPACT                                                           │
│  Est. ancillary per pax: $28.40                                            │
│  As % of total revenue: 12.4%                                              │
│  Industry benchmark: 15-20% (LCC), 8-12% (Legacy)                          │
│                                                                             │
│  ⚠ Warning: High baggage fees may reduce demand from VFR segment           │
│                                                                             │
│  [Apply changes] [Reset to defaults] [View by route]                       │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 9.4 Segment Sensitivity to Ancillary

| Segment | Baggage Sensitivity | Seat Sensitivity | Willing to Pay More |
|---------|---------------------|------------------|---------------------|
| Business | Low | Medium | Premium for convenience |
| Premium Leisure | Low | High | Comfort upgrades |
| Leisure | Medium | Medium | Discretionary |
| VFR | High (heavy bags) | Low | Baggage only |
| Budget | Very high | Low | Almost nothing |

### 9.5 Ancillary Data Model

**AncillaryProduct entity:**

| Field | Type | Purpose |
|-------|------|---------|
| `id` | UUID | Primary key |
| `airline_id` | FK | Which airline |
| `type` | enum | BAGGAGE / SEAT / WIFI / MEAL / LOUNGE / etc. |
| `name` | string | Display name |
| `price` | decimal | Customer price |
| `cost` | decimal | Delivery cost |
| `active` | bool | Currently offered |
| `cabin_restriction` | enum? | If cabin-specific |
| `route_type_restriction` | enum? | If route-specific |

**AncillaryPolicy entity:**

| Field | Type | Purpose |
|-------|------|---------|
| `id` | UUID | Primary key |
| `airline_id` | FK | Which airline |
| `product_type` | enum | Which product category |
| `included_in_fare` | bool | Free with ticket |
| `base_price` | decimal | Standard price |
| `business_price` | decimal? | Override for business |
| `effective_date` | date | When policy starts |

---

## 11. Events and Disruptions

### 9.1 Demand Events

| Event Type | Duration | Impact | Predictability |
|------------|----------|--------|----------------|
| Conference | 3-7 days | +30-100% business | High (known in advance) |
| Sports event | 1-14 days | +50-200% leisure | High |
| Holiday | 1-4 weeks | +20-50% VFR/leisure | High |
| Natural disaster | Days-months | -50-100% | Low |
| Political crisis | Weeks-months | -20-80% | Low |
| Pandemic | Months-years | -30-95% | Low |

### 9.2 Supply Events

| Event Type | Effect | Response Time |
|------------|--------|---------------|
| Competitor entry | -10-30% share | 1-6 months |
| Competitor exit | +20-50% share | Immediate |
| Airport capacity increase | +10-30% market | 1-2 years |
| Airport disruption | -100% (duration) | N/A |
| Fuel price spike | Higher costs | Immediate |

---

## 10. Data Model Integration

### 12.1 Route Entity Extensions

```yaml
Route:
  # Existing fields...
  
  # New demand fields
  base_demand_weekly: int           # Structural demand
  segment_mix: json                  # {business: 0.35, leisure: 0.40, ...}
  seasonality_pattern: enum          # BUSINESS / LEISURE / RESORT / FLAT
  price_elasticity_avg: float        # Weighted average elasticity
  
  # Competition fields
  total_market_capacity: int         # All carriers combined weekly seats
  competitor_count: int              # Number of competitors
  herfindahl_index: float            # Market concentration (0-1)
  
  # Performance fields
  your_market_share: float           # 0-1
  your_avg_yield: decimal            # Revenue per RPK
  route_profitability: decimal       # Weekly profit/loss
```

### 12.2 New Entities

**DemandSnapshot** — Point-in-time demand record

| Field | Type | Purpose |
|-------|------|---------|
| `route_id` | FK | Route reference |
| `date` | date | Snapshot date |
| `segment` | enum | BUSINESS / LEISURE / etc. |
| `base_demand` | int | Unadjusted demand |
| `adjusted_demand` | int | After all modifiers |
| `modifiers_applied` | json | {seasonal: 1.2, event: 1.5, ...} |

**CompetitorRoute** — Competitor presence on route

| Field | Type | Purpose |
|-------|------|---------|
| `route_id` | FK | Route reference |
| `airline_id` | FK | Competitor reference |
| `weekly_frequency` | int | Departures per week |
| `weekly_seats` | int | Total seats offered |
| `avg_fare` | decimal | Estimated pricing |
| `service_quality` | int | 1-100 score |

### 12.3 New Enumerations

```yaml
DemandSegment:
  BUSINESS
  PREMIUM_LEISURE
  LEISURE
  VFR
  BUDGET

SeasonalityPattern:
  BUSINESS_HEAVY      # Peaks in spring/fall
  LEISURE_HEAVY       # Peaks in summer
  RESORT              # Extreme summer peak
  SKI_RESORT          # Winter peak
  FLAT                # No strong pattern
  HOLIDAY_DRIVEN      # Peaks around holidays

PricingStrategy:
  AGGRESSIVE          # Below market, maximize load
  BALANCED            # Market rate, optimize revenue
  PREMIUM             # Above market, accept lower loads
  PENETRATION         # New route entry pricing
  CUSTOM              # Manual control
```

---

## 11. Formulas Reference

### 13.1 Core Calculations

**Demand with price:**
```
D(p) = D₀ × (p₀/p)^ε
where:
  D₀ = base demand
  p₀ = reference price
  p = actual price
  ε = elasticity (negative)
```

**Market share (logit):**
```
S_i = exp(V_i) / Σexp(V_j)
where:
  V_i = β₁×Price + β₂×Freq + β₃×Quality + ...
```

**Break-even load factor:**
```
BLF = Fixed_Cost / (Yield × Seats - Variable_Cost_per_Pax)
```

**RASK/CASK:**
```
RASK = Total_Revenue / (Seats × Distance)
CASK = Total_Cost / (Seats × Distance)
Profit per ASK = RASK - CASK
```

---

## 12. Gameplay Implications

### 12.1 Strategic Decisions

| Decision | Factors to Consider |
|----------|---------------------|
| Enter new route | Demand, competition, fit with network |
| Exit route | Ongoing losses, strategic value, alternatives |
| Change frequency | Demand vs. cost, competitive response |
| Adjust pricing | Elasticity, competition, brand positioning |
| Aircraft assignment | Range, capacity, costs vs. demand |

### 12.2 Feedback Loops

| Loop | Type | Description |
|------|------|-------------|
| Price → Demand | Negative | Lower prices increase demand |
| Market share → Loyalty | Positive | Higher share builds loyalty, which increases share |
| Frequency → Share | Positive | More flights capture more passengers |
| Quality → Yield | Positive | Better service allows higher prices |
| Competition → Price | Negative | More competitors pressure prices down |

---

## Document History

| Version | Date | Changes |
|---------|------|---------|
| 0.1 | January 2026 | Initial specification |
| 0.2 | January 2026 | Added Section 9: Ancillary Revenue |
| 0.3 | January 2026 | Added Section 9: Cargo Revenue (renumbered ancillary to 10) |
