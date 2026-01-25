# Maintenance System — Detailed Specification

**Version:** 0.1  
**Date:** January 2026  
**Companion to:** Game Design Document v0.7, Network Scheduler Spec v0.1

---

## Overview

This document specifies how aircraft maintenance works in Airliner — scheduled checks, unscheduled repairs, MRO selection, and the trade-offs between cost, reliability, and availability.

**Design Philosophy:** Maintenance is the hidden cost of aviation. Good maintenance prevents disasters; poor maintenance creates them. Players should feel the weight of keeping aircraft airworthy without drowning in technical minutiae.

**Core Loop:** Fly → Accrue hours/cycles → Schedule maintenance → Select MRO → Aircraft unavailable → Return to service

---

## 1. Maintenance Types

### 1.1 Scheduled Maintenance

| Check | Interval | Duration | Location | Cost Range |
|-------|----------|----------|----------|------------|
| **Line check** | Daily/overnight | 2-6 hours | Gate | $2-5K |
| **A check** | 400-600 FH | 1-2 days | Hangar | $50-150K |
| **B check** | 6-8 months | 1-3 days | Hangar | $100-300K |
| **C check** | 18-24 months | 1-2 weeks | MRO facility | $500K-1.5M |
| **D check** | 6-10 years | 4-8 weeks | MRO facility | $3-10M |

### 1.2 Check Scope

| Check | Typical Work |
|-------|--------------|
| **Line** | Walk-around, fluid levels, MEL items, cleaning |
| **A** | Detailed inspection, filter changes, lubrication |
| **B** | Specific system checks (often combined with A) |
| **C** | Structural inspection, system overhauls, interior work |
| **D** | Complete structural inspection, paint strip, major overhauls |

### 1.3 Unscheduled Maintenance

| Type | Trigger | Impact | Resolution |
|------|---------|--------|------------|
| **MEL item** | Component failure | Dispatch restrictions | Fix within MEL timeframe |
| **AOG** | Critical failure | Aircraft grounded | Emergency repair |
| **Bird strike** | Incident | Inspection required | 2-48 hours |
| **Hard landing** | Incident | Inspection required | 4-72 hours |
| **Lightning strike** | Incident | Inspection required | 2-24 hours |

---

## 2. Maintenance Tracking

### 2.1 Aircraft Status Display

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  MAINTENANCE STATUS · F-GKXA · Boeing 737-800                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  AIRFRAME                           ENGINES                                 │
│  Hours: 28,420                      #1: CFM56-7B24 · 8,240 hrs to shop     │
│  Cycles: 14,210                     #2: CFM56-7B24 · 9,120 hrs to shop     │
│  Age: 8.4 years                                                            │
│                                                                             │
│  NEXT SCHEDULED MAINTENANCE                                                │
│  ──────────────────────────────────────────────────────────────────────── │
│  A-check due:        245 flight hours (~3 weeks)     [Schedule]            │
│  C-check due:        1,840 flight hours (~4 months)                        │
│  Landing gear OH:    2,100 cycles (~18 months)                             │
│                                                                             │
│  MEL ITEMS                                                                  │
│  ──────────────────────────────────────────────────────────────────────── │
│  ⚠ APU inoperative · Cat B · Fix within 10 days     [View] [Schedule fix] │
│                                                                             │
│  MAINTENANCE HISTORY                                                        │
│  ──────────────────────────────────────────────────────────────────────── │
│  Dec 2025:  Line check (overnight, LYS)                                    │
│  Nov 2025:  A-check (2 days, Lyon MRO)                                     │
│  Jul 2025:  C-check (10 days, Lufthansa Technik)                          │
│  Mar 2024:  Engine #2 shop visit (42 days, GE)                            │
│                                                                             │
│  RELIABILITY THIS YEAR                                                      │
│  Dispatch reliability: 98.2%  │  Technical delays: 4  │  AOG events: 1    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2.2 Fleet Maintenance Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  FLEET MAINTENANCE SCHEDULE                                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  AIRCRAFT      TYPE        NEXT CHECK      DUE IN        STATUS            │
│  F-GKXA       737-800      A-check        245 FH        ● Plan now         │
│  F-GKXB       737-800      Line check     12 hrs        ● Tonight          │
│  F-GKXC       A320         C-check        IN PROGRESS   ■ At MRO           │
│  F-GKXD       ATR 72       A-check        890 FH        ○ OK               │
│  F-GKXE       ATR 72       Line check     8 hrs         ● Tonight          │
│                                                                             │
│  UPCOMING 30 DAYS                                                           │
│  Jan 18:  F-GKXA A-check (2 days, Lyon MRO)                                │
│  Jan 24:  F-GKXC returns from C-check                                      │
│  Feb 02:  F-GKXB A-check (scheduled)                                       │
│                                                                             │
│  [Schedule check] [View calendar] [MRO management]                         │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. MRO Selection

