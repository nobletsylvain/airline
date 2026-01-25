# Executive Team & Delegation — Detailed Specification

**Version:** 0.1  
**Date:** January 2026  
**Companion to:** Game Design Document v0.7, Governance Spec v0.1

---

## Overview

This document specifies how executive hiring, management, and delegation of authority work in Airliner — the systems that let you scale from doing everything yourself to running a major airline.

**Design Philosophy:** You can't do everything forever. As the airline grows, you must hire people, trust them, and let go. Good delegation multiplies your effectiveness; bad delegation creates disasters. The game should make both feel real.

**Core Loop:** Identify need → Hire executive → Set delegation level → Define policies → Monitor performance → Adjust

---

## 1. Executive Positions

### 1.1 C-Suite Roles

| Role | Unlock Trigger | Responsibility | Key Decisions |
|------|----------------|----------------|---------------|
| **CEO** | Start | You | Strategy, vision, stakeholders |
| **COO** | 10 aircraft | Operations | Schedule, maintenance, crew |
| **CFO** | $50M revenue | Finance | Cash, debt, hedging, reporting |
| **CCO** | 20 routes | Commercial | Pricing, revenue management, sales |
| **CMO** | Brand score 50 | Marketing | Brand, campaigns, loyalty |
| **CTO** | 30 aircraft | Technology | IT, digital, innovation |
| **CPO** | 50 aircraft | Procurement | Fleet, suppliers, contracts |
| **CHRO** | 500 employees | People | HR, training, labor relations |
| **CSO** | 100 routes | Strategy | Planning, M&A, alliances |

### 1.2 Position Details

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  EXECUTIVE TEAM                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  FILLED POSITIONS                                                           │
│                                                                             │
│  Chief Operating Officer · Marie Laurent                                   │
│  Hired: Mar 2025 │ Salary: $185K │ Performance: Good                       │
│  Delegation: Level 3 (Guidelines) │ Loyalty: Solid                         │
│  Handling: Scheduling, maintenance, crew rostering                         │
│  [View details] [Adjust delegation] [Performance review]                   │
│                                                                             │
│  Chief Financial Officer · David Park                                      │
│  Hired: Jun 2025 │ Salary: $210K │ Performance: Exceptional                │
│  Delegation: Level 4 (Oversight) │ Loyalty: Committed                      │
│  Handling: Treasury, reporting, investor relations                         │
│  [View details] [Adjust delegation] [Performance review]                   │
│                                                                             │
│  OPEN POSITIONS                                                             │
│                                                                             │
│  Chief Commercial Officer · VACANT                                         │
│  ⚠ Revenue management running on defaults                                  │
│  [Start recruitment]                                                       │
│                                                                             │
│  LOCKED POSITIONS (not yet needed)                                         │
│  CMO: Unlocks at brand score 50 (current: 42)                              │
│  CTO: Unlocks at 30 aircraft (current: 18)                                 │
│  CSO: Unlocks at 100 routes (current: 34)                                  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Hiring Executives

### 2.1 Recruitment Channels

| Channel | Cost | Time | Quality | Discretion |
|---------|------|------|---------|------------|
| **Direct approach** | Low | 2-4 weeks | Variable | Low (visible) |
| **Executive search** | 25-33% salary | 4-8 weeks | High | High |
| **Internal promotion** | Low | 2 weeks | Known quantity | N/A |
| **Industry network** | Medium | 2-6 weeks | Good | Medium |
| **Competitor poach** | Premium | 4-12 weeks | Proven | Low |

