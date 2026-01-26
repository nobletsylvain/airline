# Compromise & Obligation System — Detailed Specification

**Version:** 0.2  
**Date:** January 2026  
**Companion to:** GDD v0.7 Section 14 (The Compromise Engine), Appendix C  
**Addresses:** gameplay-concerns.md Section 9

---

## Overview

This document specifies how the obligation system surfaces to players — balancing the GDD's design intent (uncertainty creates tension) with the player experience concern (hidden debts feel unfair).

**Design Philosophy:** Players should feel the *weight* of obligations without being able to *optimize* around them. But "weight" requires awareness. The solution: players know *that* they owe, but not *when* or *exactly how* it will be called.

**Core Tension:**
- GDD intent: "No token count, no obligation list... tension builds from *not knowing*"
- Player concern: "Hidden debts may feel unfair ('where did this come from?')"
- Resolution: **Visible presence, invisible timing**

> **⚠️ Note on Numbers:** All frequency targets and thresholds in this document are *hypotheses*, not validated targets. They require prototype testing to confirm.

---

## 1. Visibility Philosophy

### 1.1 What Players Know vs. Don't Know

| Aspect | Player Visibility | Rationale |
|--------|-------------------|-----------|
| That an obligation exists | ✓ Visible | Prevents "surprise debt" feeling |
| Who they owe | ✓ Visible | Context for relationship |
| General nature of obligation | ✓ Visible | "Regional service commitment" |
| Exact terms | ⚠️ Vague | "Maintain reasonable service" vs precise requirements |
| When it will be called | ✗ Hidden | Creates anticipation/tension |
| Exact cost when called | ⚠️ Unknown until called | Prevents optimization |

### 1.2 The "Sword of Damocles" Principle

Obligations should feel like a sword hanging overhead — you know it's there, you know it could fall, but you don't know when. This is different from:

- **No visibility** (feels unfair, "where did this come from?")
- **Full visibility** (becomes spreadsheet optimization, tension disappears)

### 1.3 Visibility Levels by Game Phase

| Phase | Obligation Visibility | Rationale |
|-------|----------------------|-----------|
| Founder | Full details shown | Learning the system |
| Manager | General awareness | Understands concept, some ambiguity |
| Executive | Subtle indicators | Trusts player knows the system |
| Chairman | Strategic summary | Legacy view, not daily concern |

*Note: Founder-phase visibility functions as tutorial mode for the obligation system. See `tutorial-spec.md` and `FTUE_Endless_Mode.md` for how this integrates with progressive disclosure of game complexity.*

---

## 2. Obligation Lifecycle

*Reference: data-model.md `Obligation` entity, `ObligationStatus` enum*

### 2.1 Lifecycle Stages

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  OBLIGATION LIFECYCLE                                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   CREATION         DORMANT           CALLED           RESOLUTION           │
│   ─────────       ─────────         ────────         ────────────          │
│                                                                             │
│   ┌───────┐       ┌───────┐        ┌───────┐        ┌───────────┐         │
│   │Crisis │──────→│ Owed  │───────→│Request│───────→│ Honored   │         │
│   │ Deal  │       │       │        │Arrives│        │ Partial   │         │
│   └───────┘       └───────┘        └───────┘        │ Refused   │         │
│       │               │                │            │ Expired   │         │
│       │               │                │            └───────────┘         │
│       ▼               ▼                ▼                   │              │
│   Player sees:    Player sees:     Player sees:       Consequences:      │
│   "You owe the    Periodic          Full request      Relationship       │
│   Ministry..."    reminders         and options       impact             │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2.2 Stage Details

#### Stage 1: Creation

When a compromise creates an obligation:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  OBLIGATION CREATED                                                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  You accepted the Ministry's loan guarantee.                               │
│                                                                             │
│  AN UNDERSTANDING NOW EXISTS                                                │
│                                                                             │
│  Creditor: Ministry of Transport                                           │
│  Nature: Regional service commitment                                       │
│  Origin: Government loan guarantee (March 2025)                            │
│                                                                             │
│  What this means:                                                          │
│  The Ministry expects continued service to underserved regions.            │
│  Exact terms were not specified. They rarely are.                          │
│                                                                             │
│  When will they call?                                                      │
│  Unknown. When they need something. Could be months or years.              │
│                                                                             │
│  ⚠ This obligation is now tracked. You will be reminded periodically.     │
│                                                                             │
│  [I understand] [Tell me more about obligations]                           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Stage 2: Dormant Period

