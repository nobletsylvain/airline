# World Events — Detailed Specification

**Version:** 0.1  
**Date:** January 2026  
**Companion to:** Game Design Document v0.7, AI Competitors Spec v0.1

---

## Overview

World Events are the external forces that shape the airline industry — economic cycles, competitor moves, disruptions, and opportunities that exist independent of player action.

**Design Philosophy:** The world doesn't revolve around you. Events happen because the simulation is alive, not to create drama for the player. Some events are predictable (seasons, cycles), some are observable (competitor moves), and some are random (disruptions). The player's job is to read the environment and adapt.

**Core Principle:** If you do nothing for a year, the world should change without you.

---

## 1. Event Categories

### 1.1 Category Overview

| Category | Predictability | Scope | Duration | Player Agency |
|----------|----------------|-------|----------|---------------|
| **Economic** | Partial | Global/Regional | Months-Years | Adapt |
| **Industry** | Observable | Sector | Months-Years | Respond |
| **Competitive** | Observable | Local | Weeks-Months | Counter |
| **Disruption** | Low | Variable | Days-Months | Manage |
| **Opportunity** | Low | Variable | Days-Weeks | Seize or pass |
| **Regulatory** | Medium | Regional | Permanent | Comply |
| **Seasonal** | High | Route-level | Weeks | Plan |

### 1.2 Event Frequency

| Category | Frequency | Notes |
|----------|-----------|-------|
| Economic cycle shift | 1-2 per decade | Major phases |
| Industry events | 4-8 per year | Manufacturer, labor, etc. |
| Competitive events | 2-6 per year | Per significant competitor |
| Disruptions | 3-10 per year | Weather, technical, political |
| Opportunities | 4-12 per year | Based on player position |
| Regulatory changes | 1-3 per year | Major changes |
| Seasonal patterns | Continuous | Predictable cycles |

---

## 2. Economic Events

### 2.1 Economic Cycles

| Phase | Duration | Demand | Yields | Costs | Asset Values |
|-------|----------|--------|--------|-------|--------------|
| **Expansion** | 2-4 years | Growing +3-6%/yr | Rising | Stable | Rising |
| **Peak** | 6-18 months | High, stable | Maximum | Rising | Maximum |
| **Contraction** | 1-3 years | Falling -5-15%/yr | Falling | Sticky | Falling |
| **Trough** | 6-18 months | Low, stable | Minimum | Falling | Minimum |
| **Recovery** | 1-2 years | Growing +5-10%/yr | Rising | Stable | Rising |

### 2.2 Economic Event Types

| Event | Probability | Effect | Duration |
|-------|-------------|--------|----------|
| **Recession** | Per cycle | Demand -15-30%, yields -10-20% | 1-3 years |
| **Fuel shock** | 10%/year | Fuel +50-150% | 3-18 months |
| **Currency crisis** | 5%/year regional | Costs ±20-40% in region | 6-24 months |
| **Inflation spike** | 8%/year | Costs +5-15%, yields lag | 1-3 years |
| **Credit crunch** | Per cycle | Financing +200-400 bps | 6-24 months |

### 2.3 Economic Event Display

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  ⚠ ECONOMIC EVENT                                                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  OIL PRICE SHOCK                                                           │
│                                                                             │
│  Crude oil prices have surged following Middle East tensions.              │
│                                                                             │
│  IMPACT                                                                     │
│  Fuel cost: +65% ($2.40 → $3.96/gallon)                                   │
│  Your exposure: $14.2M additional annual cost (38% hedged)                 │
│  Industry response: Fare increases expected                                │
│                                                                             │
│  EXPECTED DURATION: 6-12 months                                            │
│                                                                             │
│  YOUR OPTIONS                                                               │
│  · Increase fares (risk: demand loss)                                      │
│  · Absorb costs (risk: margin compression)                                 │
│  · Add fuel surcharges (risk: customer backlash)                          │
│  · Accelerate hedging (if available)                                       │
│                                                                             │
│  [View fuel strategy] [Pricing review] [Dismiss]                           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Industry Events

