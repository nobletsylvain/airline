# AI Competitors — Detailed Specification

**Version:** 0.1  
**Date:** January 2026  
**Companion to:** Game Design Document v0.7, Route Economics Spec v0.1

---

## Overview

This document specifies how AI-controlled airlines behave in Airliner — their decision-making, competitive responses, and emergent rivalry dynamics.

**Design Philosophy:** AI airlines should feel like real competitors, not scripted obstacles. They pursue their own strategies, make mistakes, and respond to your actions in ways that feel believable. The world doesn't revolve around you — but competition emerges naturally.

**Core Principle:** AI airlines optimize for their own goals, not to thwart the player.

---

## 1. AI Airline Types

### 1.1 Archetypes

| Type | Behavior | Strengths | Weaknesses |
|------|----------|-----------|------------|
| **Flag carrier** | Conservative, network-focused | Brand, slots, government support | Cost structure, bureaucracy |
| **LCC** | Aggressive growth, cost-focused | Efficiency, pricing | Service, premium traffic |
| **Regional** | Niche routes, feed traffic | Flexibility, specialized | Scale, range |
| **Gulf carrier** | Premium service, hub-focused | Capital, service | Subsidies (political) |
| **Startup** | Aggressive, disruptive | Fresh approach | Capital, experience |

### 1.2 AI Airline Parameters

| Parameter | Range | Effect |
|-----------|-------|--------|
| **Aggressiveness** | 0-100 | Likelihood of price wars, route entry |
| **Risk tolerance** | 0-100 | Willingness to expand despite uncertainty |
| **Cost focus** | 0-100 | Emphasis on CASK optimization |
| **Service focus** | 0-100 | Investment in product quality |
| **Network strategy** | Hub/Point-to-point/Hybrid | Route selection logic |
| **Growth appetite** | -20% to +30% | Annual capacity change target |

---

## 2. Decision Making

### 2.1 AI Decision Cycle

AI airlines evaluate decisions on a regular cycle:

| Decision Type | Frequency | Factors Considered |
|---------------|-----------|-------------------|
| Pricing | Weekly | Demand, competition, load factor |
| Frequency | Monthly | Demand, profitability, slots |
| Route entry | Quarterly | Market opportunity, network fit |
| Route exit | Quarterly | Sustained losses, better alternatives |
| Fleet changes | Annually | Growth plan, fleet age, efficiency |

### 2.2 Route Entry Logic

AI considers entering a route when:

```python
# Simplified entry decision
def should_enter_route(ai_airline, route):
    score = 0
    
    # Market attractiveness
    if route.unserved_demand > threshold:
        score += 30
    if route.avg_yield > ai_airline.target_yield:
        score += 20
    
    # Network fit
    if route.connects_to_hub(ai_airline.hub):
        score += 25
    if route.extends_network_logically:
        score += 15
    
    # Competitive landscape
    if route.competitor_count < 2:
        score += 20
    if route.competitor_margins > 10%:
        score += 10  # Profitable market
    
    # Operational fit
    if ai_airline.has_suitable_aircraft:
        score += 15
    if ai_airline.has_crew_capacity:
        score += 10
    
    # Risk factors
    if route.requires_new_base:
        score -= 20
    if route.seasonal_demand > 50%:
        score -= 10
    
    return score > ai_airline.entry_threshold
```

### 2.3 Route Exit Logic

AI exits routes when:

| Trigger | Threshold | Delay |
|---------|-----------|-------|
| Sustained losses | >6 months | 3 months after trigger |
| Load factor collapse | <50% for 3 months | 2 months |
| Better use of aircraft | Higher ROI elsewhere | Next schedule change |
| Competitive destruction | Price war unsustainable | 6-12 months |
| Strategic shift | Network restructure | Major planning cycle |

### 2.4 Pricing Logic

