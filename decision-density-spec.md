# Decision Density — Detailed Specification

**Version:** 0.3  
**Date:** January 2026  
**Companion to:** GDD v0.7, Executive Delegation Spec, Tutorial Spec  
**Addresses:** gameplay-concerns.md Section 3

---

## Overview

This document specifies target decision density across game phases — ensuring players always have meaningful choices without overwhelming them or letting the game become passive.

**Design Philosophy:** Decisions should feel earned, not manufactured. The goal isn't more decisions, it's more *meaningful* decisions per unit of player attention. As the airline grows, decision scope expands (fleet-wide vs per-route) but frequency adjusts to prevent fatigue.

**Core Problem:** 
- Early game: Too few decisions (one plane, one route = set and forget)
- Mid game: Waiting periods with nothing to do
- Late game: Delegation removes agency; becomes a spreadsheet

> **⚠️ Note on Numbers:** All decision density targets in this document are *hypotheses*, not validated targets. They represent design intent and require prototype testing to confirm. Expect significant tuning during playtesting.

---

## 1. Game Phases

*Aligned with GDD v0.7 CEO Evolution and data-model.md GamePhase enum.*

### 1.1 Phase Definitions

| Phase | Fleet Size | Route Count | Typical Revenue | Playtime |
|-------|------------|-------------|-----------------|----------|
| **Founder** | 1-5 aircraft | 1-10 routes | <$10M/year | Hours 0-10 |
| **Manager** | 6-15 aircraft | 11-30 routes | $10-50M/year | Hours 10-30 |
| **Executive** | 16-40 aircraft | 31-80 routes | $50-250M/year | Hours 30-70 |
| **Chairman** | 40+ aircraft | 80+ routes | >$250M/year | Hours 70+ |

### 1.2 Phase Transitions

Phase advancement requires both **quantity thresholds** (fleet/routes) AND **quality gates** (viability checks). This prevents exploiting progression by scaling quantity without building a sustainable airline.

*Reference: Edge-Case Report 3 (Speedrunner) identified that pure quantity thresholds could be gamed.*

> **⚠️ Note:** All threshold values are hypotheses requiring playtesting.

#### Founder → Manager Transition

| Requirement | Threshold | Rationale |
|-------------|-----------|-----------|
| **Fleet size** | 6+ aircraft | Quantity gate |
| **Route count** | 10+ routes | Quantity gate |
| **Profitable routes** | ≥60% of routes profitable | Can't advance on bleeding money |
| **Cash runway** | 3+ months at current burn | Financial stability |

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  PHASE TRANSITION · Founder → Manager                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  READINESS CHECK                                                            │
│  ✓ Fleet size: 8 aircraft (need 6)                                         │
│  ✓ Route count: 12 routes (need 10)                                        │
│  ✓ Route profitability: 75% profitable (need 60%)                          │
│  ✓ Cash runway: 5.2 months (need 3)                                        │
│                                                                             │
│  You're ready to become a Manager.                                         │
│                                                                             │
│  WHAT CHANGES                                                               │
│  • COO position unlocks — delegate scheduling and maintenance              │
│  • Fleet-wide views become primary (not per-aircraft)                      │
│  • Route groups replace individual route management                        │
│  • Strategic decisions start to outweigh tactical ones                     │
│                                                                             │
│  Your job is shifting from "do everything" to "decide what matters."       │
│                                                                             │
│  [Continue] [What should I delegate first?]                                │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Manager → Executive Transition

| Requirement | Threshold | Rationale |
|-------------|-----------|-----------|
| **Fleet size** | 16+ aircraft | Quantity gate |
| **Route count** | 30+ routes | Quantity gate |
| **Operating margin** | ≥5% trailing 12 months | Sustainable profitability |
| **Debt service coverage** | ≥1.25x | Can handle financial obligations |

#### Executive → Chairman Transition

