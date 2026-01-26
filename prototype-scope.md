# Prototype Scope — Minimum Playable Slice

**Version:** 0.2  
**Date:** January 2026  
**Author:** Producer  
**Status:** DRAFT — Starting parameters confirmed

---

## 1. Core Question Under Test

> **"Is the loop of selecting routes, setting prices, observing revenue, and adjusting based on market feedback engaging enough to build a game around?"**

This prototype exists to validate (or invalidate) the fundamental premise that airline tycoon economics can be *fun*, not just *accurate*. We are not testing whether a full airline simulation works — we are testing whether the core decision-feedback cycle creates engagement.

**Secondary questions (testable with same slice):**
- Does competition create meaningful tension?
- Does route economics feel consequential without being opaque?
- Is watching flights operate satisfying or boring?

---

## 2. Systems In Scope

### 2.1 Route Economics (REQUIRED — Full Implementation)

**Source:** `route-economics-spec.md` §1-6

| Component | Implementation | Rationale |
|-----------|----------------|-----------|
| Base demand calculation | Simplified (population-based) | Need demand to respond to capacity |
| Demand segments | **Stub** — 2 segments (business, leisure) | 5 segments adds complexity, not learning |
| Price elasticity | Full implementation | Core to testing if pricing feels meaningful |
| Load factor / spill / spoilage | Full implementation | Player needs to see over/under capacity |
| Competition market share | Simplified logit model | Need to see competition impact |
| Seasonal patterns | **Stub** — flat demand | Test core loop before adding cycles |
| Cargo revenue | **Cut** | Not core to route decision loop |
| Ancillary revenue | **Cut** | Add after core loop validated |

**Why full:** Route economics IS the core loop. If this doesn't work, nothing else matters.

### 2.2 Pricing & Revenue Feedback (REQUIRED — Full Implementation)

**Source:** `route-economics-spec.md` §7, `financial-model-spec.md` §2

| Component | Implementation | Rationale |
|-----------|----------------|-----------|
| Pricing strategies (3 presets) | Full implementation | Core player decision |
| Revenue calculation | Full implementation | Core feedback |
| Revenue visualization | Full implementation | Player must *see* results |
| Yield management | **Stub** — single price per cabin | Fare classes add complexity |

**Why full:** Price→revenue→feedback is the atomic unit of engagement we're testing.

### 2.3 Basic Fleet (REQUIRED — Stub)

**Source:** `fleet-market-spec.md` §1-2

| Component | Implementation | Rationale |
|-----------|----------------|-----------|
| Aircraft types | **Stub** — 2-3 types (regional, narrowbody, widebody) | Enough for route matching |
| Aircraft acquisition | **Stub** — instant purchase from fixed catalog | Cut negotiation, lead times |
| Operating costs | Simplified (fuel + fixed daily) | Cost vs revenue needs to work |
| Depreciation/valuation | **Cut** | Not relevant to core loop |
| Manufacturer relationships | **Cut** | Progression system, not core |
| Leasing | **Cut** | Alternative financing, not core |

**Why stub:** Fleet is a constraint on route decisions, not the decision itself. Minimal fleet enables route testing.

### 2.4 Network/Scheduling (REQUIRED — Partial)

**Source:** `network-scheduler-spec.md` §1-6

| Component | Implementation | Rationale |
|-----------|----------------|-----------|
| Aircraft assignment to routes | Full implementation | Core decision |
| Basic Gantt visualization | Partial (day view only) | Need to see utilization |
| Turnaround time | Simplified (fixed 45 min) | Needs to constrain scheduling |
| Utilization metrics | Partial (hours/day) | Feedback on efficiency |
| Maintenance blocks | **Cut** | Adds complexity without testing core |
| Crew overlay | **Cut** | Separate system |
| Slot management | **Cut** | Advanced constraint system |
| Conflict detection | Simplified (overlap only) | Prevent broken schedules |

**Why partial:** Scheduling matters for utilization feel, but full Gantt complexity is polish.

### 2.5 Competition (REQUIRED — Stub)

**Source:** `ai-competitors-spec.md` §1-4