### 3.1 Manufacturer Events

| Event | Probability | Effect |
|-------|-------------|--------|
| **Production increase** | 5%/year | Shorter backlogs, better discounts |
| **Production problem** | 8%/year | Delivery delays, groundings |
| **New model launch** | 2-3 per decade | Order opportunities |
| **Grounding** | 2%/year | Fleet disruption if affected |
| **Bankruptcy/merger** | Rare | Supply chain disruption |

### 3.2 Labor Events

| Event | Probability | Effect | Player Impact |
|-------|-------------|--------|---------------|
| **Industry pilot shortage** | Cyclical | Wage pressure +10-20% | Hiring difficulty |
| **Union action (other airline)** | 5%/year | Spillover demand | Opportunity |
| **Your union action** | Based on relations | Operations disrupted | Direct |
| **Pension crisis** | Rare | Legacy carrier stress | Competitive |
| **Training backlog** | Cyclical | Crew availability | Growth constraint |

### 3.3 Industry Event Display

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  INDUSTRY NEWS                                                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  BOEING 737 MAX DELIVERY DELAYS                                            │
│                                                                             │
│  Boeing has announced 6-month delays on 737 MAX deliveries due to         │
│  supplier quality issues.                                                  │
│                                                                             │
│  YOUR POSITION                                                              │
│  Orders affected: 4 aircraft (Q2-Q3 2027 → Q4 2027-Q1 2028)               │
│  Network impact: Lyon-Barcelona expansion delayed                          │
│  Financial impact: $2.1M lease costs to bridge gap                        │
│                                                                             │
│  COMPENSATION OFFERED                                                       │
│  Boeing offering: $400K credit per aircraft + priority slots               │
│                                                                             │
│  [Accept compensation] [Negotiate] [Explore alternatives]                  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 4. Competitive Events

### 4.1 Competitor Actions

| Action | Detection | Lead Time | Your Options |
|--------|-----------|-----------|--------------|
| **Route entry** | Slot filing | 2-4 months | Defend, yield, counter |
| **Route exit** | Schedule drop | 1-2 months | Expand, hold |
| **Capacity increase** | Schedule | 1-3 months | Match, differentiate |
| **Price war** | Fare tracking | Immediate | Match, absorb, retreat |
| **Hub opening** | Press/slots | 6-12 months | Counter-hub, defend |
| **Alliance join** | Press | 3-6 months | Seek own partners |
| **Merger** | Press/regulatory | 6-18 months | Object, adapt |
| **Bankruptcy** | Press/filings | Varies | Acquire assets, routes |

### 4.2 Competitor Intelligence

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  COMPETITIVE INTELLIGENCE                                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  RECENT COMPETITOR MOVES (last 30 days)                                    │
│                                                                             │
│  SkyEuro · High friction competitor                                        │
│  ├─ Filed for LYS-BCN slots (your route) · 3 weeks ago                     │
│  ├─ Announced 4 A320neo order · 2 weeks ago                                │
│  └─ Reduced LYS-CDG fares 12% · 5 days ago                                 │
│                                                                             │
│  TransAir · Moderate friction                                              │
│  ├─ Exiting LYS-MRS route · effective next month                          │
│  └─ CEO resigned · succession unclear                                      │
│                                                                             │
│  EuroWings · Low friction                                                  │
│  └─ No significant moves                                                   │
│                                                                             │
│  MARKET RUMORS                                                              │
│  · "SkyEuro seeking investors for expansion"                               │
│  · "TransAir may be acquisition target"                                    │
│                                                                             │
│  [Detailed analysis] [Set alerts] [Dismiss]                                │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.3 Competitive Response Window