| Requirement | Threshold | Rationale |
|-------------|-----------|-----------|
| **Fleet size** | 40+ aircraft | Quantity gate |
| **Route count** | 80+ routes | Quantity gate |
| **Operating margin** | ≥8% trailing 12 months | Proven business model |
| **Successful delegation** | 3+ functions at Level 3+ | Organization can run without you |

#### Quality Gate Philosophy

These gates should feel like **natural readiness checks**, not arbitrary blockers:

| Principle | Implementation |
|-----------|----------------|
| Gates reflect real airline viability | Metrics match what real boards would assess |
| Failing gates provides guidance | UI shows what to fix, not just "not ready" |
| Near-miss flexibility | Within 10% of threshold + strong in other areas = may still transition |
| No grinding treadmill | Once passed, gates don't need to be maintained |

#### Transition Blocked UI

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  PHASE TRANSITION · Manager → Executive                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  READINESS CHECK                                                            │
│  ✓ Fleet size: 18 aircraft (need 16)                                       │
│  ✓ Route count: 34 routes (need 30)                                        │
│  ✗ Operating margin: 3.2% (need 5%)                                        │
│  ✓ Debt service coverage: 1.4x (need 1.25x)                                │
│                                                                             │
│  Not quite ready. Your margins need work.                                  │
│                                                                             │
│  WHY THIS MATTERS                                                           │
│  Executive phase brings shareholder scrutiny and board expectations.       │
│  At 3.2% margin, you'd face immediate pressure to cut or restructure.     │
│  Build a sustainable foundation first.                                     │
│                                                                             │
│  SUGGESTIONS                                                                │
│  • Review unprofitable routes (you have 8)                                 │
│  • Optimize pricing on high-volume routes                                  │
│  • Renegotiate supplier contracts                                          │
│                                                                             │
│  [Review routes] [View finances] [Dismiss]                                 │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Decision Categories

### 2.1 Decision Types

| Type | Examples | Cognitive Load | Time Sensitivity |
|------|----------|----------------|------------------|
| **Strategic** | Enter new market, order aircraft type | High | Low |
| **Tactical** | Set route pricing, adjust schedule | Medium | Medium |
| **Operational** | Handle disruption, approve exception | Low | High |
| **Reactive** | Respond to competitor, event, crisis | Variable | High |

### 2.2 Decision Quality Spectrum

| Quality | Characteristics | Player Feel |
|---------|-----------------|-------------|
| **Meaningful** | Clear trade-offs, lasting consequences | Engaged |
| **Interesting** | No obvious answer, invites thought | Curious |
| **Routine** | Right answer is known, just execution | Efficient |
| **Trivial** | No real impact, busywork | Annoyed |

**Target:** 80% meaningful/interesting, 20% routine, 0% trivial

---

## 3. Density Targets by Phase

### 3.1 Founder Phase (1-5 aircraft)

**Player Identity:** You ARE the airline. Every flight matters.

| Metric | Hypothesis | Rationale |
|--------|------------|-----------|
| Decisions per 30 min | 8-12 | High engagement, learning curve |
| Strategic decisions/session | 1-2 | Route selection, aircraft acquisition |
| Tactical decisions/session | 4-6 | Pricing, scheduling, capacity |
| Operational decisions/session | 2-4 | Small problems feel big |
| Max idle time | 2 minutes | Always something to do |

*Note: These numbers are hypotheses requiring prototype validation.*

**Decision Sources:**

| Source | Decisions/Week (game time) | Examples |
|--------|---------------------------|----------|
| Route management | 3-5 | Adjust price, change frequency, add connection |
| Fleet decisions | 1-2 | Lease vs buy, which type, when |
| Competition response | 1-3 | Price match, differentiate, ignore |
| Cash management | 1-2 | Take loan, defer purchase, cut costs |
| Disruptions | 1-2 | Weather delay, maintenance issue |

**Founder Phase Decision Density Map:**

```
Week 1:  [Route1][Price][Route2][Aircraft?][Crisis!][Adjust][Compete]
Week 2:  [Route3][Price][Price][Finance][Hub?][Adjust][Event]
Week 3:  [Route4][Aircraft][Price][Compete][Adjust][Strategy]
         ↑        ↑        ↑      ↑         ↑        ↑
         Always something requiring attention
```