| Component | Implementation | Rationale |
|-----------|----------------|-----------|
| AI presence on routes | **Stub** — 1-2 static competitors | Need competition pressure |
| AI pricing response | Simplified (match within band) | Test if player notices/cares |
| AI route entry/exit | **Cut** | Dynamic behavior requires tuning |
| AI personalities | **Cut** | Personality requires working base |
| Rivalry/friction | **Cut** | Emergent system, not core |
| Alliances/codeshares | **Cut** | Advanced feature |

**Why stub:** We need *some* competition to create pricing tension, but believable AI is its own project. Static competitors with reactive pricing tests the minimum.

### 2.6 Financial Model (REQUIRED — Simplified)

**Source:** `financial-model-spec.md` §1-4

| Component | Implementation | Rationale |
|-----------|----------------|-----------|
| Cash balance | Full implementation | Constraint on decisions |
| Revenue tracking | Full implementation | Core feedback |
| Operating costs | Simplified (per-flight formula) | Need profit/loss to matter |
| Weekly P&L | Partial (revenue - costs) | Basic financial feedback |
| Balance sheet | **Cut** | Accounting complexity |
| Cash flow timing | **Cut** | Simplify to instant |
| Loans/financing | **Enhanced** — asset-backed credit | Need a way to expand via debt leverage |
| Covenants | **Cut** | Advanced financial pressure |
| Bankruptcy | Simplified (cash < 0 = game over) | Stakes need to exist |
| Fuel hedging | **Cut** | Financial derivative, not core |
| Taxes | **Cut** | Unnecessary complexity |

**Why simplified:** Money needs to matter, but we're not testing financial modeling — just consequences.

### 2.7 Time System (REQUIRED — Partial)

| Component | Implementation | Rationale |
|-----------|----------------|-----------|
| Time progression | 3 speeds (pause, normal, fast) | Need to observe and accelerate |
| Flight animation | Simplified (plane icons on map) | Visual feedback that things happen |
| Skip-to feature | Basic (skip to next event) | Avoid dead time |
| Calendar/scheduling | Weekly cycle | Matches route economics |

### 2.8 UI (REQUIRED — Functional)

| Component | Implementation | Rationale |
|-----------|----------------|-----------|
| World map with routes | Full implementation | Core visualization |
| Route creation interface | Full implementation | Core action |
| Aircraft assignment | Full implementation | Core action |
| Route economics display | Full implementation | Core feedback |
| Fleet list | Basic list view | Minimal fleet management |
| Financial summary | Simple dashboard | Cash + weekly P&L |

---

## 3. Systems Out of Scope

### 3.1 Cut Entirely (Not Needed for Core Question)

| System | Source Spec | Reason for Cut |
|--------|-------------|----------------|
| **Crew management** | `crew-management-spec.md` | Separate operational layer, not core loop |
| **Maintenance** | `maintenance-spec.md` | Adds constraint complexity, test separately |
| **Cabin designer** | `cabin-designer-spec.md` | Configuration decision, not route decision |
| **Service suppliers** | `service-suppliers-spec.md` | Supplier negotiations are polish |
| **Living flight observation** | `living-flight-spec.md` | Pure immersion, no gameplay |
| **World events** | `world-events-spec.md` | Event system is variety, not core |
| **Tutorial system** | `tutorial-spec.md` | Test with design team first, not new players |
| **Campaigns** | `GDD_AirlineTycoon.md` §4 | Sandbox only for prototype |
| **Cargo operations** | `route-economics-spec.md` §9 | Secondary revenue stream |
| **Ancillary revenue** | `route-economics-spec.md` §10 | Secondary revenue stream |
| **Fuel hedging** | `financial-model-spec.md` §12 | Financial instrument, not core |
| **Alliance system** | `ai-competitors-spec.md` §9 | Partnership complexity |
| **Governance/board** | `governance-spec.md` | Late-game system |
| **Brand/marketing** | `brand-marketing-spec.md` | Soft factor, test later |
| **Executive delegation** | `executive-delegation-spec.md` | Scale system, not early game |
| **Difficulty curve** | `difficulty-curve-spec.md` | Tuning, not core validation |
| **Compromise system** | `compromise-system-spec.md` | Narrative layer |
| **Endgame content** | `endgame-content-spec.md` | Post-core validation |
| **Slot management** | `network-scheduler-spec.md` §17 | Airport constraint system |

### 3.2 Deferred (Needed, But Not for First Prototype)