When significant competitor action detected:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  ⚡ COMPETITOR ACTION DETECTED                                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  SkyEuro entering Lyon → Barcelona                                         │
│                                                                             │
│  THEIR POSITION                                                             │
│  Start: Summer season (4 months away)                                      │
│  Frequency: 2x daily                                                       │
│  Aircraft: A320neo                                                         │
│  Pricing: Unknown (expect aggressive)                                      │
│                                                                             │
│  YOUR CURRENT POSITION                                                      │
│  Frequency: 3x daily                                                       │
│  Market share: 45% (2 other competitors)                                   │
│  Profitability: €2.1M annual                                               │
│                                                                             │
│  RESPONSE OPTIONS                                                           │
│                                                                             │
│  [Increase frequency] Add 4th daily — requires aircraft                    │
│  [Preemptive pricing] Cut fares 15% before they launch                    │
│  [Quality focus] Enhance product, maintain premium                         │
│  [Schedule optimization] Capture peak times                                │
│  [Do nothing] Wait and observe their performance                          │
│                                                                             │
│  Decision needed by: [No deadline — but earlier is better]                 │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 5. Disruption Events

### 5.1 Weather Disruptions

| Event | Probability | Duration | Scope |
|-------|-------------|----------|-------|
| **Winter storm** | Seasonal | 1-3 days | Regional |
| **Hurricane** | Seasonal | 3-7 days | Regional |
| **Volcanic ash** | 1%/year | 1-14 days | Continental |
| **Fog** | Seasonal | Hours-1 day | Airport |
| **Extreme heat** | Seasonal | Hours | Airport |

### 5.2 Technical Disruptions

| Event | Probability | Duration | Scope |
|-------|-------------|----------|-------|
| **ATC failure** | 3%/year | Hours-1 day | Regional |
| **Airport closure** | 2%/year | Hours-days | Single airport |
| **IT outage (yours)** | 5%/year | Hours | Your airline |
| **IT outage (industry)** | 2%/year | Hours | Multiple airlines |
| **Fleet grounding** | Based on type | Days-months | Affected type |

### 5.3 Political Disruptions

| Event | Probability | Duration | Scope |
|-------|-------------|----------|-------|
| **Airspace closure** | 2%/year | Days-months | Country/region |
| **Sanctions** | Rare | Indefinite | Country |
| **Travel ban** | Rare | Weeks-months | Country pair |
| **Civil unrest** | 3%/year | Days-weeks | City/country |
| **War** | Rare | Indefinite | Region |

### 5.4 Disruption Response

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  ⚠ DISRUPTION EVENT                                                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  WINTER STORM · Northern Europe                                            │
│                                                                             │
│  Severe winter weather affecting: CDG, AMS, FRA, BRU, LHR                  │
│  Expected duration: 48-72 hours                                            │
│                                                                             │
│  YOUR IMPACT                                                                │
│  Flights cancelled: 34                                                     │
│  Passengers affected: 4,847                                                │
│  Aircraft stranded: 6 (at affected airports)                               │
│  Est. cost: €1.2M (rebooking, hotels, compensation)                        │
│                                                                             │
│  OPERATIONS STATUS                                                          │
│  CDG: Closed until tomorrow 14:00                                          │
│  LHR: Reduced operations (40% capacity)                                    │
│  AMS: Closed until tomorrow 06:00                                          │
│                                                                             │
│  AUTOMATIC ACTIONS (per policy)                                             │
│  ✓ Rebooking on next available flights                                     │
│  ✓ Hotel vouchers for overnight stranded                                   │
│  ✓ EU261 compensation processing                                           │
│                                                                             │
│  DECISIONS NEEDED                                                           │
│  · Wet lease to clear backlog? (+€180K, clears 2 days faster)             │
│  · Extend rebooking to partner airlines? (+€90K)                          │
│  · Proactive compensation? (+€50K, brand benefit)                         │
│                                                                             │
│  [Recovery options] [View affected flights] [Dismiss]                      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 6. Opportunity Events