### 2.2 Candidate Evaluation

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  CANDIDATE · Chief Commercial Officer                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  CANDIDATE: Sophie Martinez                                                 │
│  Current: VP Revenue Management, EuroWings                                 │
│  Experience: 12 years │ Age: 44 │ Notice period: 3 months                  │
│                                                                             │
│  COMPETENCIES (1-10)                                                        │
│  Strategic thinking:  ████████░░ 8    Cost focus:     ██████░░░░ 6        │
│  Execution:           ███████░░░ 7    Quality focus:  ████████░░ 8        │
│  Innovation:          █████████░ 9    People skills:  ███████░░░ 7        │
│  Industry knowledge:  ████████░░ 8                                         │
│                                                                             │
│  PERSONALITY                                                                │
│  Risk tolerance: High │ Communication: Direct │ Ambition: High             │
│  Autonomy preference: High (prefers delegation level 4-5)                  │
│                                                                             │
│  FIT ANALYSIS                                                               │
│  ✓ Strong revenue management background                                    │
│  ✓ Experience scaling commercial teams                                     │
│  ⚠ May clash with conservative CFO on pricing risks                       │
│  ⚠ High autonomy preference — needs clear guardrails                      │
│                                                                             │
│  OFFER                                                                      │
│  Salary requested: $220K │ Your budget: $180-240K                          │
│  Signing bonus: $30K requested                                             │
│  Equity: 0.5% requested                                                    │
│                                                                             │
│  [Make offer] [Negotiate] [Reject] [Compare candidates]                    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2.3 Hiring Costs

| Component | Typical Range | Notes |
|-----------|---------------|-------|
| Base salary | $150-350K | By role and experience |
| Signing bonus | $10-50K | To close deal |
| Search fee | $40-100K | If using headhunter |
| Equity | 0.25-2% | For key hires |
| Relocation | $20-50K | If moving |

---

## 3. Delegation System

### 3.1 Delegation Levels

| Level | Name | Your Role | Executive Role | Best For |
|-------|------|-----------|----------------|----------|
| **0** | Direct control | Make every decision | Execute only | Early stage, crisis |
| **1** | Assisted | Decide with recommendations | Analyze, recommend | Learning a function |
| **2** | Approval | Review and approve/reject | Propose, implement | Building trust |
| **3** | Guidelines | Set policies, review exceptions | Decide within policy | Trusted executive |
| **4** | Oversight | Review outcomes only | Full authority in scope | Proven executive |
| **5** | Trust | Set goals only | Complete autonomy | Exceptional performer |

### 3.2 Delegation by Function

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  DELEGATION SETTINGS                                                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  FUNCTION          EXECUTIVE     LEVEL    POLICY                           │
│                                                                             │
│  Scheduling        COO Laurent   ███░░ 3  "Minimize crew costs"            │
│  Maintenance       COO Laurent   ████░ 4  "Safety first, then cost"        │
│  Crew rostering    COO Laurent   ███░░ 3  "Fair distribution"              │
│                                                                             │
│  Pricing           (Vacant)      █░░░░ 1  Using system defaults            │
│  Revenue mgmt      (Vacant)      █░░░░ 1  Using system defaults            │
│  Sales channels    (Vacant)      █░░░░ 1  Using system defaults            │
│                                                                             │
│  Treasury          CFO Park      ████░ 4  "Min 60 days cash"               │
│  Fuel hedging      CFO Park      ███░░ 3  "50-70% coverage"                │
│  Debt management   CFO Park      ██░░░ 2  Approval required                │
│                                                                             │
│  ⚠ Commercial functions at Level 1 — consider hiring CCO                   │
│                                                                             │
│  [Adjust levels] [Edit policies] [View performance]                        │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3.3 Delegation Trade-offs

| Higher Delegation | Lower Delegation |
|-------------------|------------------|
| Saves your time | Maintains control |
| Faster decisions | Catches errors |
| Develops executives | Limits damage |
| May miss problems | Slower scaling |
| Executive satisfaction | Executive frustration |

---

## 4. Policies

### 4.1 Policy Types

| Category | Examples |
|----------|----------|
| **Commercial** | Pricing targets, distribution channels, discount limits |
| **Operational** | On-time priority, turnaround times, maintenance standards |
| **Financial** | Cash minimums, debt limits, hedging coverage |
| **HR** | Salary bands, hiring authority, training investment |
| **Brand** | Service standards, complaint handling, marketing tone |