| System | When Needed | Dependency |
|--------|-------------|------------|
| Full AI competitor behavior | After core loop validated | Needs pricing to work first |
| Seasonal demand | After base demand works | Adds variation to working system |
| 5 passenger segments | After 2-segment testing | Complexity increase |
| Fare class yield management | After flat pricing works | Revenue optimization layer |
| Detailed maintenance scheduling | After utilization validated | Operational constraint |
| FTUE/tutorial | After systems stable | Can't tutor unstable systems |

---

## 4. Technical Unknowns

### 4.1 High Risk (Prove First)

| Unknown | Risk | Mitigation |
|---------|------|------------|
| **Price elasticity feel** | Math may not translate to fun | Build pricing sandbox first, tune before full integration |
| **Competition visibility** | Player may not notice AI impact | Explicit "competitor action" notifications in prototype |
| **Revenue feedback timing** | Results may feel delayed/disconnected | Add clear cause→effect visualization |
| **Map/route visualization** | Performance with many routes | Test with 30+ routes early |

### 4.2 Medium Risk (Monitor)

| Unknown | Risk | Mitigation |
|---------|------|------------|
| **Time speed calibration** | May be too fast or too slow | Make speeds adjustable, collect feedback |
| **Decision density at small scale** | 1-3 planes may feel empty | Inject events if needed, but try without first |
| **Load factor interpretation** | Players may not understand metric | Test iconography and feedback |

### 4.3 Low Risk (Known Solutions)

| Unknown | Status |
|---------|--------|
| Godot map rendering | Proven in existing prototype work |
| Basic UI patterns | Standard tycoon conventions |
| Data persistence | Simple JSON save sufficient for prototype |

---

## 5. Prototype Exit Criteria

### 5.1 Core Question Answered (Required)

| Criteria | Measurement | Target |
|----------|-------------|--------|
| **Route decision engagement** | Playtest observation: Do testers adjust prices? | >80% of testers make 3+ price adjustments voluntarily |
| **Revenue feedback noticed** | Playtest observation: Do testers check results? | >80% check route performance after changes |
| **Competition creates tension** | Playtest observation: Do testers react to competition? | >50% of testers respond to competitor pricing |
| **Session length** | Time spent in prototype | >20 min average session (unguided) |
| **Desire to continue** | Post-test survey | >60% "want to see what happens next" |

### 5.2 Secondary Signals (Informative)

| Signal | What It Tells Us |
|--------|------------------|
| Testers ask for more aircraft types | Fleet variety matters |
| Testers complain about competitor behavior | AI needs work (expected) |
| Testers get confused about pricing impact | Feedback visualization needs work |
| Testers want to see individual flights | Living flight has appeal |
| Testers ignore competition | Competition implementation failed |

### 5.3 Failure Criteria (Kill Signals)

| Signal | Implication |
|--------|-------------|
| Testers set prices once and never adjust | Core loop is set-and-forget — fundamental problem |
| Testers don't notice revenue changes | Feedback loop broken — fix before continuing |
| Testers find "optimal" strategy in <30 min | Solved game — need more dynamics |
| Testers report boredom despite mechanics working | May not be fun — design review needed |

---

## 6. Rough Scope Estimate

### 6.1 Assumptions

| Factor | Assumption |
|--------|------------|
| Team size | Solo developer or 2-person team |
| Engine | Godot (existing prototype foundation) |
| Art | Placeholder/minimal (icons, simple map) |
| Audio | None (add later) |
| Platform | PC only (development builds) |
| Scope discipline | Features not in this doc = explicitly cut |

### 6.2 Estimate

| Phase | Duration | Deliverable |
|-------|----------|-------------|
| **Map + Route Visualization** | 2-3 weeks | Functional world map, route lines, airport markers |
| **Route Economics Core** | 2-3 weeks | Demand model, pricing, revenue calculation |
| **Fleet + Scheduling Basics** | 2-3 weeks | Aircraft types, assignment, basic utilization |
| **Competition Stub** | 1-2 weeks | Static competitors, reactive pricing |
| **Financial Basics** | 1 week | Cash, costs, simple loan |
| **Time System** | 1 week | Pause/play/fast, basic progression |
| **UI/Feedback** | 2-3 weeks | Route panels, financial dashboard, notifications |
| **Integration + Polish** | 2-3 weeks | Bug fixing, balance tuning, playtest prep |

**Total estimate: 13-20 weeks** (3-5 months)

