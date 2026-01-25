# Prototype Tasks — Phase 1: Prove the Feedback Loop

**Version:** 0.2  
**Date:** January 2026  
**Phase:** 1 of 5  
**Status:** REVISED — Based on Godot Prototype Audit  
**Reference:** `prototype-scope.md` §9.1

---

## Overview

Phase 1 validates the core question: **Does price→revenue feel connected?**

By the end of Phase 1, we should have:
- A map with ~30 European airports
- Ability to create a route between two airports
- A single aircraft (ATR 72-600) assigned to that route
- Price setting interface
- Time progression showing flights operating
- Revenue appearing based on price and demand

**This phase does NOT include:** Multiple aircraft types, fleet purchasing, multi-class cabins, delegates, diplomacy, or tutorial.

---

## Status Legend

| Symbol | Meaning |
|--------|---------|
| ✅ | Done — Implemented and working |
| ⚠️ | Needs refinement — Partially done, missing elements noted |
| ❌ | TODO — Not yet implemented |
| 🗑️ | Remove — Out of scope, needs removal/hiding |

---

## Task Summary (Updated)

| Component | Total | ✅ Done | ⚠️ Partial | ❌ TODO | Remaining Hours |
|-----------|-------|---------|------------|--------|-----------------|
| **A. Project Setup** | 4 | 1 | 1 | 2 | 4-8 |
| **B. Map & Airports** | 6 | 5 | 1 | 0 | 2-4 |
| **C. Route Creation** | 5 | 5 | 0 | 0 | 0 |
| **D. Aircraft & Assignment** | 4 | 3 | 1 | 0 | 2-3 |
| **E. Pricing Interface** | 4 | 2 | 1 | 1 | 6-10 |
| **F. Time System** | 5 | 4 | 1 | 0 | 2-4 |
| **G. Demand & Revenue** | 6 | 4 | 1 | 1 | 10-16 |
| **H. Revenue Feedback UI** | 5 | 2 | 1 | 2 | 10-16 |
| **S. Simplification** | 6 | 0 | 0 | 6 | 8-14 |
| **Total** | **45 tasks** | **26** | **7** | **12** | **44-75 hrs** |

**Revised estimate:** 1.5-2 weeks at 40 hrs/week (solo dev)

---

## Critical Path (Must Do First)

These tasks unblock prototype testing — prioritize in order:

| Priority | Task | Component | Est. Hours | Blocker For |
|----------|------|-----------|------------|-------------|
| 1 | A.2 | JSON data loading | 2-3 | All data-dependent tasks |
| 2 | A.3 | European airport subset | 1-2 | Map accuracy |
| 3 | A.4 | ATR 72-600 data | 1-2 | Aircraft consistency |
| 4 | G.2 | Price elasticity formula | 4-6 | Core loop validation |
| 5 | G.6 | Next-day price delay | 3-6 | Cause-effect testing |
| 6 | E.4 | Demand preview | 2-4 | Price decision feedback |
| 7 | H.3 | Daily summary notification | 2-4 | Revenue feedback |
| 8 | H.4 | Weekly summary report | 2-4 | Results visibility |
| 9 | H.5 | Cause-effect visualization | 2-4 | Core loop clarity |

**Critical path hours:** 20-35 hours

---

## A. Project Setup

### A.1 Initialize Godot project structure ✅ Done
**Estimate:** 2-3 hours  
**Dependencies:** None  
**Status:** Complete — Project structure exists with scenes/, scripts/, data/, assets/

### A.2 Create prototype data loader ⚠️ Needs refinement
**Estimate:** 2-3 hours  
**Dependencies:** A.1  
**Status:** GameData.gd exists but uses hardcoded airport data, not JSON loading  
**Missing:**
- [ ] JSON loader utility for game data
- [ ] Load airports from `prototype-airports.json`
- [ ] Load aircraft from `prototype-aircraft.json`
- [ ] Error handling for malformed data

**CRITICAL PATH**

### A.3 Extract European airport subset from airline-data ❌ TODO
**Estimate:** 1-2 hours  
**Dependencies:** None  
**Status:** Not started — currently using global airports hardcoded in GameData.gd
**Acceptance Criteria:**
- [ ] `prototype-airports.json` with ~30 European airports
- [ ] Includes: IATA code, name, lat/lon, country, city population
- [ ] Mix of hub airports (AMS, FRA, CDG, MUC) and secondary cities
- [ ] Data sourced from `airline-data/airports.csv`

**CRITICAL PATH**