### 6.1 Opportunity Types

| Type | Trigger | Window | Example |
|------|---------|--------|---------|
| **Distressed asset** | Competitor trouble | Days-weeks | Aircraft at 70% value |
| **Slot availability** | Carrier exit/downgrade | Days | Prime slots open |
| **Route opening** | Bilateral signed | Months | New country access |
| **Merger clearance** | Regulatory | Months | Divested assets available |
| **Event demand** | Calendar | Known | Olympics, World Cup |
| **Partnership offer** | AI initiative | Weeks | Codeshare proposal |

### 6.2 Opportunity Display

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  💡 OPPORTUNITY                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  DISTRESSED AIRCRAFT AVAILABLE                                             │
│                                                                             │
│  TransAir entering restructuring. Liquidating 4 aircraft:                  │
│                                                                             │
│  2x A320-200 (8 years, good condition) · €12M each (market: €16M)         │
│  2x A321-200 (10 years, fair condition) · €14M each (market: €19M)        │
│                                                                             │
│  Available through: Court-appointed administrator                          │
│  Decision deadline: 2 weeks                                                │
│  Financing note: Distressed assets may have harder financing               │
│                                                                             │
│  STRATEGIC FIT                                                              │
│  A320s: Good fit for regional expansion                                    │
│  A321s: Could enable new long thin routes                                  │
│                                                                             │
│  [Express interest] [Request inspection] [Pass]                            │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 7. Regulatory Events

### 7.1 Regulatory Changes

| Change | Lead Time | Impact |
|--------|-----------|--------|
| **Open skies agreement** | 6-12 months | New route access |
| **Slot regulation change** | 3-6 months | Allocation rules |
| **Environmental rules** | 1-2 years | Fleet/operations cost |
| **Safety directive** | Immediate-months | Compliance cost |
| **Tax change** | Budget cycle | Operating cost |
| **Ownership rules** | 6-12 months | Investment/structure |

### 7.2 Regulatory Display

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  📋 REGULATORY CHANGE                                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  EU EMISSIONS TRADING EXPANSION                                            │
│                                                                             │
│  Effective: January 2028                                                   │
│                                                                             │
│  CHANGE                                                                     │
│  All intra-EU flights now subject to ETS carbon pricing.                   │
│  Free allowances reduced from 80% to 50%.                                  │
│                                                                             │
│  YOUR IMPACT                                                                │
│  Annual emissions: 124,000 tonnes CO2                                      │
│  Allowances needed: 62,000 tonnes (at €85/tonne = €5.3M)                  │
│  Previous cost: €2.1M                                                      │
│  Additional cost: €3.2M annually                                           │
│                                                                             │
│  MITIGATION OPTIONS                                                         │
│  · Fleet renewal (newer aircraft = -15% emissions)                         │
│  · Route optimization (shorter routings)                                   │
│  · SAF blending (expensive but reduces obligation)                         │
│  · Carbon offsets (reputational benefit)                                   │
│                                                                             │
│  [View compliance options] [Fleet analysis] [Dismiss]                      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 8. Event Mechanics

### 8.1 Probability System

Base probability modified by:

```
Event_Probability = Base_Rate × Cycle_Modifier × Region_Modifier × Random

Where:
  Base_Rate = Event-specific annual probability
  Cycle_Modifier = Economic phase adjustment (0.5-2.0)
  Region_Modifier = Geographic relevance (0-1)
  Random = Dice roll
```

### 8.2 Event Generation Rules

| Rule | Description |
|------|-------------|
| **Spacing** | Minimum 30 days between major events of same type |
| **Clustering** | Bad news can cluster (realistic), good news spaced |
| **Caps** | Maximum 2 major disruptive events per quarter |
| **Fairness** | Events affect player proportionally, not targeted |
| **Preconditions** | Some events require setup (merger needs 2 weak airlines) |