```python
def set_price(ai_airline, route):
    base_price = route.market_average_fare
    
    # Adjust for strategy
    if ai_airline.strategy == "LCC":
        target = base_price * 0.85  # Undercut market
    elif ai_airline.strategy == "PREMIUM":
        target = base_price * 1.15  # Premium positioning
    else:
        target = base_price * 1.0   # Match market
    
    # Adjust for load factor
    if route.our_load_factor < 70%:
        target *= 0.95  # Stimulate demand
    elif route.our_load_factor > 90%:
        target *= 1.05  # Capture yield
    
    # Competitive response
    if player_just_cut_prices:
        if should_match(ai_airline, route):
            target = min(target, player_price * 1.02)
    
    return max(target, route.variable_cost * 1.1)  # Floor
```

---

## 3. Competitive Response

### 3.1 Response Triggers

| Your Action | AI Detection | Response |
|-------------|--------------|----------|
| Enter new route | Immediate | Monitor, then match/ignore |
| Price cut <10% | Weekly analysis | Likely ignore |
| Price cut 10-20% | Weekly analysis | May match |
| Price cut >20% | Immediate | Match or exit |
| Frequency increase | Monthly analysis | Evaluate response |
| Quality improvement | Quarterly review | Slow response |
| Hub development | Ongoing monitoring | Strategic assessment |