### 3.1 MRO Types

| Type | Capabilities | Cost | Turnaround | Locations |
|------|--------------|------|------------|-----------|
| **In-house** | Line, A (if facility) | Lowest | Fast | Your base |
| **OEM** | All, including engines | Highest | Variable | Limited |
| **Third-party major** | All | Medium-high | Good | Regional |
| **Third-party regional** | Line, A, B | Low | Fast | Widespread |
| **Engine specialist** | Engines only | Premium | 30-60 days | Few |

### 3.2 MRO Comparison

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  SELECT MRO · C-CHECK · F-GKXA · Boeing 737-800                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  MRO                      COST        TIME      QUALITY   SLOT AVAIL       │
│                                                                             │
│  ★ Lufthansa Technik     $1.24M      12 days   ████████  Feb 15-28        │
│     Hamburg, Germany     (+15%)      (+2 days)  Excellent                  │
│     OEM-approved, extensive experience                                      │
│                                                                             │
│  ○ Lyon MRO Services     $1.08M      10 days   ██████░░  Jan 20-30        │
│     Lyon, France         (base)      (base)    Good                        │
│     Your contracted provider, good relationship                            │
│                                                                             │
│  ○ IAG Technik           $980K       14 days   █████░░░  Mar 1-15         │
│     Madrid, Spain        (-10%)      (+4 days) Adequate                    │
│     Budget option, longer turnaround                                       │
│                                                                             │
│  ○ Turkish Technic       $890K       11 days   ██████░░  Feb 1-12         │
│     Istanbul, Turkey     (-18%)      (+1 day)  Good                        │
│     Competitive pricing, requires ferry flight                             │
│                                                                             │
│  Recommendation: Lyon MRO (contracted, fast slot, home base)               │
│                                                                             │
│  [Confirm selection] [Request quotes] [Defer]                              │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3.3 MRO Contracts

Long-term contracts provide benefits:

| Contract Type | Commitment | Discount | Benefits |
|---------------|------------|----------|----------|
| **Preferred** | First right of refusal | 5-10% | Priority slots |
| **Volume** | Minimum annual spend | 10-15% | Fixed rates |
| **Exclusive** | All work to one MRO | 15-20% | Guaranteed slots |
| **Power-by-hour** | Per flight hour fee | Variable | Predictable costs |

---

## 4. Cost Structure

### 4.1 Check Costs by Aircraft Type

| Type | A-Check | C-Check | D-Check | Annual MX/FH |
|------|---------|---------|---------|--------------|
| ATR 72 | $35K | $350K | $2.5M | $400 |
| 737-800 | $80K | $800K | $6M | $700 |
| A320neo | $90K | $900K | $6.5M | $750 |
| 787-9 | $150K | $2M | $15M | $1,200 |
| 777-300ER | $180K | $2.5M | $18M | $1,500 |

### 4.2 Engine Costs

| Engine Type | Shop Visit | Time Between OH | Notes |
|-------------|------------|-----------------|-------|
| CFM56-7B | $3-5M | 20-25K cycles | 737 Classic/NG |
| CFM LEAP-1A | $4-6M | 20-25K cycles | A320neo |
| CFM LEAP-1B | $4-6M | 20-25K cycles | 737 MAX |
| GEnx-1B | $6-10M | 15-20K cycles | 787 |
| Trent XWB | $8-12M | 15-20K cycles | A350 |

### 4.3 Maintenance Reserves

For leased aircraft, escrowed funds:

| Component | Reserve Rate | Notes |
|-----------|--------------|-------|
| Airframe | $150-250/FH | Covers checks |
| Engines | $80-150/cycle | Per engine |
| Landing gear | $30-50/cycle | Overhaul reserve |
| APU | $50-80/FH | If included |

---

## 5. Reliability & Failures

### 5.1 Dispatch Reliability

Target: >98% dispatch reliability

| Factor | Impact on Reliability |
|--------|----------------------|
| Aircraft age | Older = lower reliability |
| Maintenance quality | Better MRO = higher reliability |
| Fleet commonality | Spares availability |
| Operating environment | Harsh = more failures |
| MEL management | Deferred items compound |

### 5.2 Failure Events

Random events based on:
- Aircraft age and condition
- Maintenance history
- Operating environment
- Random probability

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  ⚠ TECHNICAL EVENT                                                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Aircraft: F-GKXA (737-800)                                                │
│  Flight: MA1234 LYS-CDG                                                    │
│  Status: GROUNDED (AOG)                                                    │
│                                                                             │
│  Issue: Hydraulic system fault - System B pressure low                     │
│  Detected during: Pre-flight check                                         │
│                                                                             │
│  Options:                                                                   │
│  1. Repair at LYS (2-4 hours, $15K) - Parts available                     │
│  2. Ferry to maintenance base (requires MEL dispatch)                      │
│  3. Call mobile repair team ($8K callout + $15K repair)                   │
│                                                                             │
│  Flight impact:                                                             │
│  → MA1234: Delay 3+ hours or cancel                                        │
│  → 142 passengers affected                                                 │
│  → 4 downstream flights may be affected                                    │
│                                                                             │
│  [Repair at LYS] [Call mobile team] [Cancel flight] [View alternatives]   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 5.3 MEL (Minimum Equipment List)

Aircraft can dispatch with certain items inoperative:

| MEL Category | Repair Deadline | Example Items |
|--------------|-----------------|---------------|
| **A** | As specified | Varies |
| **B** | 3 calendar days | APU, some instruments |
| **C** | 10 calendar days | Galley equipment, seats |
| **D** | 120 calendar days | Convenience items |

---

## 6. Data Model Integration

### 6.1 Entities

**MaintenanceEvent** — Scheduled and unscheduled maintenance

| Field | Type | Purpose |
|-------|------|---------|
| `id` | UUID | Primary key |
| `aircraft_id` | FK | Aircraft reference |
| `event_type` | enum | LINE / A_CHECK / C_CHECK / etc. |
| `scheduled_start` | datetime | Planned start |
| `actual_start` | datetime? | When started |
| `scheduled_end` | datetime | Planned completion |
| `actual_end` | datetime? | When completed |
| `mro_id` | FK | MRO provider |
| `estimated_cost` | decimal | Budget |
| `actual_cost` | decimal? | Final cost |
| `findings` | json | Discovered issues |
| `status` | enum | SCHEDULED / IN_PROGRESS / COMPLETED |

**MROProvider** — Maintenance facilities

| Field | Type | Purpose |
|-------|------|---------|
| `id` | UUID | Primary key |
| `name` | string | Provider name |
| `location` | FK → Airport | Base location |
| `capabilities` | json | What checks they can do |
| `aircraft_types` | string[] | Approved types |
| `quality_rating` | int | 1-100 |
| `cost_factor` | float | Relative to baseline |
| `turnaround_factor` | float | Speed factor |

### 6.2 New Enumerations

```yaml
MaintenanceEventType:
  LINE_CHECK
  A_CHECK
  B_CHECK
  C_CHECK
  D_CHECK
  ENGINE_SHOP_VISIT
  LANDING_GEAR_OVERHAUL
  APU_OVERHAUL
  UNSCHEDULED_REPAIR
  AOG_REPAIR

MaintenanceStatus:
  SCHEDULED
  IN_PROGRESS
  DELAYED
  COMPLETED
  CANCELLED

MELCategory:
  A    # As specified
  B    # 3 days
  C    # 10 days  
  D    # 120 days
```

---

## Document History

| Version | Date | Changes |
|---------|------|---------|
| 0.1 | January 2026 | Initial specification |