### A.4 Create ATR 72-600 aircraft data ❌ TODO
**Estimate:** 1-2 hours  
**Dependencies:** None  
**Status:** ATR 72-600 exists in aircraft_types.json (160+ types!) but needs isolated prototype file
**Acceptance Criteria:**
- [ ] `prototype-aircraft.json` with ATR 72-600 only
- [ ] Matches specs: capacity=78, range=1528km, speed=556km/h
- [ ] Includes: daily_cost (~€8,000), fuel_burn_per_hour, turnaround_time (45 min)

**CRITICAL PATH**

---

## B. Map & Airports

### B.1 Create world map scene ✅ Done
**Estimate:** 4-6 hours  
**Status:** WorldMap.gd with OpenStreetMap tiles, pan/zoom, bounds

### B.2 Create airport marker scene ✅ Done
**Estimate:** 2-3 hours  
**Status:** Airport markers with hover states, click signals

### B.3 Load and display airports on map ✅ Done
**Estimate:** 3-4 hours  
**Status:** Working — airports positioned by lat/lon
**Note:** Will need update after A.2/A.3 to use JSON loader

### B.4 Implement airport selection ✅ Done
**Estimate:** 2-3 hours  
**Status:** Selection highlighting, route creation flow works

### B.5 Create airport info panel ✅ Done
**Estimate:** 3-4 hours  
**Status:** Floating panel shows airport details on hover/selection

### B.6 Add hub selection at game start ⚠️ Needs refinement
**Estimate:** 4-6 hours  
**Status:** MainMenu.gd has hub selection, but hardcoded to global airports
**Missing:**
- [ ] Limit to 4 European hubs (AMS, FRA, CDG, MUC) for prototype
- [ ] Update to use prototype airport data

---

## C. Route Creation

### C.1 Create route data structure ✅ Done
**Estimate:** 2-3 hours  
**Status:** Route.gd complete with distance calculation (Haversine), pricing, aircraft assignment

### C.2 Implement route creation flow ✅ Done
**Estimate:** 4-6 hours  
**Status:** Two-airport selection creates route, range constraints work

### C.3 Display route lines on map ✅ Done
**Estimate:** 3-4 hours  
**Status:** WorldMap.gd renders route arcs with profitability colors

### C.4 Create route list panel ✅ Done
**Estimate:** 3-4 hours  
**Status:** Sidebar shows route list with selection

### C.5 Implement route deletion ✅ Done
**Estimate:** 2-3 hours  
**Status:** Routes can be removed, aircraft unassigned

---

## D. Aircraft & Assignment

### D.1 Create aircraft instance data structure ✅ Done
**Estimate:** 2-3 hours  
**Status:** AircraftInstance.gd with assignment tracking, condition degradation

### D.2 Create fleet panel ✅ Done
**Estimate:** 3-4 hours  
**Status:** FleetManagementPanel.gd shows fleet with status
**Note:** Currently shows all aircraft types — needs simplification (S.1)

### D.3 Implement aircraft assignment to route ✅ Done
**Estimate:** 3-4 hours  
**Status:** Assignment flow works via RouteConfigDialog

### D.4 Calculate and display flight schedule ⚠️ Needs refinement
**Estimate:** 2-3 hours  
**Status:** Basic utilization calculated, frequency exists
**Missing:**
- [ ] Clear display of "X flights/day, Y hours/day utilization"
- [ ] Show turnaround time impact (45 min)
- [ ] Auto-calculated max frequency

---

## E. Pricing Interface

### E.1 Create route detail panel ✅ Done
**Estimate:** 3-4 hours  
**Status:** RouteConfigDialog shows route details

### E.2 Implement price slider/input ✅ Done
**Estimate:** 3-4 hours  
**Status:** Price inputs exist for economy/business/first
**Note:** Needs simplification to single class (S.6)

### E.3 Implement pricing presets ⚠️ Needs refinement
**Estimate:** 2-4 hours  
**Status:** Base price calculation exists (€0.15/km) but no preset buttons
**Missing:**
- [ ] Three preset buttons: "Aggressive" / "Balanced" / "Premium"
- [ ] -20% / market / +20% logic

### E.4 Show demand impact preview ❌ TODO
**Estimate:** 2-4 hours  
**Dependencies:** E.2, G.1  
**Status:** No real-time demand preview on price change
**Acceptance Criteria:**
- [ ] As price changes, show estimated load factor
- [ ] Visual indicator: green (>80%), yellow (50-80%), red (<50%)
- [ ] Uses elasticity calculation (from G.2)

**CRITICAL PATH**

---

## F. Time System

### F.1 Implement game clock ✅ Done
**Estimate:** 3-4 hours  
**Status:** SimulationEngine.gd tracks week/hour, signals on week complete