While outstanding, obligations appear in the Obligations Ledger (Section 4) and generate periodic awareness signals:

| Signal Type | Frequency | Example |
|-------------|-----------|---------|
| Ledger presence | Always visible | Listed in obligations view |
| Status indicator | On relevant screens | Icon near Ministry relationship |
| Ambient reminder | Every 3-6 months (game time) | "The Ministry noted your expansion plans..." |
| Tension escalation | If context changes | "Elections approaching. Regional policy under review." |

#### Stage 3: Called

When the creditor invokes the obligation:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  ⚡ OBLIGATION CALLED · Ministry of Transport                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  "The regional development committee meets next month.                     │
│  The Lyon-Aurillac service has been... noted.                              │
│  We trust the 2019 arrangement remains understood."                        │
│                                                                             │
│  CONTEXT                                                                    │
│  Origin: Government loan guarantee (March 2019)                            │
│  Understanding: Maintain regional service                                  │
│  Time outstanding: 3 years, 7 months                                       │
│                                                                             │
│  THEIR REQUEST                                                              │
│  Continue Lyon-Aurillac service at current frequency (2x daily)            │
│  Route profitability: -$12K/month                                          │
│                                                                             │
│  YOUR OPTIONS                                                               │
│                                                                             │
│  [Honor fully]        Maintain current service                             │
│                       Cost: -$144K/year                                    │
│                       Relationship: Strong positive                        │
│                       Future: Likely more favorable treatment              │
│                                                                             │
│  [Partial compliance] Reduce to 1x daily                                   │
│                       Cost: -$72K/year                                     │
│                       Relationship: Strained but intact                    │
│                       Future: Noted as "difficult partner"                 │
│                                                                             │
│  [Refuse]             Discontinue the route                                │
│                       Cost: None immediate                                 │
│                       Relationship: Severely damaged                       │
│                       Future: Regulatory scrutiny likely                   │
│                                                                             │
│  [Negotiate]          Propose alternative (new route? subsidy?)            │
│                       Outcome: Uncertain, depends on offer                 │
│                                                                             │
│  ⚠ The Minister has a long memory.                                        │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Stage 4: Resolution

After player responds, the obligation resolves:

| Response | Status | Relationship Impact | Future Effect |
|----------|--------|---------------------|---------------|
| Honored | HONORED | +20 to +50 | Future favors possible, goodwill bank |
| Partial | HONORED (partial) | -10 to +10 | Noted as "minimum compliance" |
| Refused | BROKEN | -30 to -80 | Future dealings harder, possible retaliation |
| Negotiated | Varies | Depends on offer | New obligation may form |
| Expired | EXPIRED | Neutral | Rare — most don't expire |

---

## 3. Frequency Targets

### 3.1 How Many Active Obligations?

*Hypothesis: These numbers require playtesting.*

| Phase | Target Active Obligations | Too Few | Too Many |
|-------|--------------------------|---------|----------|
| Founder | 0-2 | Not learning system | Overwhelmed |
| Manager | 2-4 | No weight | Debt spiral feeling |
| Executive | 3-6 | Empire feels consequence-free | Micromanagement |
| Chairman | 4-8 | Legacy has no weight | Lost in noise |

### 3.2 Call Frequency

*How often are obligations invoked?*

| Phase | Calls per Year (game time) | Rationale |
|-------|---------------------------|-----------|
| Founder | 0-1 | Time to establish before calls |
| Manager | 1-2 | Feeling consequences of early deals |
| Executive | 2-3 | Past catching up, but manageable |
| Chairman | 1-2 | Focus on legacy, not daily debt |

### 3.3 Creation Rate Limits

To prevent "obligation spam":

| Mechanic | Limit | Purpose |
|----------|-------|---------|
| Max simultaneous obligations | 10 | Prevent overwhelm |
| Same creditor cooldown | 12 months after resolution | Variety |
| Major obligation limit | 3 active | Keep stakes high |
| Auto-expiration | After 10 years uncalled | Prevent infinite accumulation |

---

## 4. The Obligations Ledger

