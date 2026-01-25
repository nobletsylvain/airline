# Difficulty Curve — Detailed Specification

**Version:** 0.2  
**Date:** January 2026  
**Companion to:** GDD v0.7 Section 9, decision-density-spec.md, economic-parameters.md  
**Addresses:** gameplay-concerns.md Section 4

---

## Overview

This document specifies how challenge scales from hour 1 to hour 100+ — ensuring the game remains engaging without becoming trivially easy or impossibly hard at any phase.

**Design Philosophy:** Difficulty should feel *natural*, not *punitive*. As the airline grows, new challenges emerge organically from complexity, competition, and the weight of past decisions. The player's capability grows too — but never fast enough to make the game feel solved.

**Core Problem:**
- Early game may be too easy (no competition, simple economics)
- Mid game may have a cliff (sudden complexity spike)
- Late game may be solved (optimal strategies become obvious)

> **⚠️ Note on Numbers:** All scaling values in this document are *hypotheses*, not validated targets. They represent design intent and require prototype testing to confirm. Expect significant tuning during playtesting.

---

## 1. Difficulty Escalation Vectors

Four primary vectors create difficulty that scales with player progression:

| Vector | What It Measures | Why It Matters |
|--------|------------------|----------------|
| **Capital Scarcity** | Access to funds, financing costs | Constrains growth, forces trade-offs |
| **Competition Intensity** | Rival behavior, market pressure | Prevents "set and forget" routes |
| **Market Saturation** | Route opportunities, slot availability | Forces creativity, blocks easy expansion |
| **Operational Complexity** | Fleet diversity, maintenance, crew | Increases cognitive load, failure modes |

### 1.1 Design Principles

**Difficulty should:**
- Emerge from gameplay systems, not artificial modifiers
- Scale with player capability (bigger airline = bigger problems)
- Present *different* challenges, not just *harder* versions of the same
- Always leave room for player skill to matter

