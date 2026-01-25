# Documentation Dependency Audit

**Date:** January 2026  
**Purpose:** Verify all systems are documented and dependencies are traceable before prototyping

---

## 1. Core System Dependency Map

### Legend
- ✓ Documented (spec or GDD section)
- ⚠️ Partially documented (mentioned but not detailed)
- ✗ Missing documentation
- → Depends on

---

## 2. System-by-System Audit

### FLEET MANAGEMENT
**What it does:** Buy/sell/lease aircraft, track condition, view history

| Dependency | Status | Where Documented |
|------------|--------|------------------|
| Aircraft entity | ✓ | data-model.md |
| AircraftType catalog | ✓ | data-model.md |
| AircraftPrestige | ✓ | data-model.md |
| AircraftHistory | ✓ | data-model.md |
| Pricing by era | ✓ | economic-parameters.md |
| Used aircraft values | ✓ | economic-parameters.md §3.4 |
| Lease rates | ✓ | economic-parameters.md §8 |
| Market (where to buy) | ⚠️ | Mentioned in GDD, no spec |
| Delivery queue | ⚠️ | Mentioned, no spec |

**Gap:** No "Fleet Market" spec describing how acquisition works (orders, auctions, lessors)

---

### ROUTE/NETWORK MANAGEMENT  
**What it does:** Open routes, set frequencies, price tickets, compete

| Dependency | Status | Where Documented |
|------------|--------|------------------|
| Airport entity | ✓ | data-model.md |
| Route entity | ✓ | data-model.md |
| Schedule entity | ✓ | data-model.md |
| Network Scheduler UI | ✓ | network-scheduler-spec.md |
| Demand model | ⚠️ | Route entity has demand fields, no calculation spec |
| Pricing/yield | ⚠️ | economic-parameters.md has historical fares, no demand curve |
| Competition response | ⚠️ | Mentioned in GDD, no AI behavior spec |
| Slot system | ⚠️ | Airport has slot fields, no acquisition spec |

**Gap:** No "Route Economics" spec describing demand curves, price elasticity, competition modeling

---

### CABIN CONFIGURATION
**What it does:** Design seat layouts, set amenities

| Dependency | Status | Where Documented |
|------------|--------|------------------|
| AircraftConfiguration | ✓ | data-model.md |
| Cabin Designer UI | ✓ | cabin-designer-spec.md |
| Seat types | ✓ | cabin-designer-spec.md §2 |
| Comfort calculation | ✓ | cabin-designer-spec.md §9 |
| Regulatory validation | ✓ | cabin-designer-spec.md §6 |
| Revenue impact | ✓ | cabin-designer-spec.md §8 |
| Reconfiguration cost/time | ✓ | cabin-designer-spec.md §10 |

**Status:** ✓ COMPLETE

---

### SERVICE & SUPPLIERS
**What it does:** Contract caterers, IFE, amenities; create service profiles

| Dependency | Status | Where Documented |
|------------|--------|------------------|
| Supplier entity | ✓ | data-model.md |
| SupplierContract | ✓ | data-model.md |
| ServiceProfile | ✓ | data-model.md |
| Contract negotiation | ✓ | service-suppliers-spec.md §4 |
| Service profiles | ✓ | service-suppliers-spec.md §5 |
| Cost calculations | ✓ | service-suppliers-spec.md §7 |
| Satisfaction impact | ✓ | service-suppliers-spec.md §8 |
| Crew requirements | ✓ | service-suppliers-spec.md §11 |

**Status:** ✓ COMPLETE

---

### SCHEDULING
**What it does:** Assign aircraft to routes, manage utilization

| Dependency | Status | Where Documented |
|------------|--------|------------------|
| Schedule entity | ✓ | data-model.md |
| Flight entity | ✓ | data-model.md |
| Gantt visualization | ✓ | network-scheduler-spec.md |
| Conflict detection | ✓ | network-scheduler-spec.md §5 |
| Turnaround rules | ✓ | network-scheduler-spec.md §4 |
| Maintenance blocks | ✓ | network-scheduler-spec.md §4.3 |
| Crew overlay | ✓ | network-scheduler-spec.md §7 |