A dedicated view showing all outstanding obligations. This is the primary visibility mechanism.

### 4.1 Ledger UI

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  OBLIGATIONS LEDGER · What You Owe                                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Active obligations: 4                                                     │
│  Resolved this year: 2 (1 honored, 1 partial)                              │
│                                                                             │
│  ──────────────────────────────────────────────────────────────────────────│
│                                                                             │
│  ⬤ MINISTRY OF TRANSPORT                                      Since 2019  │
│    Understanding: Regional service commitment                              │
│    Origin: Government loan guarantee                                       │
│    Status: Outstanding │ 3 years, 7 months                                │
│    [View details]                                                          │
│                                                                             │
│  ⬤ ALTITUDE PARTNERS (Investor)                                Since 2021  │
│    Understanding: Growth trajectory expectations                           │
│    Origin: Series A investment                                             │
│    Status: Outstanding │ 1 year, 2 months                                 │
│    [View details]                                                          │
│                                                                             │
│  ⬤ PILOTS UNION LOCAL 442                                      Since 2022  │
│    Understanding: Scheduling flexibility in exchange for pay freeze        │
│    Origin: Contract negotiation                                            │
│    Status: Outstanding │ 8 months                                         │
│    [View details]                                                          │
│                                                                             │
│  ⬤ SKYLEASING (Lessor)                                         Since 2020  │
│    Understanding: First right of refusal on new orders                     │
│    Origin: Favorable lease terms on A320                                   │
│    Status: Outstanding │ 2 years, 4 months                                │
│    [View details]                                                          │
│                                                                             │
│  ──────────────────────────────────────────────────────────────────────────│
│                                                                             │
│  RECENTLY RESOLVED                                                          │
│                                                                             │
│  ✓ REGIONAL DEVELOPMENT FUND                              Resolved Apr 2022│
│    Was: Employment commitment in Lyon │ Honored fully                      │
│    Outcome: +35 relationship, future funding unlocked                      │
│                                                                             │
│  ◐ EUROBANK                                               Resolved Jan 2022│
│    Was: Early payment terms │ Partial compliance                          │
│    Outcome: -10 relationship, loan still active                           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.2 Obligation Detail View

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  OBLIGATION DETAIL · Ministry of Transport                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  CREDITOR                                                                   │
│  Name: Ministry of Transport                                               │
│  Type: Government                                                          │
│  Current relationship: 62/100 (Cooperative)                                │
│                                                                             │
│  ORIGIN                                                                     │
│  Event: Government loan guarantee                                          │
│  Date: March 2019                                                          │
│  Context: Cash crisis, bank refused extension                              │
│  You received: $15M loan guarantee, favorable terms                        │
│                                                                             │
│  THE UNDERSTANDING                                                          │
│  Explicit terms: None documented                                           │
│  Implicit understanding: "Maintain service to underserved regions"         │
│                                                                             │
│  Nothing was signed. But something was understood.                         │
│                                                                             │
│  CURRENT STATUS                                                             │
│  Status: Outstanding                                                       │
│  Time since origin: 3 years, 7 months                                      │
│  Indicators: No recent signals                                             │
│                                                                             │
│  WHAT MIGHT HAPPEN                                                          │
│  The Ministry may request:                                                 │
│  - Continued regional service                                              │
│  - New route to underserved destination                                    │
│  - Public statements supporting regional policy                            │
│                                                                             │
│  When: Unknown. When they need something.                                  │
│                                                                             │
│  [Close] [View relationship history] [View related routes]                 │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 5. Surfacing Mechanisms

### 5.1 Where Obligations Appear

| Location | What Shows | When |
|----------|------------|------|
| Dashboard widget | Count and oldest | Always (if any exist) |
| Relationship panels | Indicator icon | When viewing relevant stakeholder |
| Fleet/route details | Origin note | If acquired under obligation |
| Timeline view | Creation events | When reviewing history |
| Decision prompts | Relevant obligations | When making related decisions |

### 5.2 Dashboard Widget

```
┌───────────────────────────────────┐
│  OBLIGATIONS · 4 outstanding      │
├───────────────────────────────────┤
│  Oldest: Ministry (3y 7m)         │
│  Most recent: Union (8m)          │
│                                   │
│  No calls pending                 │
│  [View ledger]                    │
└───────────────────────────────────┘
```