### 8.3 Event Cascade System

Events can trigger follow-on events:

```
OIL SHOCK
  └→ May trigger: Airline failures (6-12 months)
       └→ May trigger: Consolidation opportunities
       
RECESSION
  └→ Triggers: Demand reduction (immediate)
  └→ May trigger: Competitor distress (6-18 months)
  └→ May trigger: Asset price drops (3-12 months)

COMPETITOR BANKRUPTCY
  └→ Triggers: Route opportunities (immediate)
  └→ Triggers: Slot availability (1-3 months)
  └→ May trigger: Asset sales (1-6 months)
```

---

## 9. Data Model Integration

### 9.1 WorldEvent Entity

| Field | Type | Purpose |
|-------|------|---------|
| `id` | UUID | Primary key |
| `type` | enum | Event category |
| `subtype` | string | Specific event |
| `severity` | int | 1-10 impact scale |
| `scope` | enum | GLOBAL / REGIONAL / LOCAL |
| `affected_regions` | string[] | Geographic scope |
| `start_date` | date | When event begins |
| `expected_end` | date? | Predicted end |
| `actual_end` | date? | When resolved |
| `effects` | json | Specific impacts |
| `player_notified` | bool | Shown to player |
| `player_response` | json? | Player actions taken |

### 9.2 Enumerations

```yaml
WorldEventType:
  ECONOMIC_CYCLE
  FUEL_SHOCK
  CURRENCY_CRISIS
  CREDIT_CRUNCH
  MANUFACTURER_ISSUE
  LABOR_MARKET
  COMPETITOR_ACTION
  WEATHER_DISRUPTION
  TECHNICAL_DISRUPTION
  POLITICAL_DISRUPTION
  REGULATORY_CHANGE
  OPPORTUNITY
  PANDEMIC

EventSeverity:
  MINOR           # 1-3: Notable but manageable
  MODERATE        # 4-6: Significant impact
  MAJOR           # 7-8: Serious consequences
  SEVERE          # 9-10: Crisis level

EventScope:
  GLOBAL          # Affects all regions
  CONTINENTAL     # Affects continent
  REGIONAL        # Affects region
  NATIONAL        # Affects country
  LOCAL           # Affects city/airport

EventStatus:
  BREWING         # Signs visible, not yet impacting
  ACTIVE          # Currently affecting operations
  PEAK            # Maximum impact
  SUBSIDING       # Impact reducing
  RESOLVED        # Event over, effects may linger
```

---

## 10. Notification System

### 10.1 Alert Levels

| Level | Events | Behavior |
|-------|--------|----------|
| **Critical** | Crisis, major disruption | Always interrupt, pause game |
| **Important** | Competitor moves, opportunities | Default interrupt |
| **Notable** | Industry news, minor events | Notification panel |
| **Background** | Market data, trends | Weekly digest |

### 10.2 Player Preferences

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  EVENT NOTIFICATION SETTINGS                                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  INTERRUPT GAME FOR:                                                        │
│  [✓] Crisis events (cash, safety, strikes)                                 │
│  [✓] Major competitor moves                                                │
│  [✓] Time-sensitive opportunities                                          │
│  [ ] All disruptions                                                       │
│  [ ] Industry news                                                         │
│                                                                             │
│  NOTIFICATION PANEL FOR:                                                    │
│  [✓] Competitor intelligence                                               │
│  [✓] Regulatory changes                                                    │
│  [✓] Economic indicators                                                   │
│  [✓] Market opportunities                                                  │
│                                                                             │
│  WEEKLY DIGEST INCLUDES:                                                    │
│  [✓] Industry summary                                                      │
│  [✓] Competitor activity                                                   │
│  [✓] Economic outlook                                                      │
│                                                                             │
│  [Save preferences]                                                        │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Document History

| Version | Date | Changes |
|---------|------|---------|
| 0.1 | January 2026 | Initial specification |