**Difficulty should NOT:**
- Punish success (winning shouldn't make the game harder)
- Create "gotcha" moments (surprises should be manageable)
- Require external knowledge (solutions discoverable in-game)
- Make failure feel random (cause and effect must be clear)

---

## 2. Vector 1: Capital Scarcity

### 2.1 Scaling by Phase

| Phase | Capital Access | Financing Cost | Cash Buffer Risk |
|-------|---------------|----------------|------------------|
| **Founder** | Very limited | High (12-18% APR) | Critical — one bad month = crisis |
| **Manager** | Growing credit | Moderate (8-12% APR) | Moderate — 2-3 month buffer typical |
| **Executive** | Strong lines | Standard (5-8% APR) | Comfortable — focus on ROI not survival |
| **Chairman** | Near-unlimited | Low (3-6% APR) | Strategic — capital as weapon |

*Hypothesis: Interest rate spreads need playtesting to confirm they create meaningful tension.*

### 2.2 Founder Phase Capital Mechanics

**Challenge:** Every dollar matters. Growth requires sacrifice.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  FINANCIAL POSITION · Month 3                                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  CASH: $142,000                                                            │
│  Monthly burn: -$28,000                                                    │
│  Runway: 5 months (if nothing changes)                                     │
│                                                                             │
│  OPPORTUNITY                                                                │
│  Used ATR 72 available: $3.2M                                              │
│  Your cash: $142K                                                          │
│                                                                             │
│  OPTIONS                                                                    │
│  ☐ Bank loan (15% APR, needs 6-month history)      ✗ Not eligible yet     │
│  ☐ Lease ($28K/month, 36 months)                   Your burn doubles      │
│  ☐ Angel investor (wants 30% equity)               Dilution               │
│  ☐ Wait for profits (6+ months)                    Plane may sell         │
│                                                                             │
│  Every choice has cost. Welcome to aviation.                               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2.3 Capital Scarcity Prevents "Solved" States

| Phase | How Capital Creates Challenge |
|-------|------------------------------|
| Founder | Can't buy way out of problems. Must optimize what you have. |
| Manager | Growth requires debt. Debt creates covenants. Covenants constrain choices. |
| Executive | Shareholders demand returns. Can't stockpile cash forever. |
| Chairman | Capital allocation is THE decision. Wrong bets are expensive. |

---

## 3. Vector 2: Competition Intensity

*Integration: AI behavior defined in ai-competitors-spec.md (planned).*

### 3.1 Scaling by Phase

| Phase | Competitor Attention | Response Speed | Competitive Actions |
|-------|---------------------|----------------|---------------------|
| **Founder** | Minimal — you're invisible | Slow (weeks) | Ignore or gentle price matching |
| **Manager** | Noticed — potential threat | Moderate (days) | Price wars, capacity additions |
| **Executive** | Targeted — real competitor | Fast (hours) | Slot blocking, M&A attempts |
| **Chairman** | Respected — strategic rival | Variable | Alliance politics, regulatory plays |

*Hypothesis: AI response timing needs extensive playtesting.*

### 3.2 Competition Emergence Pattern

```
FOUNDER (Hours 0-10)
├── Competitors exist but ignore you
├── First route: no competition response
├── 5+ routes: minor price adjustments on overlap
└── 10 routes: First "wake up" — one competitor notices

MANAGER (Hours 10-30)
├── Regional rivals emerge as threats
├── Price matching within 48 hours of your changes
├── Capacity increases on profitable routes you dominate
└── First hostile action: competitor enters your best route

EXECUTIVE (Hours 30-70)
├── Multiple rivals watching closely
├── Slot competitions at constrained airports
├── Predatory pricing on strategic routes
└── Alliance dynamics create friend/enemy patterns

CHAIRMAN (Hours 70+)
├── Industry politics become central
├── Regulatory influence competitions
├── M&A threats and opportunities
└── Legacy airlines may seek to acquire you (or be acquired)
```

### 3.3 Competition Prevents "Solved" States

| Phase | How Competition Creates Challenge |
|-------|----------------------------------|
| Founder | Can't assume any route stays profitable forever. |
| Manager | Price optimization is a moving target — rivals adapt. |
| Executive | Network effects create interdependencies. Losing one hub damages many routes. |
| Chairman | Industry structure is fluid. Today's partner is tomorrow's threat. |

---

## 4. Vector 3: Market Saturation

### 4.1 Scaling by Phase

| Phase | Route Opportunities | Slot Availability | Market Growth |
|-------|--------------------|--------------------|---------------|
| **Founder** | Abundant — many unserved routes | Easy — secondary airports open | Strong — demand exceeds supply |
| **Manager** | Good — but best routes contested | Moderate — majors getting tight | Stable — growing with economy |
| **Executive** | Selective — easy wins exhausted | Hard — slot trading required | Mature — must steal share |
| **Chairman** | Strategic — only major plays remain | Political — regulatory involvement | Saturated — innovation required |

*Hypothesis: Slot scarcity timing (when players feel constrained) is critical to tune.*

### 4.2 Route Opportunity Decay

As the game progresses, easy opportunities diminish:

| Game Year | "Obvious" Routes | Contested Routes | Saturated Routes |
|-----------|------------------|------------------|------------------|
| Year 1 | 70% | 25% | 5% |
| Year 3 | 40% | 45% | 15% |
| Year 5 | 20% | 50% | 30% |
| Year 10 | 5% | 45% | 50% |

*"Obvious" = profitable with minimal competition. Player sees green on first analysis.*

### 4.3 Slot Scarcity Visualization

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  SLOT AVAILABILITY · London Heathrow (LHR)                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  STATUS: Severely Constrained                                              │
│  Available slots: 2 pairs (AM)                                             │
│  Wait list: 14 airlines                                                    │
│  Your position: #8                                                         │
│                                                                             │
│  OPTIONS TO ACQUIRE                                                         │
│                                                                             │
│  ① Wait for allocation          Est. 18-24 months    No cost              │
│  ② Secondary market purchase    £45M per pair        Immediate            │
│  ③ Slot swap (give up CDG)      Trade value varies   Complex              │
│  ④ Acquire slot holder          €150M+ airline       Major commitment     │
│                                                                             │
│  ⚠ Without LHR access, your transatlantic strategy is compromised         │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.4 Market Saturation Prevents "Solved" States

| Phase | How Saturation Creates Challenge |
|-------|----------------------------------|
| Founder | Must find niches, not copy incumbents. |
| Manager | Growth requires entering contested markets. |
| Executive | Expansion means M&A or accepting lower returns. |
| Chairman | Industry leadership requires shaping markets, not just entering them. |

---

## 5. Vector 4: Operational Complexity

*Integration: See maintenance-spec.md, crew-management-spec.md, service-suppliers-spec.md.*

### 5.1 Scaling by Phase

| Phase | Fleet Types | Maintenance Events | Crew Complexity | Failure Modes |
|-------|------------|--------------------|--------------------|---------------|
| **Founder** | 1 (homogeneous) | Rare, predictable | Simple — one base | Localized |
| **Manager** | 2-3 types | Regular, plannable | Growing — multiple bases | Spreading |
| **Executive** | 4-6 types | Frequent, some surprises | Complex — union issues | Systemic |
| **Chairman** | 6+ types | Constant, statistical | Political — labor relations | Cascading |

*Hypothesis: Fleet diversity penalties need careful calibration to avoid punishing reasonable fleet planning.*

### 5.2 Complexity Growth Pattern

```
FLEET SIZE: 1-5 (Founder)
├── All aircraft same type
├── Pilots fully interchangeable
├── One maintenance contract
└── Failure = inconvenience

FLEET SIZE: 6-15 (Manager)
├── 2-3 aircraft types emerging
├── Type ratings create constraints
├── Multiple maintenance relationships
└── Failure = revenue loss

FLEET SIZE: 16-40 (Executive)
├── 4-6 types including widebodies
├── Crew base optimization matters
├── Maintenance scheduling is strategic
└── Failure = cascading disruptions

FLEET SIZE: 40+ (Chairman)
├── Diverse fleet is a legacy
├── Union negotiations per fleet type
├── Retirement planning for aging types
└── Failure = systemic crisis
```

### 5.3 Operational Complexity Prevents "Solved" States

| Phase | How Complexity Creates Challenge |
|-------|----------------------------------|
| Founder | Must learn systems before scaling. |
| Manager | Can't just copy what worked — fleet needs planning. |
| Executive | Optimization is never "done" — conditions change. |
| Chairman | Legacy decisions constrain future options. |

---

## 6. Difficulty by Phase: Integrated View

### 6.1 Founder Phase (Hours 0-10)

**Primary Challenge:** Survival with limited resources.

| Vector | Intensity | Key Tension |
|--------|-----------|-------------|
| Capital Scarcity | 5/5 ⬛⬛⬛⬛⬛ Extreme | Every purchase is existential |
| Competition | 1/5 ⬛⬜⬜⬜⬜ Minimal | Free pass to establish first routes |
| Market Saturation | 1/5 ⬛⬜⬜⬜⬜ Low | Many easy opportunities |
| Operational Complexity | 1/5 ⬛⬜⬜⬜⬜ Simple | Focus on learning, not juggling |

**Failure Possibility:**
- Running out of cash before achieving profitability
- Overextending (too many routes, too fast)
- Choosing unprofitable routes and not recognizing the problem

**What Prevents "Solved" State:**
- Limited capital forces hard trade-offs (can't buy all opportunities)
- Random events introduce variance (weather, fuel spikes)
- Hidden demand factors mean route analysis isn't perfect

### 6.2 Manager Phase (Hours 10-30)

**Primary Challenge:** Growing while managing emerging complexity.

| Vector | Intensity | Key Tension |
|--------|-----------|-------------|
| Capital Scarcity | 3/5 ⬛⬛⬛⬜⬜ Moderate | Growth requires debt; debt has strings |
| Competition | 3/5 ⬛⬛⬛⬜⬜ Growing | Rivals notice and respond |
| Market Saturation | 2/5 ⬛⬛⬜⬜⬜ Moderate | Easy wins diminishing |
| Operational Complexity | 3/5 ⬛⬛⬛⬜⬜ Increasing | Fleet diversity, crew bases |

**Failure Possibility:**
- Price wars with established competitors
- Covenant violations on aggressive debt
- Fleet mismanagement (wrong types, poor timing)
- Delegation to poor executives

**What Prevents "Solved" State:**
- Competitor adaptation means strategies have shelf life
- Debt covenants create constraints on optimization
- Fleet type decisions have 10+ year consequences
- Executives introduce variance (personality affects outcomes)

### 6.3 Executive Phase (Hours 30-70)

**Primary Challenge:** Sustaining advantage while managing a large organization.

| Vector | Intensity | Key Tension |
|--------|-----------|-------------|
| Capital Scarcity | 2/5 ⬛⬛⬜⬜⬜ Low | Access easy; shareholder expectations high |
| Competition | 4/5 ⬛⬛⬛⬛⬜ High | Direct targeting, slot wars |
| Market Saturation | 4/5 ⬛⬛⬛⬛⬜ High | Good routes contested; expansion hard |
| Operational Complexity | 4/5 ⬛⬛⬛⬛⬜ High | Systemic interdependencies |

**Failure Possibility:**
- Strategic missteps in capital allocation (wrong fleet order)
- Alliance politics creating enemies
- Labor relations breakdown (strikes)
- Cascading operational failures exposing systemic weakness

**What Prevents "Solved" State:**
- Competitors have similar capabilities — differentiation is hard
- Shareholder expectations mean you can't just "coast"
- Organizational inertia resists rapid change
- Past decisions (fleet, alliances) constrain options

### 6.4 Chairman Phase (Hours 70+)

**Primary Challenge:** Shaping the industry while managing legacy.

| Vector | Intensity | Key Tension |
|--------|-----------|-------------|
| Capital Scarcity | 1/5 ⬛⬜⬜⬜⬜ Minimal | Capital is a tool, not constraint |
| Competition | 5/5 ⬛⬛⬛⬛⬛ Strategic | Industry-level rivalry |
| Market Saturation | 5/5 ⬛⬛⬛⬛⬛ Very High | Only major plays available |
| Operational Complexity | 5/5 ⬛⬛⬛⬛⬛ Systemic | Organization has its own momentum |

**Failure Possibility:**
- Strategic obsolescence (industry shifts you didn't anticipate)
- Succession failure (next generation unprepared)
- Regulatory changes undermining business model
- Acquisition by rival if vulnerable

**What Prevents "Solved" State:**
- Industry evolution creates new challenges
- Accumulated compromises create future obligations
- Legacy decisions constrain adaptation
- New technologies and competitors emerge

---

## 7. Failure Throughout the Game

### 7.1 Design Goal

Failure should be possible at every phase, but:
- The *type* of failure changes
- The *speed* of failure changes
- The *recovery options* change

### 7.2 Failure Modes by Phase

| Phase | Fast Failure | Slow Failure | Recovery Path |
|-------|--------------|--------------|---------------|
| Founder | Cash exhaustion (weeks) | Route losses accumulating | Angel/government rescue |
| Manager | Price war collapse (months) | Debt spiral | Restructuring, asset sales |
| Executive | Strike/grounding (months) | Market share erosion | Strategic pivot, M&A |
| Chairman | Regulatory action (varies) | Relevance decline | Succession, reinvention |

### 7.3 Failure Warning System

Players should never be surprised by failure. The game surfaces warnings:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  ⚠️ FINANCIAL HEALTH WARNING                                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Your debt service coverage ratio has fallen below 1.5x                    │
│                                                                             │
│  WHAT THIS MEANS                                                            │
│  You're generating barely enough to cover loan payments.                   │
│  If revenue drops 20%, you'll breach covenants.                            │
│                                                                             │
│  CAUSES                                                                     │
│  • Fuel costs up 35% (unhedged exposure)                                   │
│  • Paris-Madrid route losing €45K/month                                    │
│  • Fleet expansion financed at 12% APR                                     │
│                                                                             │
│  OPTIONS                                                                    │
│  ① Cut the Paris-Madrid route                    Stops bleeding           │
│  ② Sell 2 aircraft (reduces debt)               Shrinks capacity          │
│  ③ Raise ticket prices 10%                      Risk losing passengers    │
│  ④ Negotiate with lenders                       They may refuse           │
│                                                                             │
│  [Analyze options] [Dismiss warning] [Ask advisor]                         │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 7.4 Failure Recovery Mechanics

First-time failures have softer landings (on Easy/Normal difficulty):

| Failure Type | First Occurrence | Subsequent |
|--------------|------------------|------------|
| Bankruptcy | Government bridge loan offered | Game over or acquisition |
| Grounding | Emergency resolution, minor penalty | Extended grounding, reputation damage |
| Strike | Quick resolution, moderate cost | Prolonged strike, structural damage |
| Regulatory violation | Warning, small fine | Operating restrictions |

*Note: These mercy mechanics apply to Easy and Normal difficulty. On Hard, first-occurrence mercy is reduced. On Expert, there is no mercy — failure modes apply at full severity immediately.*

---

## 8. Preventing "Solved" States

### 8.1 What Creates "Solved" States

| Symptom | Cause | Risk |
|---------|-------|------|
| Optimal strategy obvious | Lack of trade-offs | High |
| Spreadsheet solutions | Full information, static environment | High |
| Set-and-forget profitable | No competitive response | Medium |
| Growth is always correct | No diseconomies of scale | Medium |

### 8.2 Anti-Solve Mechanics

| Mechanic | How It Works | Which Phase |
|----------|--------------|-------------|
| **Hidden demand variance** | Route demand has random component | All |
| **Competitor adaptation** | AI learns and responds to player patterns | Manager+ |
| **Covenant constraints** | Debt limits optimization freedom | Manager |
| **Executive variance** | Delegated decisions have personality factor | Manager+ |
| **Legacy obligations** | Past compromises create future constraints | Executive+ |
| **Market evolution** | Passenger preferences shift over time | All |
| **Technology disruption** | New aircraft types obsolete old strategies | Executive+ |
| **Regulatory shifts** | Rules change, requiring adaptation | Executive+ |
| **Random events** | Disruptions inject variance (see `world-events-spec.md`) | All |

*Random event frequency and types are defined in `world-events-spec.md`. Events should be tuned per difficulty setting — more frequent/severe on Hard, less on Easy.*

### 8.3 Difficulty Setting Modifiers

Players who want different challenge levels:

| Setting | Effect on Vectors |
|---------|-------------------|
| **Easy** | Capital +50%, Competition reaction -30%, Market saturation -20% |
| **Normal** | As specified in this document |
| **Hard** | Capital -25%, Competition reaction +30%, Random events +50% |
| **Historical** | Era-accurate parameters from economic-parameters.md |

---

## 9. Integration Points

### 9.1 Related Specifications

| Spec | Integration | Status |
|------|-------------|--------|
| `decision-density-spec.md` | Phase definitions, decision frequency | ✓ Committed |
| `economic-parameters.md` | Era-specific cost/revenue values | 📝 Draft |
| `route-economics-spec.md` | Route profitability calculations | 📝 Draft |
| `maintenance-spec.md` | Operational complexity mechanics | 📝 Draft |
| `crew-management-spec.md` | Crew complexity, labor relations | 📝 Draft |
| `world-events-spec.md` | Random events injecting variance (see Section 8.2) | 📝 Draft |
| `ai-competitors-spec.md` | Competition intensity mechanics | 📝 Draft |
| `governance-spec.md` | Shareholder/board pressure | 📝 Draft |

*Status key: ✓ Committed = in repo, 📝 Draft = exists locally but not yet committed/reviewed.*

### 9.2 Data Model Integration

Uses existing entities from `data-model.md`:

| Entity | Difficulty Role |
|--------|-----------------|
| `Loan.covenant_status` | Capital scarcity enforcement |
| `Loan.interest_rate` | Capital cost by phase |
| `Airline.stage` | Competitor attention trigger |
| `Slot.acquisition_method` | Market saturation mechanics |
| `FinancialPeriod.*` | Failure detection metrics |
| `Executive.performance_rating` | Operational variance |
| `Union.strike_risk` | Complexity/failure mode |
| `CEOPhase` enum | Phase-based difficulty scaling |

### 9.3 Suggested Data Model Additions

*The following enums are suggestions pending data model review. They should be evaluated for consistency with existing patterns before adding to `data-model.md`.*

```yaml
# Suggested: Categorize difficulty sources for analytics/tuning
DifficultyVector:
  CAPITAL_SCARCITY
  COMPETITION_INTENSITY
  MARKET_SATURATION
  OPERATIONAL_COMPLEXITY

# Suggested: Classify failure types for recovery mechanics
FailureMode:
  CASH_EXHAUSTION
  COVENANT_BREACH
  PRICE_WAR_COLLAPSE
  OPERATIONAL_GROUNDING
  LABOR_STRIKE
  REGULATORY_ACTION
  ACQUISITION_TARGET

# Suggested: Unified warning severity levels
WarningLevel:
  WATCH            # Something to monitor
  CONCERN          # Needs attention soon
  WARNING          # Requires action
  CRITICAL         # Immediate action required
```

*Note: These may overlap with or extend existing enums. Review before implementation.*

---

## 10. Tuning Guidelines

### 10.1 Playtest Metrics to Track

| Metric | Target Range | Too Low | Too High |
|--------|--------------|---------|----------|
| Time to first crisis | Hours 3-8 | Game feels easy | Game feels punishing |
| Bankruptcy rate (Founder) | 15-25% of runs | Capital too easy | Capital too scarce |
| Average phase duration | 80-120% of target hours | Progression too fast | Progression stalled |
| Recovery rate from crisis | 50-70% | Crises too hard | Crises too soft |
| "Set and forget" routes | <20% of portfolio | Competition too weak | Routes too volatile |

### 10.2 Phase Transition Checkpoints

Before advancing to next phase, player should have experienced:

| Transition | Required Experience |
|------------|---------------------|
| Founder → Manager | At least one route competition event |
| Manager → Executive | At least one financing challenge |
| Executive → Chairman | At least one systemic crisis |

### 10.3 Difficulty Tuning Levers

| Lever | Primary Effect | Tuning Range |
|-------|----------------|--------------|
| Starting cash | Founder survival time | ±50% |
| Interest rate spread | Capital scarcity pressure | ±3 percentage points |
| AI competitor attention threshold | When competition intensifies | ±30% of route count |
| Slot release rate | Market saturation timing | ±50% |
| Maintenance variance | Operational surprises | ±30% |
| Random event frequency | Overall volatility | ±50% |

---

## Document History

| Version | Date | Changes |
|---------|------|---------|
| 0.1 | January 2026 | Initial specification |
| 0.2 | January 2026 | Fixed spec status indicators. Added difficulty-dependent mercy mechanics note. Added numeric 1-5 scale backup for intensity bars. Clarified data model additions are suggestions pending review. Added explicit world-events-spec.md reference for random events. |