### 3.2 Manager Phase (6-15 aircraft)

**Player Identity:** You're building a system. Delegate the obvious, focus on the strategic.

| Metric | Hypothesis | Rationale |
|--------|------------|-----------|
| Decisions per 30 min | 5-8 | Fewer but larger decisions |
| Strategic decisions/session | 2-3 | Markets, fleet strategy, alliances |
| Tactical decisions/session | 2-3 | Portfolio adjustments, not per-route |
| Operational decisions/session | 1-2 | Only exceptions surface |
| Max idle time | 5 minutes | Acceptable if watching results |

*Note: These numbers are hypotheses requiring prototype validation.*

**Decision Sources:**

| Source | Decisions/Week | Examples |
|--------|----------------|----------|
| Network strategy | 2-3 | Hub development, market entry/exit |
| Fleet planning | 1-2 | Type strategy, order timing |
| Executive management | 1-2 | Hire, delegate, adjust policies |
| Competitive positioning | 1-2 | Alliance, price war, differentiation |
| Policy exceptions | 2-3 | Approve deviations, adjust rules |
| Growth investments | 1 | Facilities, lounges, technology |

**Manager Phase Decision Scope Shift:**

```
FOUNDER: "Should I add a 6th flight to Lyon-Marseille?"
         ↓ (scope expands)
MANAGER: "Should I develop Lyon as a secondary hub?"
         ↓ (decisions aggregate)
         Individual route decisions → delegated to CCO
         You approve pricing POLICY, not individual prices
```

### 3.3 Executive Phase (16-40 aircraft)

**Player Identity:** You're the strategist. Set direction, manage exceptions, shape the future.

| Metric | Hypothesis | Rationale |
|--------|------------|-----------|
| Decisions per 30 min | 3-5 | High-impact, considered choices |
| Strategic decisions/session | 2-4 | Major initiatives, M&A, restructuring |
| Tactical decisions/session | 1-2 | Macro adjustments, portfolio |
| Operational decisions/session | 0-1 | Only crises reach you |
| Max idle time | 10 minutes | But with meaningful observation |

*Note: These numbers are hypotheses requiring prototype validation.*

**Decision Sources:**

| Source | Decisions/Week | Examples |
|--------|----------------|----------|
| Corporate strategy | 1-2 | New regions, vertical integration |
| M&A/Alliances | 0-1 | Acquire competitor, join alliance |
| Executive team | 1-2 | Key hires, performance, succession |
| Capital allocation | 1 | Major fleet orders, dividends |
| Crisis management | 0-1 | Market shocks, regulatory changes |
| Legacy/Identity | 1 | Brand positioning, long-term vision |

**Executive Phase Anti-Boredom Mechanics:**

```
IF (player_idle > 5 minutes AND nothing_delegated)
    THEN surface "CEO Briefing" with strategic options
    
IF (player_has_no_decisions AND game_speed_normal)
    THEN suggest "Your executives are handling things. 
         Want to review performance, accelerate time, 
         or explore new opportunities?"
```

### 3.4 Chairman Phase (40+ aircraft)

**Player Identity:** You've built an empire. Now shape the industry.

| Metric | Hypothesis | Rationale |
|--------|------------|-----------|
| Decisions per 30 min | 1-3 | Rare but consequential choices |
| Strategic decisions/session | 1-2 | Industry positioning, legacy |
| Tactical decisions/session | 0-1 | Only major portfolio shifts |
| Operational decisions/session | 0 | Everything delegated |
| Max idle time | 15 minutes | Observation mode is valid gameplay |

*Note: These numbers are hypotheses requiring prototype validation.*

**Decision Sources:**