### F.2 Implement time controls ✅ Done
**Estimate:** 3-4 hours  
**Status:** 6 speed levels (Paused → Very Fast), TimeSpeedPanel.gd

### F.3 Create flight animation system ✅ Done
**Estimate:** 4-6 hours  
**Status:** PlaneSprite.gd animates planes along routes, WorldMap manages them

### F.4 Implement day tick processing ⚠️ Needs refinement
**Estimate:** 2-3 hours  
**Status:** Weekly processing exists, but no daily tick
**Missing:**
- [ ] Daily (not just weekly) financial updates
- [ ] Day-change signal for UI updates
- [ ] Daily log/history storage

### F.5 Implement skip-to-next-day ✅ Done
**Estimate:** 2-3 hours  
**Status:** Fast-forward speeds effectively skip time

---

## G. Demand & Revenue

### G.1 Implement base demand calculation ✅ Done
**Estimate:** 4-6 hours  
**Status:** MarketAnalysis.gd calculates demand based on population, distance, gravity model

### G.2 Implement price elasticity ⚠️ Needs refinement
**Estimate:** 4-6 hours  
**Status:** SimulationEngine has class distribution but not proper price elasticity curve
**Missing:**
- [ ] `actual_demand = base_demand * (reference_price / actual_price) ^ elasticity`
- [ ] Business elasticity: -0.5, Leisure elasticity: -2.0
- [ ] Weighted average formula
- [ ] Visible impact on demand when price changes

**CRITICAL PATH — Core to testing if pricing feels meaningful**

### G.3 Calculate passengers per flight ✅ Done
**Estimate:** 2-4 hours  
**Status:** SimulationEngine.simulate_route() calculates passengers capped by capacity

### G.4 Implement revenue calculation ✅ Done
**Estimate:** 3-4 hours  
**Status:** Revenue = passengers × price, tracked per route and airline

### G.5 Implement cost calculation ✅ Done
**Estimate:** 3-4 hours  
**Status:** Fuel, crew, maintenance, airport fees calculated in SimulationEngine

### G.6 Implement price-change delay ❌ TODO
**Estimate:** 3-6 hours  
**Dependencies:** E.2, G.2  
**Status:** Prices take effect immediately — no next-day delay
**Acceptance Criteria:**
- [ ] Price changes take effect "next day" (not instantly)
- [ ] Current price vs pending price displayed in UI
- [ ] "Price change pending" indicator on route
- [ ] At day rollover, pending prices become active

**CRITICAL PATH — Essential for cause-effect clarity (prototype-scope.md §8.3)**

---

## H. Revenue Feedback UI

### H.1 Create route performance display ✅ Done
**Estimate:** 4-6 hours  
**Status:** RouteCard shows revenue, profit, passengers
**Note:** May need sparkline/trend visualization

### H.2 Create financial dashboard ✅ Done
**Estimate:** 4-6 hours  
**Status:** FinancesPanel shows balance, weekly P&L, revenue breakdown