### 3.2 Response Decision

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  AI COMPETITOR ANALYSIS (Internal - player doesn't see this)               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  MERIDIAN AIR entered LYS-BCN                                              │
│                                                                             │
│  Our current position:                                                      │
│  - We have 3x daily, 75% LF, 8% margin                                     │
│  - Market share: 45%                                                       │
│                                                                             │
│  Their entry:                                                               │
│  - 2x daily, likely ~$120 fare (vs our $135)                              │
│  - Projected impact: -12% share, -3% margin                                │
│                                                                             │
│  Options evaluated:                                                         │
│  1. Match price: Cost $1.2M/year, maintain share                           │
│  2. Match frequency: Add flight, cost $800K/year                           │
│  3. Do nothing: Accept share loss, maintain yield                          │
│  4. Exit route: Redeploy aircraft to better market                         │
│                                                                             │
│  Decision: Option 3 (do nothing) - Route still profitable                 │
│  Reassess: In 3 months if share drops below 35%                           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3.3 Price War Dynamics

When price wars occur:

| Phase | Duration | AI Behavior |
|-------|----------|-------------|
| **Trigger** | Week 1 | Someone cuts >20% |
| **Escalation** | Weeks 2-4 | Others match, potentially undercut |
| **Destruction** | Months 1-6 | All participants lose money |
| **Attrition** | Months 3-12 | Weakest exits |
| **Recovery** | After exit | Survivors raise prices |

AI airlines have a "pain threshold" — how long they'll sustain losses before acting.

---

## 4. AI Personalities

### 4.1 Behavioral Modifiers

Each AI airline has distinct personality:

| Personality Trait | Low (0-30) | Medium (40-60) | High (70-100) |
|-------------------|------------|----------------|---------------|
| **Aggressive** | Avoids confrontation | Normal competition | Actively attacks |
| **Patient** | Quick reactions | Balanced timing | Long-term view |
| **Rational** | Emotional decisions | Cost-benefit | Purely economic |
| **Innovative** | Copies others | Selective adoption | Early mover |

### 4.2 Sample AI Airlines

**EuroWings (LCC)**
- Aggressiveness: 75
- Risk tolerance: 60
- Cost focus: 90
- Service focus: 20
- Strategy: Aggressive growth, price competition

**National Airways (Flag Carrier)**
- Aggressiveness: 35
- Risk tolerance: 40
- Cost focus: 45
- Service focus: 75
- Strategy: Protect hub, premium positioning

**SkyConnect (Regional)**
- Aggressiveness: 50
- Risk tolerance: 70
- Cost focus: 60
- Service focus: 50
- Strategy: Feed traffic, niche routes

---

## 5. Emergent Rivalry

### 5.1 Rivalry Detection

The system tracks friction between player and AI airlines:

| Event | Friction Points |
|-------|-----------------|
| Enter same route | +5 |
| Price war | +15 |
| Slot contest | +10 |
| Poach employee | +8 |
| Marketing clash | +5 |
| Time passes (monthly) | -2 (decay) |

### 5.2 Rivalry Levels

| Friction Score | Relationship | AI Behavior |
|----------------|--------------|-------------|
| 0-20 | Neutral | Normal competition |
| 20-40 | Competitive | More likely to respond |
| 40-60 | Hostile | Actively targets you |
| 60-80 | Rival | Prioritizes hurting you |
| 80+ | Nemesis | Will sacrifice profits to damage you |

### 5.3 Player Perception

Player doesn't see friction scores, but observes behavior:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  COMPETITIVE INTELLIGENCE                                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  EUROWINGS                                                                  │
│  Relationship: Increasingly competitive                                     │
│                                                                             │
│  Recent actions against you:                                                │
│  • Jan 15: Matched your LYS-BCN price cut within 48 hours                  │
│  • Jan 10: Added 3rd daily on LYS-CDG (your profitable route)              │
│  • Dec 28: Launched aggressive marketing in Lyon market                    │
│                                                                             │
│  Analysis:                                                                  │
│  "EuroWings appears to be targeting your Lyon hub. Their recent            │
│   capacity additions exceed normal growth patterns. Expect continued       │
│   competitive pressure on your core routes."                               │
│                                                                             │
│  [Monitor closely] [View their network] [Competitive response options]     │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 6. Alliance & Codeshare AI

### 6.1 AI Alliance Behavior

| Alliance Type | AI Behavior |
|---------------|-------------|
| **Member** | Coordinates schedules, shares lounges |
| **Partner** | Codeshares, may compete on non-partner routes |
| **Unaligned** | Fully independent |

### 6.2 Codeshare Logic

AI proposes codeshares when:
- Route connects their network to unreachable destination
- Joint service would beat competitor
- Cost sharing makes marginal route viable

### 6.3 Alliance Invitation

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  ALLIANCE INVITATION                                                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  From: SkyTeam Alliance                                                    │
│  Sponsor: Air France                                                       │
│                                                                             │
│  "Air France has nominated Meridian Air for SkyTeam membership.            │
│   Your growing Lyon hub and complementary network make you an              │
│   attractive partner."                                                     │
│                                                                             │
│  Benefits:                                                                  │
│  • Codeshare access to 850+ destinations                                   │
│  • Joint frequent flyer program                                            │
│  • Shared lounge access                                                    │
│  • Coordinated schedules                                                   │
│                                                                             │
│  Obligations:                                                               │
│  • Service standards compliance                                            │
│  • Revenue sharing on codeshares                                           │
│  • Cannot join competing alliance                                          │
│  • Annual membership fees: $2.4M                                           │
│                                                                             │
│  [Accept invitation] [Negotiate terms] [Decline]                           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 7. AI Mistakes & Weaknesses

### 7.1 AI Can Make Bad Decisions

To feel realistic, AI airlines sometimes:

| Mistake Type | Probability | Example |
|--------------|-------------|---------|
| **Overexpansion** | 10%/year | Too many routes, cash crunch |
| **Mispricing** | 5%/quarter | Wrong response to market |
| **Bad timing** | 15%/major decision | Order aircraft at peak prices |
| **Underreaction** | 20% | Ignore competitive threat too long |
| **Overreaction** | 15% | Excessive response to minor threat |

### 7.2 AI Financial Stress

AI airlines can go bankrupt:

| Indicator | Effect |
|-----------|--------|
| Losses >2 years | Seeks merger/sale |
| Cash <3 months | Emergency measures |
| Covenant breach | Restructuring |
| No recovery path | Liquidation |

---

## 8. Data Model Integration

### 8.1 Entities

**AIAirline** — AI competitor configuration

| Field | Type | Purpose |
|-------|------|---------|
| `airline_id` | FK | Base airline entity |
| `archetype` | enum | FLAG_CARRIER / LCC / REGIONAL / GULF |
| `aggressiveness` | int | 0-100 |
| `risk_tolerance` | int | 0-100 |
| `cost_focus` | int | 0-100 |
| `service_focus` | int | 0-100 |
| `network_strategy` | enum | HUB / POINT_TO_POINT / HYBRID |
| `growth_target` | float | Annual % |
| `pain_threshold` | int | Months of losses before exit |

**CompetitorRelationship** — Tracks friction with player

| Field | Type | Purpose |
|-------|------|---------|
| `player_airline_id` | FK | Player |
| `competitor_id` | FK | AI airline |
| `friction_score` | int | 0-100 |
| `rivalry_level` | enum | NEUTRAL / COMPETITIVE / HOSTILE / RIVAL |
| `recent_events` | json | Last 90 days |

### 8.2 New Enumerations

```yaml
AIArchetype:
  FLAG_CARRIER
  LCC
  REGIONAL
  GULF
  STARTUP
  CARGO

NetworkStrategy:
  HUB
  POINT_TO_POINT
  HYBRID
  FOCUS_CITY

RivalryLevel:
  NEUTRAL
  COMPETITIVE
  HOSTILE
  RIVAL
  NEMESIS
```

---

## 9. Alliances & Codeshares

### 9.1 Alliance Structure

| Alliance Type | Commitment | Benefits | Obligations |
|---------------|------------|----------|-------------|
| **Global alliance** | High | Full network access, lounges, FFP | Revenue share, standards |
| **Regional alliance** | Medium | Regional network, some lounges | Limited standards |
| **Bilateral partnership** | Low | Specific route cooperation | Route-specific only |

### 9.2 Alliance Membership

**Global alliances in game:**

| Alliance | Character | Typical Members |
|----------|-----------|-----------------|
| **StarAlliance** | Premium legacy | Flag carriers, quality focus |
| **SkyTeam** | Mixed | European/Asian focus |
| **Oneworld** | Transatlantic focus | Premium transcontinental |

**Joining an alliance:**

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  ALLIANCE INVITATION · StarAlliance                                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  StarAlliance is interested in your membership.                            │
│                                                                             │
│  WHY THEY WANT YOU                                                          │
│  · Strong Lyon hub fills network gap                                       │
│  · Your service quality matches standards                                  │
│  · Regional feed for their long-haul members                               │
│                                                                             │
│  MEMBERSHIP BENEFITS                                                        │
│  · Codeshare access to 847 destinations                                    │
│  · Shared lounge access (23 partner lounges)                               │
│  · FFP reciprocity (earn/burn across network)                              │
│  · Joint purchasing (fuel, catering, IT)                                   │
│  · Marketing: "Member of StarAlliance"                                     │
│                                                                             │
│  MEMBERSHIP OBLIGATIONS                                                     │
│  · Service standards compliance (you meet 94%)                             │
│  · IT system integration ($2.4M one-time)                                  │
│  · Annual fee: $1.2M                                                       │
│  · Revenue share on codeshare segments: 18%                                │
│  · Cannot partner with competing alliances                                 │
│                                                                             │
│  SPONSOR: Lufthansa (relationship: Positive)                               │
│                                                                             │
│  [Accept invitation] [Negotiate terms] [Decline] [Request time]            │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 9.3 Codeshare Agreements

**Codeshare types:**

| Type | Description | Revenue Model |
|------|-------------|---------------|
| **Free-flow** | Either airline sells all segments | Prorate by distance |
| **Block space** | Buy seats wholesale | Fixed purchase |
| **Hard block** | Guaranteed seats | Must pay regardless |
| **Soft block** | Seats until deadline | Release if unsold |

**Codeshare negotiation:**

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  CODESHARE PROPOSAL · Air France                                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Air France proposes codeshare on your Lyon routes.                        │
│                                                                             │
│  THEIR REQUEST                                                              │
│  Routes: LYS-NCE, LYS-MRS, LYS-TLS                                         │
│  Type: Free-flow codeshare                                                 │
│  Their code: AF 4xxx on your flights                                       │
│  Prorate: 18% to marketing carrier (them when they sell)                   │
│                                                                             │
│  WHAT YOU GET                                                               │
│  · Access to AF CDG hub connections                                        │
│  · Your code on AF CDG-LYS (feed to your routes)                          │
│  · GDS visibility boost                                                    │
│  · Est. incremental revenue: €340K annually                                │
│                                                                             │
│  WHAT YOU GIVE                                                              │
│  · They sell your seats (18% to them)                                      │
│  · Brand dilution (AF passengers on your planes)                           │
│  · Schedule coordination requirements                                      │
│                                                                             │
│  STRATEGIC CONSIDERATION                                                    │
│  Air France is a potential competitor. This partnership could:             │
│  · Keep them cooperative (less likely to enter your routes)                │
│  · Give them market intelligence (risky)                                   │
│                                                                             │
│  [Accept] [Counter-propose] [Decline]                                      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 9.4 Interline Agreements

Simpler than codeshare — just ticket acceptance:

| Agreement | Scope | Benefit |
|-----------|-------|---------|
| **Basic interline** | Accept each other's tickets | Connection bookings |
| **Baggage interline** | Through-check bags | Better pax experience |
| **Schedule interline** | Coordinated connections | Minimum connect times |

### 9.5 Partnership Effects

| Partnership Level | Pricing | Scheduling | Operations |
|-------------------|---------|------------|------------|
| **None** | Independent | Independent | Independent |
| **Interline** | Separate tickets | MCT published | Bag transfer |
| **Codeshare** | Single ticket | Some coordination | Shared inventory |
| **JV (rare)** | Revenue pooled | Full coordination | Shared metal |
| **Alliance** | Global benefits | Network-wide | Standards |

### 9.6 Partnership Strategy

AI airlines seek partnerships based on:

| Factor | Weight | Logic |
|--------|--------|-------|
| Network complementarity | High | Fill gaps, not overlap |
| Quality match | Medium | Similar service standards |
| Hub proximity | Medium | Feed traffic potential |
| Existing competition | Negative | Less likely if rivals |
| Alliance membership | High | Same alliance preferred |

### 9.7 Alliance Data Model

**Alliance entity:**

| Field | Type | Purpose |
|-------|------|---------|
| `id` | UUID | Primary key |
| `name` | string | Alliance name |
| `type` | enum | GLOBAL / REGIONAL / BILATERAL |
| `annual_fee` | decimal | Membership cost |
| `service_standards` | json | Required minimums |
| `member_count` | int | Current members |

**AllianceMembership entity:**

| Field | Type | Purpose |
|-------|------|---------|
| `id` | UUID | Primary key |
| `airline_id` | FK | Member airline |
| `alliance_id` | FK | Alliance |
| `joined_date` | date | Membership start |
| `tier` | enum | FULL / REGIONAL / AFFILIATE |
| `sponsor_id` | FK? | Sponsoring member |
| `status` | enum | ACTIVE / SUSPENDED / PENDING |

**Codeshare entity:**

| Field | Type | Purpose |
|-------|------|---------|
| `id` | UUID | Primary key |
| `marketing_carrier_id` | FK | Sells the seat |
| `operating_carrier_id` | FK | Flies the plane |
| `routes` | FK[] | Covered routes |
| `codeshare_type` | enum | FREE_FLOW / BLOCK / HARD / SOFT |
| `prorate_pct` | float | Marketing carrier share |
| `start_date` | date | Agreement start |
| `end_date` | date | Agreement end |
| `status` | enum | ACTIVE / TERMINATED / PENDING |

### 9.8 Partnership Enumerations

```yaml
AllianceType:
  GLOBAL              # StarAlliance, SkyTeam, Oneworld
  REGIONAL            # Regional groupings
  BILATERAL           # Two-airline partnership

MembershipTier:
  FULL                # Full voting member
  REGIONAL            # Regional affiliate
  AFFILIATE           # Limited participation
  CONNECTING          # Interline only

CodeshareType:
  FREE_FLOW           # Either sells all segments
  BLOCK_SPACE         # Wholesale seat purchase
  HARD_BLOCK          # Guaranteed purchase
  SOFT_BLOCK          # Release if unsold

PartnershipStatus:
  ACTIVE              # In force
  PENDING             # Under negotiation
  SUSPENDED           # Temporarily halted
  TERMINATED          # Ended
```

---

## Document History

| Version | Date | Changes |
|---------|------|---------|
| 0.1 | January 2026 | Initial specification |
| 0.2 | January 2026 | Added Section 9: Alliances & Codeshares |