**Status:** ✓ COMPLETE (scheduling UI), but depends on Crew & Maintenance systems

---

### MAINTENANCE
**What it does:** Schedule checks, manage MROs, handle AOG

| Dependency | Status | Where Documented |
|------------|--------|------------------|
| MaintenanceEvent entity | ✓ | data-model.md |
| Check types (A/B/C/D) | ✓ | network-scheduler-spec.md §4.3 |
| Check intervals | ✓ | network-scheduler-spec.md §4.3 |
| MRO providers | ⚠️ | Mentioned, no catalog or selection spec |
| AOG events | ⚠️ | Mentioned in GDD events, no resolution spec |
| Maintenance costs | ⚠️ | No cost tables |

**Gap:** No "Maintenance System" spec with MRO options, costs, failure modes

---

### CREW
**What it does:** Hire pilots/cabin crew, manage fatigue, training

| Dependency | Status | Where Documented |
|------------|--------|------------------|
| CrewMember entity | ✓ | data-model.md |
| CrewAssignment | ✓ | data-model.md |
| Legality rules | ⚠️ | Mentioned in scheduler, no detailed rules |
| Fatigue model | ⚠️ | Living Flight mentions crew_fatigue, no spec |
| Hiring/training | ⚠️ | service-suppliers-spec.md §11 has training costs, no hiring flow |
| Crew costs | ✓ | economic-parameters.md §5 |

**Gap:** No "Crew Management" spec with hiring, rostering, fatigue rules

---

### FINANCE
**What it does:** Track P&L, manage loans, investor relations

| Dependency | Status | Where Documented |
|------------|--------|------------------|
| Airline entity (finances) | ✓ | data-model.md |
| Revenue calculation | ⚠️ | cabin-designer + routes, no unified spec |
| Cost categories | ✓ | economic-parameters.md, service-suppliers-spec.md |
| Loan/debt | ⚠️ | economic-parameters.md §8 has rates, no mechanics |
| Cash flow | ⚠️ | No weekly/monthly flow spec |
| Board/investors | ⚠️ | GDD §10 has ownership, no detailed triggers |

**Gap:** No "Financial Model" spec with P&L structure, cash flow timing, debt mechanics

---

### BRAND & REPUTATION
**What it does:** Track perception by segment, marketing

| Dependency | Status | Where Documented |
|------------|--------|------------------|
| Brand entity | ⚠️ | data-model.md has brand_score, no breakdown |
| Segment perception | ⚠️ | GDD mentions segments, no spec |
| Marketing campaigns | ⚠️ | Not documented |
| Reputation events | ⚠️ | service-suppliers-spec.md §9 has brand impact, scattered |

**Gap:** No "Brand & Marketing" spec

---

### EVENTS & CRISES
**What it does:** Generate world events, trigger crises

| Dependency | Status | Where Documented |
|------------|--------|------------------|
| Event types | ✓ | GDD §12.5, historical-airlines-database.md |
| Event triggers | ⚠️ | data-model.md has triggers, no probability spec |
| Crisis resolution | ⚠️ | GDD has examples, no mechanic spec |
| Economic shocks | ✓ | economic-parameters.md §10.2 |

**Status:** Partially covered, events are more narrative than mechanical

---

### AI COMPETITORS
**What it does:** Simulate rival airlines

| Dependency | Status | Where Documented |
|------------|--------|------------------|
| Airline entity (AI) | ✓ | data-model.md |
| CompetitorRelationship | ✓ | data-model.md |
| AI behavior rules | ✗ | Not documented |
| Competition response | ✗ | Not documented |
| Alliance/codeshare AI | ✗ | Not documented |

**Gap:** No "AI Competitors" spec

---

### HISTORICAL SCENARIOS
**What it does:** Seed historical airline states