**Confidence:** Low-Medium. Estimate assumes:
- No major technical surprises
- Scope stays as specified (NO creep)
- Existing Godot prototype provides foundation
- Placeholder art acceptable

**Uncertainty factors:**
- Route economics tuning may take longer (balancing is hard)
- Competition stub may need iteration
- UI iteration often exceeds estimates

### 6.3 Risk-Adjusted Estimate

| Scenario | Duration | Probability |
|----------|----------|-------------|
| Optimistic (no surprises) | 3 months | 20% |
| Expected (normal challenges) | 4-5 months | 60% |
| Pessimistic (major rework) | 6+ months | 20% |

---

## 7. What This Prototype Is NOT

To maintain scope discipline, explicitly acknowledging what we are NOT building:

- **Not a vertical slice** — This is a horizontal proof of core loop, not polished content
- **Not feature-complete** — Missing systems are intentional, not TODO
- **Not balanced** — Numbers will be wrong; we're testing feel, not tuning
- **Not pretty** — Placeholder art is fine; visual polish comes after fun is proven
- **Not the tutorial** — Design team will play, not new users
- **Not a demo** — Not for external showing; internal validation only

---

## 8. Dependencies

### 8.1 Prerequisite Decisions (Flag to @game-designer)

| Decision Needed | Why It Matters | Owner |
|-----------------|----------------|-------|
| Starting conditions (cash, plane type) | Affects early game feel | Game Designer |
| Map scope (regional vs global) | Affects route variety in prototype | Game Designer |
| Competition intensity (1 vs 2 competitors) | Affects tension level | Game Designer |
| Price change delay (instant vs next week) | Affects feedback speed | Game Designer |

### 8.2 External Dependencies

| Dependency | Status | Risk |
|------------|--------|------|
| Godot 4.x stable | Available | Low |
| Airport/route data | Exists in `airline-data/` | Low — needs review |
| Aircraft data | Exists in `airline-data/` | Low — needs simplification |

### 8.3 Prototype Starting Parameters

*Confirmed by Game Designer based on FTUE profiles and economic-parameters.md*

> **⚠️ Note:** All values are hypotheses. Adjust during playtesting.

| Parameter | Value | Rationale | Reference |
|-----------|-------|-----------|-----------|
| **Starting cash** | €1.5M | ~3 months runway at typical costs. Below FTUE "Fresh Start" ($2M) but above desperation. | FTUE §Screen 3, decision-density-spec.md §1.2 |
| **Starting aircraft** | 1× ATR 72-600 | 72 seats, regional range. More viable than ATR 42 for testing route economics. | economic-parameters.md §3.3 |
| **Map scope** | Europe regional (~30 airports) | Dense short-haul market. Enough variety without performance risk. | FTUE §Region Characteristics, prototype-scope.md §4.1 |
| **Competition** | 1 static competitor | Minimum viable competition pressure. Appears on 40-60% of viable routes. | prototype-scope.md §2.5 |
| **Price change timing** | Next-day effect | Fast enough for iteration, slow enough for cause-effect clarity. | prototype-scope.md §2.2 |

#### Starting Aircraft Specifications

| Attribute | ATR 72-600 |
|-----------|------------|
| Seats | 72 (single class) |
| Range | 1,500 km |
| Fuel consumption | ~350 gal/hr |
| Daily operating cost | ~€3,500 (fuel + crew + mx reserve) |
| Typical route length | 300-800 km |

> **Balance Note (Jan 2026):** Daily operating cost reduced from €8,000 to €3,500 after playtesting showed routes were unprofitable even with 60-70% load factors. The €3,500 figure represents a realistic turboprop operating cost that allows profitable operation at ~50% load factor with baseline pricing.

#### Starting Position

- **Hub:** Player-selected from 4 recommended: Amsterdam, Frankfurt, Paris CDG, Munich
- **Competitor presence:** 1 AI airline with 3-5 routes in region (static, reactive pricing only)
- **Demand modifier:** Normal (no events, no seasonality)
- **Time:** Day 1, Week 1 (fresh start)

#### Why These Values

| Design Goal | How Parameters Serve It |
|-------------|-------------------------|
| Force pricing decisions | €1.5M runway creates urgency without panic |
| Test competition reaction | Single competitor on some (not all) routes |
| Enable iteration | Next-day pricing + fast-forward lets players try 5+ strategies per session |
| Avoid early failure | ATR 72 on regional routes is viable; hard to lose money if load factor >50% |