### 4.2 Policy Configuration

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  POLICY EDITOR · Pricing                                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  POLICY: Leisure route pricing                                             │
│  Applies to: CCO (or system if vacant)                                     │
│  Function: Revenue management                                               │
│                                                                             │
│  RULES                                                                      │
│                                                                             │
│  Target load factor:        [75-85%      ]                                 │
│  Minimum margin per flight: [15%         ]                                 │
│  Maximum discount vs base:  [40%         ]                                 │
│  Price floor:               [Variable cost + 10%]                          │
│                                                                             │
│  COMPETITIVE RESPONSE                                                       │
│  If competitor cuts >15%:   [Match within 5%  ▼]                           │
│  If competitor exits:       [Raise 10-15%    ▼]                            │
│  Price war stance:          [Defend share   ▼]                             │
│                                                                             │
│  SEASONAL ADJUSTMENT                                                        │
│  Peak markup:               [+20-30%     ]                                 │
│  Off-peak discount:         [-15-25%     ]                                 │
│                                                                             │
│  EXCEPTIONS                                                                 │
│  ☑ Alert me if margin falls below 10%                                     │
│  ☑ Alert me if competitor starts price war                                │
│  ☐ Require approval for discounts >30%                                    │
│                                                                             │
│  [Save policy] [Test impact] [Revert to defaults]                          │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.3 Policy Conflicts

When policies conflict:
1. Safety policies always win
2. Financial minimums override growth targets
3. Player can set explicit priority order
4. System alerts player to conflicts

---

## 5. Executive Performance

### 5.1 Performance Dimensions

| Dimension | What It Measures |
|-----------|------------------|
| **Results** | KPIs in their domain |
| **Execution** | Projects completed on time/budget |
| **Leadership** | Team morale, development |
| **Judgment** | Quality of decisions made |
| **Collaboration** | Works well with peers |

### 5.2 Performance Ratings

| Rating | Description | Consequence |
|--------|-------------|-------------|
| **Exceptional** | Top performer | Bonus, promotion candidate |
| **Good** | Meeting+ expectations | Normal progression |
| **Adequate** | Meeting expectations | Development needed |
| **Poor** | Below expectations | Warning, coaching |
| **Failing** | Unacceptable | Termination likely |

### 5.3 Performance Review

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  PERFORMANCE REVIEW · COO Marie Laurent                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  PERIOD: Q3 2026                                                            │
│  OVERALL RATING: Good                                                       │
│                                                                             │
│  RESULTS                                                                    │
│  On-time performance:  94.2% (target: 92%)     ████████░░ ✓ Exceeded       │
│  Cost per ASK:         $0.078 (target: $0.082) ████████░░ ✓ Exceeded       │
│  Maintenance delays:   3 (target: <5)          ████████░░ ✓ Met            │
│  Crew satisfaction:    72/100 (target: 70)     ███████░░░ ✓ Met            │
│                                                                             │
│  HIGHLIGHTS                                                                 │
│  • Renegotiated MRO contract saving $400K annually                         │
│  • Implemented new crew rostering system                                   │
│  • Handled summer disruption effectively                                   │
│                                                                             │
│  CONCERNS                                                                   │
│  • Slow to address pilot union issues                                      │
│  • Maintenance planning could be more proactive                            │
│                                                                             │
│  COMPENSATION                                                               │
│  Base salary: $185K │ Bonus earned: $28K (15% of target 20%)              │
│  Recommendation: 5% salary increase                                        │
│                                                                             │
│  [Approve review] [Adjust compensation] [Increase delegation]              │
│  [Performance improvement plan] [Terminate]                                │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 6. Executive Loyalty & Departure

### 6.1 Loyalty Factors

| Factor | Impact on Loyalty |
|--------|-------------------|
| Compensation vs market | High impact |
| Delegation level | Medium impact |
| Recognition | Medium impact |
| Company performance | Medium impact |
| Relationship with CEO | High impact |
| Growth opportunity | Medium impact |

### 6.2 Loyalty Levels

| Level | Behavior |
|-------|----------|
| **Committed** | Long-term, rejects approaches |
| **Solid** | Stable, occasional interest |
| **Wavering** | Open to conversations |
| **Looking** | Actively interviewing |