| Dependency | Status | Where Documented |
|------------|--------|------------------|
| Scenario entity | ✓ | data-model.md |
| Historical airlines | ✓ | historical-airlines-database.md |
| Era economics | ✓ | economic-parameters.md |
| Scripted events | ✓ | historical-airlines-database.md |
| Victory conditions | ✓ | historical-airlines-database.md |

**Status:** ✓ COMPLETE

---

### FTUE / TUTORIAL
**What it does:** Onboard new players

| Dependency | Status | Where Documented |
|------------|--------|------------------|
| FTUE flow | ✓ | FTUE_Endless_Mode.md |
| First aircraft | ✓ | FTUE doc |
| First route | ✓ | FTUE doc |
| UI hints | ⚠️ | Mentioned, no detailed hint spec |

**Status:** ✓ COMPLETE for sandbox mode

---

## 3. Gap Summary

| Missing Spec | Priority | Blocks Prototyping? | Complexity |
|--------------|----------|---------------------|------------|
| Route Economics (demand, pricing, competition) | **HIGH** | Yes — core loop | Medium |
| Financial Model (P&L, cash flow, debt) | **HIGH** | Yes — win/lose conditions | Medium |
| Fleet Market (acquisition channels) | Medium | Partial — can stub | Low |
| Maintenance System | Medium | Partial — can use simple model | Low |
| Crew Management | Medium | Partial — can stub | Medium |
| AI Competitors | Medium | No — can delay | High |
| Brand & Marketing | Low | No — can delay | Medium |

---

## 4. Recommended Priority

### Must have before prototyping:
1. **Route Economics Spec** — How demand works, price elasticity, load factors
2. **Financial Model Spec** — P&L categories, cash timing, bankruptcy triggers

### Nice to have before prototyping:
3. Fleet Market Spec — Acquisition flows (can stub with "buy button")
4. Maintenance Spec — Can use simple interval model initially

### Can defer to implementation:
5. AI Competitors — Human-only testing first
6. Brand & Marketing — Secondary system
7. Crew Management — Can stub with costs only

---

## 5. Cross-Reference: Data Model Completeness

Entities in data-model.md vs. systems that use them:

| Entity | Used By | Documented? |
|--------|---------|-------------|
| Aircraft | Fleet, Scheduling | ✓ |
| AircraftType | Fleet, Cabin | ✓ |
| AircraftConfiguration | Cabin Designer | ✓ |
| AircraftPrestige | Fleet (history) | ✓ |
| Airport | Routes, Scheduling | ✓ |
| Route | Network, Scheduling | ✓ needs demand spec |
| Schedule | Scheduling | ✓ |
| Flight | Scheduling, Living Flight | ✓ |
| FlightSnapshot | Living Flight | ✓ |
| Airline | All systems | ✓ needs finance detail |
| Supplier | Service & Suppliers | ✓ |
| SupplierContract | Service & Suppliers | ✓ |
| ServiceProfile | Service & Suppliers | ✓ |
| CrewMember | Crew, Scheduling | ⚠️ needs management spec |
| MaintenanceEvent | Maintenance, Scheduling | ⚠️ needs system spec |
| Scenario | Historical modes | ✓ |
| Competitor | AI, Events | ✗ needs AI spec |

---

## 6. Conclusion

**Documentation is ~75% complete.**

Two specs are blocking for a meaningful prototype:
1. Route Economics
2. Financial Model

These define the core gameplay loop: fly routes → earn revenue → manage costs → grow/fail.

Without them, you can build UI but can't validate if the game is *fun*.

---

## 7. Next Session: Specs to Create

### Blocking (HIGH priority)
1. **route-economics-spec.md** — Demand model, pricing, competition
2. **financial-model-spec.md** — P&L structure, cash flow, debt

### Non-Blocking (MEDIUM priority)
3. **fleet-market-spec.md** — Acquisition channels (new orders, leases, used market)
4. **maintenance-spec.md** — Check system, MROs, failures
5. **crew-management-spec.md** — Hiring, rostering, fatigue
6. **ai-competitors-spec.md** — AI airline behavior
7. **brand-marketing-spec.md** — Reputation system, campaigns