| Source | Decisions/Week | Examples |
|--------|----------------|----------|
| Industry shaping | 0-1 | Alliance leadership, regulatory influence |
| Succession planning | 0-1 | Groom next CEO, board composition |
| Major M&A | 0-1 | Mergers, hostile takeovers, spinoffs |
| Legacy decisions | 0-1 | Sustainability initiatives, brand identity |
| Crisis intervention | 0-1 | Step in when executives fail |
| What-if exploration | Variable | Scenario planning, strategic experiments |

**Chairman Phase Design Challenge:**

The risk at this phase is the game becoming purely passive observation. Mitigation strategies:

1. **Consequence amplification** — Chairman decisions have industry-wide ripples
2. **Legacy tracking** — Player's history creates obligations and opportunities
3. **Competitive endgame** — Other airlines reaching similar scale create rivalry
4. **Scenario unlocks** — Historical "what if" challenges become available
5. **New game+ elements** — Restart with advantages, try different strategies

---

## 4. Preventing Dead Time

### 4.1 The "Nothing to Do" Problem

| Phase | Dead Time Risk | Mitigation |
|-------|----------------|------------|
| Founder | Waiting for first revenue | Guided first route, quick wins |
| Early Manager | Stable routes, no growth capital | Competitor moves, random events |
| Late Manager | Delegation in place, watching | Strategic options surface |
| Executive | Everything running smoothly | High-level challenges emerge |
| Chairman | Empire on autopilot | Industry-shaping opportunities, legacy goals |

### 4.2 Decision Injection Systems

When player has no pending decisions, inject from:

**Priority 1: Organic Decisions**
- Competitor action requiring response
- Market shift (demand change, fuel spike)
- Internal event (maintenance issue, crew problem)

**Priority 2: Opportunity Decisions**
- "New route opportunity detected" (with time limit)
- "Aircraft available at discount" (broker deal)
- "Codeshare offer from [Airline]"

**Priority 3: Strategic Prompts**
- "Your Lyon hub is underperforming vs potential"
- "3 routes haven't been reviewed in 6 months"
- "Executive suggests discussing fleet renewal"

**Priority 4: Meta Decisions**
- "Want to accelerate time to next event?"
- "Review performance dashboard?"
- "Explore what-if scenarios?"

### 4.3 Decision Queue UI

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  DECISIONS PENDING                                                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ⚡ URGENT (2)                                                              │
│  • EuroSky undercut Paris-Madrid by 30% — respond?                         │
│  • A320 #LN-SKY due for C-check, slot available next week                  │
│                                                                             │
│  📋 THIS WEEK (3)                                                           │
│  • Q3 executive reviews due                                                │
│  • Fuel hedging contracts expiring                                         │
│  • Expansion opportunity: Prague hub                                        │
│                                                                             │
│  💡 WHEN YOU HAVE TIME (5)                                                  │
│  • Review underperforming routes (3)                                       │
│  • New aircraft evaluation                                                 │
│  • Alliance partnership proposal                                           │
│                                                                             │
│  Delegation filter: [Show all] [Only exceptions] [Strategic only]          │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 5. Delegation Without Disconnection

### 5.1 The Delegation Paradox

**Problem:** Delegation removes decisions, but decisions are engagement.

**Solution:** Delegation changes decision *type*, not total engagement.

| Without Delegation | With Delegation |
|--------------------|-----------------|
| Set each route's price | Set pricing policy |
| Approve each hire | Set hiring standards, review outcomes |
| Handle each delay | Set disruption response policy |
| Check each aircraft | Review fleet performance |

### 5.2 Delegation Creates New Decisions

| Delegated Task | New Decisions Created |
|----------------|----------------------|
| Route pricing | Policy design, exception handling, performance review |
| Maintenance scheduling | Standards setting, vendor selection, budget allocation |
| Crew rostering | Work rules, training priorities, labor relations |
| Competitive response | Strategy definition, guardrails, crisis escalation |

### 5.3 Exception Surfacing