### 5.3 Contextual Indicators

When obligations are relevant to current decisions:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  ROUTE PLANNING · Lyon Regional Network                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Lyon → Aurillac                                                           │
│  Profit: -$12K/month                                                       │
│                                                                             │
│  ⚠ OBLIGATION CONTEXT                                                      │
│  This route relates to an outstanding obligation:                          │
│  - Ministry of Transport (regional service commitment)                     │
│  - Origin: 2019 loan guarantee                                             │
│  - Discontinuing may trigger a call                                        │
│                                                                             │
│  [Continue planning] [View obligation details]                             │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 5.4 Ambient Reminders

Periodic non-urgent signals that obligations exist:

| Trigger | Message Type | Example |
|---------|--------------|---------|
| Random (every 3-6 months) | Subtle mention | "Ministry official tours regional airports..." |
| Creditor in news | Contextual | "Altitude Partners announces new fund..." |
| Related decision | Warning | "This affects your SkyLeasing obligation" |
| Anniversary | Reflection | "Two years since the government loan..." |

---

## 6. Preventing "Hidden Debt" Feeling

### 6.1 The Unfairness Problem

Players feel cheated when:
- Obligation appears they don't remember creating
- Terms seem different from what they agreed to
- They had no warning before being called

### 6.2 Prevention Mechanisms

| Mechanism | Purpose | Implementation |
|-----------|---------|----------------|
| **Creation confirmation** | Ensure player knows an obligation formed | Explicit dialog when creating |
| **Origin recall** | Remind player of context when called | Show original decision in call dialog |
| **Ledger access** | Allow proactive review | Always-accessible obligations view |
| **Predictable types** | No "gotcha" obligation sources | Limited creation contexts |
| **Fair calling** | Calls should feel reasonable | AI follows plausible motivations |

### 6.3 Obligation Creation Contexts

Obligations can *only* form in these situations:

| Context | Creditor Type | Example |
|---------|---------------|---------|
| Government support | Government | Loan guarantee, subsidy, slot allocation |
| Investor funding | Investor | Equity investment, debt injection |
| Union negotiation | Union | Contract concession, pay deal |
| Supplier deal | Lessor/Supplier | Favorable terms in exchange for commitment |
| Competitor arrangement | Competitor | Codeshare, route agreement |
| Community commitment | Local government | Hub development, employment pledge |

If a player gets an obligation call, they should be able to trace it to one of these origin types.

---

## 7. Can Players Be "Free" of Past Compromises?

### 7.1 Design Decision: Burden Can Decrease, But History Remains

Obligations can be resolved, but the *memory* of compromises persists:

| Aspect | Can Be Cleared? | How |
|--------|-----------------|-----|
| Active obligations | Yes | Resolution (honored, broken, expired) |
| Relationship effects | Partially | Time + positive actions |
| Historical record | No | Permanently logged in timeline |
| Legacy score impact | No | Already factored in |

### 7.2 "Clean Slate" Pathway

For players who want to reduce obligation burden:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  OBLIGATION MANAGEMENT · Strategic Options                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Current burden: 6 active obligations                                      │
│                                                                             │
│  OPTIONS TO REDUCE                                                          │
│                                                                             │
│  ▸ Proactive resolution                                                    │
│    Approach creditors to resolve before they call                          │
│    Some may accept early resolution at premium cost                        │
│    [Review proactive options]                                              │
│                                                                             │
│  ▸ Relationship investment                                                 │
│    Strong relationships reduce call likelihood                             │
│    Some creditors may "forget" if relationship is excellent                │
│    [View relationship priorities]                                          │
│                                                                             │
│  ▸ Wait for expiration                                                     │
│    Old obligations (10+ years) may expire without call                     │
│    Not guaranteed — some creditors have long memories                      │
│    Oldest: Ministry of Transport (3y 7m — not yet eligible)               │
│                                                                             │
│  ▸ Accept the burden                                                       │
│    Obligations are the price of your history                               │
│    Successful resolution builds goodwill                                   │
│    "Those who forget history are doomed to repeat it"                      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 7.3 Proactive Resolution

Players can attempt to clear obligations before being called:

| Proactive Approach | Cost | Success Rate | Effect if Successful |
|-------------------|------|--------------|---------------------|
| Early fulfillment | 1.5x standard cost | High | Obligation cleared, +relationship |
| Buyout offer | Variable | Medium | May accept cash settlement |
| Relationship upgrade | Time + investment | Medium | May "forget" the debt |
| Renegotiation | Political capital | Low | New terms, new obligation |

---

## 8. Obligation as Decision Source

*Reference: decision-density-spec.md*

Obligations generate decisions, contributing to decision density:

| Phase | Obligation Decisions/Session | Type |
|-------|------------------------------|------|
| Founder | 0-1 | Reactive (when called) |
| Manager | 1-2 | Reactive + proactive management |
| Executive | 1-2 | Strategic obligation planning |
| Chairman | 0-1 | Legacy burden management |

---

## 9. Obligation as Difficulty Source

*Reference: difficulty-curve-spec.md Section 8.2*

Obligations contribute to the "Legacy obligations" anti-solve mechanic:

| How Obligations Create Difficulty |
|----------------------------------|
| Limit optimization (can't just maximize profit if you owe service) |
| Create timing constraints (creditor may call at inconvenient moment) |
| Force trade-offs (honoring vs. breaking) |
| Connect past to present (early decisions have late consequences) |

---

## 10. Integration Points

### 10.1 Related Specifications

| Spec | Integration | Status |
|------|-------------|--------|
| `decision-density-spec.md` | Obligations as decision source | ✓ Committed |
| `difficulty-curve-spec.md` | Legacy obligations as difficulty vector | ✓ Committed |
| `governance-spec.md` | Investor/board obligations | 📝 Draft |
| `world-events-spec.md` | Events can trigger obligation calls | 📝 Draft |
| `endgame-content-spec.md` | Legacy burden in Chairman phase | ✓ Committed |

*Status key: ✓ Committed = in repo, 📝 Draft = exists locally but not yet committed/reviewed.*

### 10.2 Data Model Integration

Uses existing entities from `data-model.md`:

| Entity | Usage |
|--------|-------|
| `Compromise` | Origin events for obligations |
| `Obligation` | Core tracking entity |
| `ObligationStatus` enum | Lifecycle states |
| `ObligationCreditorType` enum | Creditor categories |
| `ObligationResponse` enum | Player response types |

### 10.3 Suggested Data Model Additions

*Suggestions pending data model review:*

```yaml
# Tracking obligation visibility state
ObligationVisibility:
  FULL              # Founder phase — all details shown
  STANDARD          # Manager phase — general awareness
  SUBTLE            # Executive phase — indicator only
  SUMMARY           # Chairman phase — legacy view

# Proactive resolution tracking
ProactiveResolutionAttempt:
  obligation_id: FK → Obligation
  attempt_date: date
  approach: enum  # EARLY_FULFILLMENT / BUYOUT / RELATIONSHIP / RENEGOTIATION
  cost_offered: decimal?
  outcome: enum  # ACCEPTED / REJECTED / COUNTER_OFFER
  notes: string?
```

---

## 11. Tuning Guidelines

### 11.1 Playtest Metrics to Track

| Metric | Target Range | Too Low | Too High |
|--------|--------------|---------|----------|
| "Surprise obligation" complaints | <10% of calls | — | Visibility failing |
| Active obligations (avg) | 3-5 | No weight | Overwhelmed |
| Call response time | <30 seconds | Too simple | Too complex |
| Honor rate | 40-60% | Too easy to break | Too punishing to refuse |
| Proactive resolution rate | 10-20% | Players don't engage | System too manageable |

### 11.2 Balance Levers

| Lever | Effect | Range |
|-------|--------|-------|
| Call frequency | More/less obligation pressure | 0.5x - 2x |
| Call timing variance | Predictability | 3-24 months after creation |
| Honor cost multiplier | Economic impact | 0.5x - 2x |
| Relationship impact multiplier | Social consequences | 0.5x - 2x |
| Auto-expiration threshold | Burden accumulation | 5-15 years |

---

## Document History

| Version | Date | Changes |
|---------|------|---------|
| 0.1 | January 2026 | Initial specification |
| 0.2 | January 2026 | Added FTUE/tutorial-spec.md reference for Founder-phase visibility as tutorial mode. |