---

## 9. Recommended Prototype Build Order

### Phase 1: Prove the Feedback Loop (Weeks 1-5)
1. Static map with 10 airports
2. Create route between two airports
3. Assign (fixed) aircraft to route
4. Set price for route
5. Time passes, flights operate
6. Revenue appears based on price/demand
7. **Validate:** Does price→revenue feel connected?

### Phase 2: Add Competition Pressure (Weeks 6-8)
1. Add 1 static competitor on some routes
2. Competitor affects your market share
3. Competitor reacts to your price (simple matching)
4. **Validate:** Does competition create tension?

### Phase 3: Fleet Decisions (Weeks 9-11)
1. Add 2-3 aircraft types with different characteristics
2. Purchase new aircraft from simple menu
3. Assign aircraft to routes (matching constraints)
4. Basic utilization display
5. **Validate:** Do fleet decisions feel meaningful?

### Phase 4: Financial Stakes (Weeks 12-14)
1. Costs reduce cash
2. Cash runs out = game over
3. Loan option to expand
4. **Validate:** Do financial stakes create pressure?

### Phase 5: Integration + Playtest Prep (Weeks 15-18)
1. Bug fixing
2. Basic balance pass
3. Session logging for telemetry
4. Playtest protocol preparation

---

## Risk Register

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Core loop feels passive | Medium | Critical | Build pricing sandbox early, get feedback before integration |
| Scope creep ("just one more feature") | High | High | This document is the scope. Flag additions for explicit approval. |
| Route economics too complex to tune | Medium | Medium | Start with simpler demand model, add complexity only if needed |
| Competition feels random | Medium | Medium | Add explicit notifications when competitors act |
| Technical debt from prototyping | Medium | Low | Accept debt; prototype is throwaway if core fails |
| Map visualization performance | Low | Medium | Test early with target route count |

---

## 10. Economic Balance Log

*Record of balance changes made during prototype development.*

### v0.3 — January 26, 2026

#### Operating Cost Rebalance
- **ATR 72-600 daily_cost:** €8,000 → €3,500
- **Reason:** Routes were unprofitable even at 60-70% load factors. Original cost was too high for regional turboprop economics.
- **Result:** Routes now profitable at ~50% load factor with baseline pricing.

#### Credit Limit Enhancement
- **Previous formula:** `weekly_revenue × 10 × reputation_multiplier`
- **New formula:**
  - Revenue credit: `weekly_revenue × 20`
  - Asset credit: `fleet_value × 50%` (aircraft as collateral)
  - Cash credit: `balance × 30%`
  - Minimum: €5M credit line
  - Reputation multiplier: 1.0 to 2.0 based on grade
- **Reason:** Original formula limited credit to ~€2.5M, insufficient to purchase aircraft. Players had no viable expansion path beyond grinding 100+ weeks.
- **Result:** Players with 4 aircraft can borrow ~€30-50M, enabling debt-leveraged expansion.

#### Cost Calculation Cleanup
- Fuel/crew/maintenance now scale from aircraft `daily_cost` metadata
- Airport fees reduced by ~70% (were unrealistically high for regional ops)
- Debug output added showing full cost breakdown per route

#### Aircraft Price & Interest Rate Rebalance
- **ATR 72-600 price:** €26.5M → €15M (realistic used turboprop value)
- **Lease rate:** €180K/month → €120K/month
- **Interest rates:** Reduced across all grades (New: 8% → 6%, others scaled proportionally)
- **Reason:** With €200K/week profit and €26.5M aircraft, expansion took ~2.5 years. Too slow for engaging gameplay.
- **Target pacing:** Player can acquire 2nd aircraft within 30-60 minutes of play using debt leverage

---

## Document History

| Version | Date | Changes |
|---------|------|---------|
| 0.1 | January 2026 | Initial prototype scope |
| 0.2 | January 2026 | Added Section 8.3 (Prototype Starting Parameters) with confirmed values: €1.5M cash, ATR 72-600, Europe regional map, 1 static competitor, next-day price effects. |
| 0.3 | January 26, 2026 | Added Section 10 (Economic Balance Log). Documented operating cost rebalance and credit limit enhancement. |