Delegated functions surface exceptions for player decision:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  ⚠ EXCEPTION · From CCO Sophie Martinez                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  SITUATION                                                                  │
│  Nordic Air started aggressive pricing on our Stockholm routes.            │
│  Under current policy, I would match within 5%.                            │
│                                                                             │
│  COMPLICATION                                                               │
│  Matching puts us below our 15% margin floor on 3 routes.                  │
│  Policy conflict: "Match competitors" vs "Maintain margin floor"           │
│                                                                             │
│  MY RECOMMENDATION                                                          │
│  Match on the 2 high-volume routes, exit the 1 marginal route.             │
│  Net impact: -€40K monthly, but protects core position.                    │
│                                                                             │
│  [Approve recommendation] [Match all] [Hold prices] [Let's discuss]        │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 6. Scaling Decision Scope

### 6.1 From Micro to Macro

| Founder | Manager | Executive | Chairman |
|---------|---------|-----------|----------|
| "Add flight?" | "Develop route group?" | "Enter region?" | "Shape industry?" |
| "What price?" | "What pricing strategy?" | "What market positioning?" | "What brand legacy?" |
| "Which aircraft?" | "What fleet mix?" | "What fleet identity?" | "What manufacturing deal?" |
| "Handle delay" | "Set delay policy" | "Approve ops philosophy" | "Set industry standards?" |

### 6.2 Decision Aggregation

Individual decisions aggregate into policy decisions:

```
MICRO LEVEL (Founder)
├── LYS-MRS: Price €89
├── LYS-NCE: Price €95  
├── LYS-TLS: Price €72
│
AGGREGATE VIEW (Manager)
├── Short-haul leisure: Target 75% load @ €85-95 avg
│   └── 12 routes following this strategy
│
POLICY LEVEL (Executive)  
├── Commercial positioning: "Affordable quality"
│   └── CCO manages all pricing within this framework
│   └── Exception: Alert if any route falls below 60% load
```

### 6.3 Zoom Levels

Player can always zoom in or out:

| Zoom | View | Decisions Available |
|------|------|---------------------|
| Network | All routes, fleet | Strategic positioning |
| Region | Group of routes | Tactical portfolio |
| Route | Individual route | Detailed tuning |
| Flight | Specific flight | Micro-adjustment (rare) |

---

## 7. Anti-Spreadsheet Measures

### 7.1 The Spreadsheet Problem

**Risk:** Game becomes pure optimization with calculable right answers.

**Symptoms:**
- Players use external tools to solve
- One strategy dominates
- Decisions feel like data entry

### 7.2 Preventing Spreadsheet Syndrome

| Mechanism | How It Works |
|-----------|--------------|
| **Hidden variables** | Competitor behavior not fully predictable |
| **Soft factors** | Brand, reputation, relationships affect outcomes |
| **Timing uncertainty** | Right decision at wrong time still fails |
| **Cascading effects** | Decisions interact non-linearly |
| **Personality influence** | Executives interpret policies differently |
| **Random events** | Disruption prevents pure optimization |

### 7.3 Interesting vs Optimal

Not every decision has an optimal answer:

```
DILEMMA: Nordic Air offers codeshare on your Stockholm route

OPTION A: Accept
+ Additional feed traffic (~800 pax/month)  
+ Revenue share income
- Nordic now has access to your schedule data
- Your brand diluted on these flights
- Harder to compete with them later

OPTION B: Reject
+ Maintain independence and brand clarity
+ Full control of route strategy
- Miss feed traffic
- Nordic may partner with EuroSky instead

Neither is "right." Depends on your strategy.
```

---

## 8. Metrics & Monitoring

### 8.1 Decision Tracking

Track internally (not visible to player):

| Metric | Purpose |
|--------|---------|
| Decisions per session | Validate density targets |
| Time between decisions | Identify dead spots |
| Decision type distribution | Balance check |
| Skip/auto-resolve rate | Engagement indicator |
| Time to decide | Difficulty indicator |

### 8.2 Intervention Triggers

| Condition | Intervention |
|-----------|--------------|
| No decision in 5+ min (Founder) | Surface opportunity or event |
| No decision in 10+ min (Manager) | Prompt strategic review |
| No decision in 15+ min (Executive) | CEO briefing with strategic options |
| No decision in 20+ min (Chairman) | Legacy opportunity or industry shift |
| >50% decisions auto-resolved | Ask if player wants more control |
| <3 decisions/session (Executive) | Introduce challenge or crisis |
| <1 decision/session (Chairman) | Major industry event or succession prompt |

### 8.3 Player Feedback Loops

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  SESSION SUMMARY                                                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Session: 45 minutes                                                        │
│  Game time: 8 months                                                        │
│                                                                             │
│  DECISIONS MADE: 12                                                         │
│  • Strategic: 3 (new hub, fleet order, alliance partner)                   │
│  • Tactical: 5 (pricing adjustments, schedule changes)                     │
│  • Reactive: 4 (competitor response, disruption handling)                  │
│                                                                             │
│  DELEGATED: 8 decisions handled by executives                              │
│  • 2 required your approval (exceptions)                                   │
│  • 6 resolved within policy                                                │
│                                                                             │
│  OUTCOMES                                                                   │
│  • Revenue up 12%                                                          │
│  • 2 routes now profitable (were marginal)                                 │
│  • 1 bad call: Prague expansion struggling                                 │
│                                                                             │
│  [Review decisions] [Continue] [Exit]                                      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 9. Integration Points

### 9.1 Related Specifications

| Spec | Integration | Status |
|------|-------------|--------|
| `tutorial-spec.md` | Complexity levels affect decision surfacing | ✓ Exists |
| `route-economics-spec.md` | Route performance drives tactical decisions | ✓ Exists |
| `service-suppliers-spec.md` | Supplier contracts create periodic decisions | ✓ Exists |
| `cabin-designer-spec.md` | Configuration choices at fleet/route level | ✓ Exists |
| `economic-parameters.md` | Tuning values for decision frequency and impact | ✓ Exists |
| `world-events-spec.md` | Events inject decisions into quiet periods | ✓ Exists |
| `executive-delegation-spec.md` | Delegation levels control decision filtering | 📋 Planned |
| `ai-competitors-spec.md` | AI creates reactive decision opportunities | 📋 Planned |

### 9.2 Data Model

Decision tracking entities (`DecisionLog`, `SessionMetrics`) should be added to `data-model.md` when this spec is approved. Key fields needed:

- **DecisionLog**: session_id, timestamp, category (STRATEGIC/TACTICAL/OPERATIONAL/REACTIVE), domain, time_to_decide, outcome
- **SessionMetrics**: duration_real, duration_game, decisions_total, decisions_by_category, max_idle_time, interventions_triggered

*See `data-model.md` for the authoritative schema. GamePhase enum already defines FOUNDER/MANAGER/EXECUTIVE/CHAIRMAN.*

---

## 10. Tuning Guidelines

### 10.1 Phase-Specific Tuning

| Lever | Founder | Manager | Executive | Chairman |
|-------|---------|---------|-----------|----------|
| Event frequency | High | Medium | Low | Very Low |
| Competitor aggression | Medium | High | Variable | Industry-level |
| Exception threshold | Low (surface more) | Medium | High | Very High |
| Decision queue visibility | Always | On demand | Strategic only | Legacy only |
| Auto-resolve option | Disabled | Optional | Encouraged | Default |

### 10.2 Difficulty Scaling

| Difficulty | Decision Density Effect |
|------------|------------------------|
| Easy | More time to decide, softer consequences |
| Normal | Targets as specified |
| Hard | Tighter timing, more cascading effects |
| Expert | No decision queue, pure reactive |

---

## Document History

| Version | Date | Changes |
|---------|------|---------|
| 0.1 | January 2026 | Initial specification |
| 0.2 | January 2026 | Aligned phases with GDD (4 phases: Founder/Manager/Executive/Chairman). Flagged all density numbers as hypotheses. Fixed spec references to existing documents. Moved data model to reference only. |
| 0.3 | January 2026 | Added quality gates to phase transitions (Section 1.2) to prevent speedrunner exploits. Gates include profitability, margins, and financial stability requirements alongside quantity thresholds. |