### H.3 Implement daily summary notification ❌ TODO
**Estimate:** 2-4 hours  
**Dependencies:** F.4, H.1  
**Status:** No end-of-day notifications
**Acceptance Criteria:**
- [ ] At end of each day, brief notification appears
- [ ] Shows: flights operated, passengers, revenue, profit/loss
- [ ] Auto-dismisses or dismisses on click
- [ ] Non-intrusive (doesn't require confirmation)

**CRITICAL PATH**

### H.4 Implement weekly summary report ⚠️ Needs refinement
**Estimate:** 2-4 hours  
**Status:** Week simulation prints to console, but no popup
**Missing:**
- [ ] Summary popup at end of each week
- [ ] Best/worst performing route
- [ ] "Continue" button to dismiss
- [ ] Clear cause→effect messaging

**CRITICAL PATH**

### H.5 Create cause-effect visualization ❌ TODO
**Estimate:** 2-4 hours  
**Dependencies:** G.6, H.1  
**Status:** No price-change impact visualization
**Acceptance Criteria:**
- [ ] When price change takes effect, highlight the change
- [ ] Show: "Price changed from €X to €Y" with arrow
- [ ] Show: "Load factor changed from X% to Y%"
- [ ] Brief animation to draw attention

**CRITICAL PATH**

---

## S. Simplification Tasks (NEW)

These tasks remove out-of-scope complexity from the current prototype.

### S.1 Reduce aircraft types to ATR 72-600 only 🗑️ Remove
**Estimate:** 2-3 hours  
**Dependencies:** A.4  
**Status:** Currently 160+ aircraft types in aircraft_types.json
**Acceptance Criteria:**
- [ ] GameData.create_aircraft_models() loads only ATR 72-600
- [ ] FleetManagementPanel hides aircraft purchase UI (or limits to ATR 72-600)
- [ ] AircraftPurchaseDialog disabled or simplified
- [ ] Starting aircraft forced to ATR 72-600

### S.2 Reduce AI competitors to 1 static 🗑️ Remove
**Estimate:** 1-2 hours  
**Dependencies:** None  
**Status:** AIController.gd has complex decision-making, multiple competitors
**Acceptance Criteria:**
- [ ] Single AI airline created in GameData.create_ai_airlines()
- [ ] AI has 3-5 fixed routes (no dynamic entry/exit)
- [ ] AI pricing: reactive only (match player within band)
- [ ] Remove AI expansion/contraction logic

### S.3 Hide/disable delegate UI 🗑️ Remove
**Estimate:** 1-2 hours  
**Dependencies:** None  
**Status:** DelegatesPanel, Delegate, DelegateTask, DelegateAssignmentDialog exist
**Acceptance Criteria:**
- [ ] Remove delegate panel from sidebar
- [ ] Disable delegate initialization in GameData
- [ ] Remove delegate task processing from SimulationEngine

### S.4 Hide/disable diplomacy UI 🗑️ Remove
**Estimate:** 1-2 hours  
**Dependencies:** None  
**Status:** CountryRelationsPanel, Country.gd, country_relationships exist
**Acceptance Criteria:**
- [ ] Remove country relations panel from sidebar
- [ ] Disable country initialization
- [ ] Remove relationship tracking

### S.5 Disable tutorial system 🗑️ Remove
**Estimate:** 1-2 hours  
**Dependencies:** None  
**Status:** TutorialManager, TutorialOverlay, TutorialStep active
**Acceptance Criteria:**
- [ ] Set `is_first_time_player = false` by default
- [ ] Remove tutorial auto-start from GameData
- [ ] Hide tutorial UI elements
- [ ] Keep code for later re-enablement

### S.6 Simplify cabin config to single class 🗑️ Remove
**Estimate:** 2-3 hours  
**Dependencies:** None  
**Status:** Economy/Business/First class with separate pricing and capacities
**Acceptance Criteria:**
- [ ] Route.gd: single `price` field (remove class-based pricing)
- [ ] Demand calculation: single passenger type
- [ ] RouteConfigDialog: single price input
- [ ] AircraftConfiguration.gd: simplified to total seats only
- [ ] Remove class distribution logic from SimulationEngine

---

## Unknowns & Decisions Needed

### Flag to @game-designer

| Question | Context | Status |
|----------|---------|--------|
| **Demand constant tuning** | G.1 formula needs tuning for realistic load factors | Pending — test after G.2 implemented |
| **Single-class pricing baseline** | With cabin classes removed, what's the base €/km? | Recommend: €0.10/km baseline |
| **AI competitor route selection** | Which 3-5 routes should the static AI operate? | Need selection criteria |

### Technical Decisions Made

| Decision | Rationale |
|----------|-----------|
| Keep OSM tile map | Already working, no need to change |
| Keep weekly simulation cycle | Matches route-economics spec |
| Remove cabin classes | Simplifies core loop testing |

---

## Phase 1 Exit Criteria

Before moving to Phase 2, validate:

- [ ] Player can create a route from European hub to another European airport
- [ ] Player can set a price for that route (single class)
- [ ] Price changes take effect next day (not instantly)
- [ ] Time can be advanced (play/fast-forward)
- [ ] Flights visibly operate on the map
- [ ] Revenue and costs are calculated and displayed
- [ ] Player can observe the impact of price changes on load factor and revenue
- [ ] Weekly summary shows clear cause→effect
- [ ] The loop feels connected: "I changed price → I see different results"

**Internal playtesting:** 30-60 minutes with designer. Does it feel like a game yet?

---

## Time Summary

| Category | Hours |
|----------|-------|
| Critical path tasks | 20-35 |
| Simplification tasks | 8-14 |
| Remaining refinements | 16-26 |
| **Total remaining** | **44-75 hours** |

**Calendar estimate:** 1.5-2 weeks at 40 hrs/week (solo dev)

---

## Document History

| Version | Date | Changes |
|---------|------|---------|
| 0.1 | January 2026 | Initial Phase 1 task breakdown |
| 0.2 | January 2026 | Revised based on Godot Prototype Audit: marked 26 tasks done, 7 partial, added 6 simplification tasks. Reduced estimate from 106-158 hrs to 44-75 hrs. Identified critical path. |