### 6.3 Departure Events

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  ⚠ EXECUTIVE DEPARTURE                                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  CFO David Park has received an offer from SkyConnect Airlines             │
│                                                                             │
│  Their offer: $280K base + $50K signing + 1% equity (CFO)                  │
│  Current: $210K base + 0.5% equity                                         │
│                                                                             │
│  David says: "I love what we've built here, but this is a significant     │
│  step up in responsibility and compensation. I wanted to give you the     │
│  chance to discuss before I decide."                                       │
│                                                                             │
│  If he leaves:                                                              │
│  • Financial functions revert to Level 1 (your direct control)            │
│  • Investor relations transition needed                                    │
│  • 3-month search for replacement likely                                   │
│  • Institutional knowledge loss                                            │
│                                                                             │
│  RESPONSE OPTIONS                                                           │
│  [Counter-offer] [Wish him well] [Negotiate retention] [Discuss concerns] │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 7. Data Model Integration

### 7.1 Entities

**Executive** — C-suite position

| Field | Type | Purpose |
|-------|------|---------|
| `id` | UUID | Primary key |
| `person_id` | FK → Person | The person |
| `airline_id` | FK → Airline | The airline |
| `role` | enum | CEO / COO / CFO / etc. |
| `hired_date` | date | Start date |
| `salary` | decimal | Base compensation |
| `bonus_target_pct` | float | Target bonus |
| `equity_pct` | float? | Ownership stake |
| `performance_rating` | enum | Current rating |
| `loyalty` | enum | Current loyalty |
| `relationship_with_ceo` | int | -100 to +100 |
| `last_review_date` | date | Last formal review |

**DelegationSetting** — Delegation configuration

| Field | Type | Purpose |
|-------|------|---------|
| `id` | UUID | Primary key |
| `airline_id` | FK | Which airline |
| `function` | enum | PRICING / SCHEDULING / etc. |
| `level` | int | 0-5 delegation level |
| `executive_id` | FK? → Executive | Who handles it |
| `policy_id` | FK? → Policy | Governing policy |
| `last_changed` | date | When adjusted |

**Policy** — Operating policies

| Field | Type | Purpose |
|-------|------|---------|
| `id` | UUID | Primary key |
| `airline_id` | FK | Which airline |
| `category` | enum | COMMERCIAL / OPERATIONAL / etc. |
| `name` | string | Policy name |
| `description` | string | What it governs |
| `parameters` | json | Specific rules |
| `priority` | int | Conflict resolution order |
| `active` | bool | Currently in effect |
| `created_date` | date | When established |

### 7.2 New Enumerations

```yaml
ExecutiveRole:
  CEO
  COO
  CFO
  CCO
  CMO
  CTO
  CPO
  CHRO
  CSO

DelegationFunction:
  SCHEDULING
  MAINTENANCE
  CREW_ROSTERING
  PRICING
  REVENUE_MANAGEMENT
  SALES_CHANNELS
  TREASURY
  FUEL_HEDGING
  DEBT_MANAGEMENT
  MARKETING
  LOYALTY_PROGRAM
  FLEET_PLANNING
  PROCUREMENT
  HR_HIRING
  HR_COMPENSATION
  LABOR_RELATIONS
  STRATEGY
  MA

DelegationLevel:
  DIRECT_CONTROL     # 0
  ASSISTED           # 1
  APPROVAL           # 2
  GUIDELINES         # 3
  OVERSIGHT          # 4
  TRUST              # 5

PerformanceRating:
  EXCEPTIONAL
  GOOD
  ADEQUATE
  POOR
  FAILING

LoyaltyLevel:
  COMMITTED
  SOLID
  WAVERING
  LOOKING

PolicyCategory:
  COMMERCIAL
  OPERATIONAL
  FINANCIAL
  HR
  BRAND
```

---

## Document History

| Version | Date | Changes |
|---------|------|---------|
| 0.1 | January 2026 | Initial specification |
