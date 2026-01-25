# Network Scheduler — Detailed Specification

**Version:** 0.1  
**Date:** January 2026  
**Companion to:** Game Design Document v0.7, Art Bible v0.1

---

## Overview

The Network Scheduler is the command center for aircraft utilization. It visualizes time, allocates aircraft to flights, manages maintenance windows, and detects scheduling conflicts.

**Design Philosophy:** Visualize efficiency. Gaps are wasted money. Overlaps are operational failures. The player should *feel* utilization in the visual layout.

**Core Insight:** A well-utilized aircraft makes money. An idle aircraft costs money. The scheduler makes this visible at a glance.

---

## 1. Access Points

Players access the Network Scheduler from:

| Entry Point | Context |
|-------------|---------|
| Main menu → Operations → Scheduler | Full scheduler view |
| Fleet view → Aircraft → [View schedule] | Single aircraft focus |
| Route view → [View aircraft assignments] | Route-centric view |
| Alert: "Scheduling conflict detected" | Jump to conflict |
| Maintenance scheduled notification | Jump to maintenance block |

---

## 2. Core Visualization

### 2.1 The Gantt Chart

**Primary visual:** Horizontal timeline with aircraft rows.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  NETWORK SCHEDULER · Week of Jan 15, 2026                    [Day][Week][Mo]│
├─────────────────────────────────────────────────────────────────────────────┤
│  TIME →     06:00   09:00   12:00   15:00   18:00   21:00   00:00   03:00   │
├─────────────────────────────────────────────────────────────────────────────┤
│  F-GKXA     ████████░░████████████████░░░░████████████░░░░░░░░░░░░░░░░░░░░░ │
│  737-800    LYS-CDG  ║ CDG-NCE      CDG     NCE-LYS   CDG     (idle)        │
│             0845→1015║ 1100→1215    1330    1500→1630 1745                  │
│                      ║                                                      │
│  F-GKXB     ░░░░████████████████████████████████░░░░░░░░░░████████████░░░░ │
│  737-800    idle LYS-MRS    MRS-ORY    ORY-LYS       idle   LYS-BCN  BCN    │
│                                                                             │
│  F-GKXC     ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░░░░░░░ │
│  A320       ═══════════════ C-CHECK (3 days) ═══════════════   returning    │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│  UTILIZATION: F-GKXA 8.2 hrs │ F-GKXB 10.1 hrs │ F-GKXC 0.0 hrs (mx)       │
│  FLEET AVG: 6.1 hrs/day │ TARGET: 8.0 hrs │ ▼ UNDERPERFORMING             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2.2 Visual Elements

| Element | Appearance | Meaning |
|---------|------------|---------|
| Green block (████) | Solid green | Flying — revenue time |
| Amber block (░░░░) | Amber/yellow | Turnaround — ground time |
| Red block (▓▓▓▓) | Red hatched | Maintenance — scheduled downtime |
| Gray block | Light gray | Available — unutilized time |
| Purple block | Purple | Conflict — overlapping assignments |
| Blue outline | Blue border | Selected/focused flight |

### 2.3 Block Information

Hovering over a block shows:

```
┌─────────────────────────────────┐
│  LYS → CDG                      │
│  Flight: MA 1234                │
│  Depart: 08:45 local           │
│  Arrive: 10:15 local           │
│  Block time: 1h 30m            │
│  Aircraft: F-GKXA (737-800)    │
│  Load: 142/174 (82%)           │
│  Status: ● On time             │
│                                 │
│  [Edit] [Reassign] [Cancel]    │
└─────────────────────────────────┘
```

---

## 3. Time Scales

### 3.1 View Options

| View | Time Span | Grid Resolution | Use Case |
|------|-----------|-----------------|----------|
| Day | 24 hours | 15 minutes | Detailed daily ops |
| Week | 7 days | 1 hour | Planning view |
| Month | 30 days | 6 hours | Strategic overview |
| Quarter | 90 days | 1 day | Fleet planning |

### 3.2 Navigation

| Action | Control |
|--------|---------|
| Scroll time | Mouse wheel / drag |
| Zoom | Ctrl + wheel |
| Jump to date | Calendar picker |
| Jump to now | "Today" button |
| Jump to conflict | Click alert |

---

## 4. Block Types

### 4.1 Flying Blocks

| Property | Description |
|----------|-------------|
| Color | Green (`#00c853`) |
| Content | Route code, times, load factor |
| Width | Proportional to block time |
| Interactions | Click to select, drag to reassign |

### 4.2 Turnaround Blocks

| Property | Description |
|----------|-------------|
| Color | Amber (`#ffb000`) |
| Content | Station code, duration |
| Width | Minimum 30-90 min depending on aircraft |
| Auto-calculated | Yes — inserted between flights |

**Turnaround minimums by type:**

| Aircraft Category | Domestic | International |
|-------------------|----------|---------------|
| Regional (ATR, CRJ) | 25 min | 35 min |
| Narrowbody (737, A320) | 35 min | 50 min |
| Widebody (787, A350) | 60 min | 90 min |
| Heavy (747, A380) | 75 min | 120 min |

### 4.3 Maintenance Blocks

| Property | Description |
|----------|-------------|
| Color | Red (`#ff3b4f`) hatched |
| Content | Check type, duration, MRO |
| Width | Based on check duration |
| Locked | Cannot be moved by player |

**Check durations:**

| Check Type | Duration | Typical Interval |
|------------|----------|------------------|
| Line check | 2-4 hours | Daily |
| A check | 1-2 days | 400-600 flight hours |
| B check | 1-3 days | 6-8 months |
| C check | 1-2 weeks | 18-24 months |
| D check | 4-8 weeks | 6-10 years |

### 4.4 Conflict Blocks

| Property | Description |
|----------|-------------|
| Color | Purple (`#9c27b0`) pulsing |
| Content | "CONFLICT" label |
| Alert | Generates system notification |
| Resolution | Must be resolved before simulation advances |

---

## 5. Conflict Detection

### 5.1 Conflict Types

| Conflict | Description | Severity |
|----------|-------------|----------|
| **Overlap** | Aircraft assigned to two flights simultaneously | Critical |
| **Turnaround violation** | Insufficient ground time between flights | Critical |
| **Location mismatch** | Flight departs from wrong airport | Critical |
| **Maintenance override** | Flight scheduled during maintenance | Critical |
| **Crew timeout** | Exceeds crew duty limits | Warning |
| **Curfew violation** | Operation during airport curfew | Warning |
| **Range exceeded** | Route exceeds aircraft range | Error (prevented) |

### 5.2 Conflict Visualization

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  ⚠ SCHEDULING CONFLICTS (2)                                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  CRITICAL: Aircraft overlap                                                 │
│  F-GKXA is assigned to MA1234 and MA1456 at 14:00                          │
│  [View in scheduler] [Auto-resolve] [Dismiss]                              │
│                                                                             │
│  WARNING: Turnaround violation                                              │
│  F-GKXB has only 25 min at CDG (minimum: 35 min)                           │
│  [Adjust timing] [Accept risk] [Dismiss]                                   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 5.3 Auto-Resolution

When player clicks "Auto-resolve":

1. System identifies alternative aircraft with matching type
2. If available, proposes swap
3. If no alternative, proposes flight cancellation
4. Player confirms or manually resolves

---

## 6. Utilization Metrics

### 6.1 Key Metrics

| Metric | Calculation | Target |
|--------|-------------|--------|
| **Block hours/day** | Flying time ÷ calendar days | 8-12 hrs |
| **Utilization %** | Block hours ÷ 24 | 35-50% |
| **Revenue hours/day** | Passenger-carrying time | 7-10 hrs |
| **Maintenance ratio** | MX time ÷ total time | <8% |
| **Idle ratio** | Unscheduled time ÷ total | <15% |

### 6.2 Utilization Display

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  FLEET UTILIZATION                                           This week      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  AIRCRAFT          BLOCK HRS    UTIL %    REV/BLK HR    STATUS             │
│  F-GKXA 737-800      52.4       31.2%      $4,820       ● Below target     │
│  F-GKXB 737-800      68.2       40.6%      $5,140       ● On target        │
│  F-GKXC A320         0.0        0.0%       —            ■ In maintenance   │
│  F-GKXD ATR 72       71.8       42.7%      $2,890       ● On target        │
│                                                                             │
│  FLEET AVERAGE       48.1       28.6%      $4,280       ▼ Underperforming  │
│  TARGET                         35.0%      $5,000                          │
│                                                                             │
│  [View details] [Optimization suggestions]                                 │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 6.3 Utilization Targets by Aircraft Type

| Aircraft Type | Daily Target | Optimal | Maximum |
|---------------|--------------|---------|---------|
| Regional | 6-8 hrs | 7 hrs | 10 hrs |
| Narrowbody | 8-10 hrs | 9 hrs | 12 hrs |
| Widebody | 12-16 hrs | 14 hrs | 18 hrs |

---

## 7. Crew Integration

### 7.1 Crew Overlay

Optional layer showing crew assignments:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  [✓] Show crew assignments                                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  F-GKXA     ████████░░████████████████░░░░████████████                     │
│  Crew A     ════════════════════════════════════════════ (Capt. Dubois)    │
│  Crew B                                 ════════════════ (Capt. Martin)     │
│                                                                             │
│  ⚠ Crew A approaching duty limit (11.5 / 12.0 hrs)                         │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 7.2 Crew Constraints

| Constraint | Limit | Configurable |
|------------|-------|--------------|
| Max duty period | 10-14 hrs | By regulation |
| Min rest | 8-12 hrs | By regulation |
| Max flight time/day | 8-10 hrs | By regulation |
| Max sectors/day | 4-6 | By contract |
| Required crew/flight | 2 pilots + cabin | By aircraft |

---

## 8. Maintenance Scheduling

### 8.1 Maintenance Warnings

System alerts when maintenance is approaching:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  ⚙ MAINTENANCE APPROACHING                                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  F-GKXA · Boeing 737-800                                                    │
│  A-check due in: 42 flight hours (est. Jan 22)                             │
│  Duration: 24-36 hours                                                      │
│                                                                             │
│  Suggested window: Jan 22-23 (low demand period)                           │
│  MRO: Lyon MRO Services (contracted)                                       │
│                                                                             │
│  [Schedule now] [Remind later] [View MRO options]                          │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 8.2 Maintenance Integration

| Feature | Description |
|---------|-------------|
| Auto-blocking | System reserves time when check due |
| MRO selection | Choose provider based on cost/speed |
| Slot management | Coordinate with MRO availability |
| AOG handling | Emergency maintenance disrupts schedule |

---

## 9. Schedule Operations

### 9.1 Drag-and-Drop Operations

| Operation | Action | Result |
|-----------|--------|--------|
| Move flight | Drag block left/right | Changes departure time |
| Reassign aircraft | Drag block to different row | Changes aircraft assignment |
| Swap aircraft | Drag onto another block | Swaps assignments |
| Cancel flight | Drag to trash zone | Removes from schedule |

### 9.2 Context Menu

Right-click on any block:

```
┌─────────────────────────┐
│  Edit flight details    │
│  Reassign aircraft      │
│  Duplicate flight       │
│  ──────────────────────│
│  View route economics   │
│  View aircraft status   │
│  ──────────────────────│
│  Cancel flight          │
│  Cancel rotation        │
└─────────────────────────┘
```

### 9.3 Bulk Operations

| Operation | Scope | Use Case |
|-----------|-------|----------|
| Select multiple | Ctrl+click | Edit several flights |
| Select rotation | Double-click | Select full day rotation |
| Copy schedule | Ctrl+C → Ctrl+V | Replicate to another day |
| Clear day | Select all → Delete | Start fresh |

---

## 10. Schedule Views

### 10.1 Aircraft View (Default)

- Rows: Aircraft (tail numbers)
- Columns: Time
- Best for: Fleet utilization, aircraft-centric planning

### 10.2 Route View

- Rows: Routes (origin-destination pairs)
- Columns: Time
- Best for: Frequency planning, competitive analysis

### 10.3 Hub View

- Rows: Banks/waves at hub
- Columns: Connecting flights
- Best for: Hub-and-spoke optimization

### 10.4 Maintenance View

- Focus: Aircraft approaching/in maintenance
- Shows: Check status, MRO assignments, return dates
- Best for: Maintenance planning

---

## 11. Real-Time Updates

### 11.1 Live Status

During gameplay, schedule reflects actual operations:

| Status | Indicator | Meaning |
|--------|-----------|---------|
| On time | Green dot | Within 15 min of schedule |
| Delayed | Amber dot | 15-60 min delay |
| Significantly delayed | Red dot | >60 min delay |
| Cancelled | X mark | Flight will not operate |
| Completed | Checkmark | Flight has landed |

### 11.2 Disruption Propagation

When delays occur, system shows downstream impact:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  ⚠ DISRUPTION CASCADE                                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Root cause: MA1234 LYS-CDG delayed 45 min (weather)                       │
│                                                                             │
│  Affected flights:                                                          │
│  → MA1456 CDG-NCE    now departs 12:15 (+45 min)                           │
│  → MA1567 NCE-LYS    now departs 14:00 (+45 min)                           │
│  → MA1678 LYS-MRS    now departs 16:30 (+45 min) ⚠ Crew timeout risk       │
│                                                                             │
│  Options:                                                                   │
│  [Accept delays] [Swap aircraft] [Cancel MA1678] [Reassign crew]           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 12. Optimization Suggestions

### 12.1 AI Advisor

System can suggest schedule improvements:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  💡 OPTIMIZATION SUGGESTIONS                                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. Swap F-GKXA and F-GKXB on Thursday                                     │
│     → Reduces total ground time by 2.1 hours                               │
│     → Saves est. $1,200 in crew costs                                      │
│     [Apply] [Details] [Dismiss]                                            │
│                                                                             │
│  2. Add red-eye LYS-CDG on Friday                                          │
│     → Uses 3.5 hrs of idle time                                            │
│     → Est. revenue: $8,400                                                 │
│     [Schedule] [Details] [Dismiss]                                         │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 12.2 Optimization Goals

Player can prioritize:

| Goal | Trade-off |
|------|-----------|
| Maximum utilization | May increase crew costs |
| Minimum costs | May reduce frequencies |
| Best connections | May create idle time |
| Crew quality of life | May reduce utilization |

---

## 13. Data Model Integration

### 13.1 Entities Used

| Entity | Purpose |
|--------|---------|
| `Aircraft` | Row labels, constraints |
| `Schedule` | Recurring patterns |
| `Flight` | Individual block instances |
| `Route` | Flight endpoints |
| `CrewAssignment` | Crew overlay |
| `MaintenanceEvent` | Maintenance blocks |

### 13.2 New/Updated Fields

**Flight entity additions:**

| Field | Type | Purpose |
|-------|------|---------|
| `scheduled_departure` | datetime | Planned time |
| `actual_departure` | datetime? | Real time (if operated) |
| `delay_minutes` | int | Delay amount |
| `delay_reason` | enum | Cause of delay |
| `status` | enum | SCHEDULED / BOARDING / DEPARTED / ARRIVED / CANCELLED |

---

## 14. Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `T` | Jump to today |
| `D` / `W` / `M` | Switch to Day / Week / Month view |
| `←` / `→` | Scroll time |
| `+` / `-` | Zoom in / out |
| `Ctrl+F` | Find flight |
| `Ctrl+C` | Copy selected |
| `Ctrl+V` | Paste schedule |
| `Delete` | Cancel selected flight |
| `Esc` | Deselect all |
| `Space` | Toggle crew overlay |

---

## 15. Performance Considerations

| Scenario | Target |
|----------|--------|
| Initial load (week view, 20 aircraft) | <1 second |
| Scroll/pan | 60 fps |
| Drag-and-drop feedback | Instant (<50ms) |
| Conflict detection | <200ms |
| Full schedule recalculation | <2 seconds |

### 15.1 Large Fleet Handling

For fleets >50 aircraft:
- Virtual scrolling (render visible rows only)
- Deferred conflict checking
- Background optimization calculations

---

## 16. Audio Feedback

| Action | Sound |
|--------|-------|
| Drop flight (valid) | Soft click |
| Drop flight (invalid) | Rejection buzz |
| Conflict created | Alert tone |
| Conflict resolved | Resolution chime |
| Schedule saved | Confirmation tone |
| Time advance | Subtle tick |

---

## 17. Slot Management

At slot-controlled airports, the scheduler must respect slot allocations.

### 17.1 Slot Visualization

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  SLOT PORTFOLIO · London Heathrow (LHR)                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  YOUR SLOTS: 14 pairs (28 movements/day)                                   │
│  Season: Winter 2026                                                        │
│                                                                             │
│  MORNING BANK (06:00-10:00)                                                │
│  06:15  ██ LYS-LHR  MA301  │  06:45  ██ LHR-LYS  MA302                     │
│  08:30  ██ CDG-LHR  MA401  │  09:15  ██ LHR-CDG  MA402                     │
│  09:45  ░░ (unused)        │  10:00  ░░ (unused)  ⚠ Use-it-or-lose-it      │
│                                                                             │
│  MIDDAY (10:00-14:00)                                                      │
│  11:00  ██ NCE-LHR  MA501  │  12:30  ██ LHR-NCE  MA502                     │
│  13:00  ██ MRS-LHR  MA601  │  13:45  ██ LHR-MRS  MA602                     │
│                                                                             │
│  EVENING BANK (16:00-20:00)                                                │
│  16:30  ██ LYS-LHR  MA303  │  17:15  ██ LHR-LYS  MA304                     │
│  18:00  ██ CDG-LHR  MA403  │  19:00  ██ LHR-CDG  MA404                     │
│  19:30  ██ BCN-LHR  MA701  │  20:15  ██ LHR-BCN  MA702                     │
│                                                                             │
│  UTILIZATION: 12/14 pairs (86%)  │  Min required: 80%                      │
│                                                                             │
│  [Acquire slots] [Trade slots] [View competitors] [Slot history]           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 17.2 Slot Rules

| Rule | Description |
|------|-------------|
| **Use-it-or-lose-it** | Must use 80% of slots or forfeit next season |
| **Grandfather rights** | Used slots carried forward automatically |
| **New entrant pool** | 50% of surrendered slots go to new entrants |
| **Slot pairs** | Arrival + departure must be matched |
| **Seasonal** | Slots allocated per IATA season (Summer/Winter) |

### 17.3 Slot Acquisition

| Channel | Cost | Lead Time | Notes |
|---------|------|-----------|-------|
| **Coordinator allocation** | Free | 6 months | New entrant priority |
| **Secondary market** | $2-50M/pair | 1-3 months | Varies by airport |
| **Lease** | $50-500K/season | 1 month | Temporary access |
| **Swap** | Varies | 2-4 weeks | Trade with competitor |
| **Babysitting** | Revenue share | Immediate | Operate for slot holder |

### 17.4 Slot Scarcity by Airport

| Category | Examples | Availability | Typical Price/Pair |
|----------|----------|--------------|-------------------|
| **Level 3 (Coordinated)** | LHR, JFK, HND | Very scarce | $15-50M |
| **Level 3 (Easier)** | CDG, FRA, SIN | Moderate | $2-10M |
| **Level 2 (Schedules facilitated)** | Most major airports | Available | $0.5-2M |
| **Level 1 (Uncoordinated)** | Regional airports | Open | N/A |

### 17.5 Slot Conflict Detection

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  ⚠ SLOT VIOLATION                                                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  MA701 LYS-LHR scheduled for 08:45                                         │
│  BUT you have no slot at LHR between 08:00-09:00                           │
│                                                                             │
│  Options:                                                                   │
│  1. Move to 09:45 slot (available)                                         │
│  2. Acquire 08:30 slot from British Airways ($18M)                         │
│  3. Cancel flight                                                          │
│                                                                             │
│  [Move to 09:45] [View slot market] [Cancel]                               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 17.6 Slot Data Model

**Slot entity:** (see data-model.md)

| Field | Type | Purpose |
|-------|------|---------|
| `airport_id` | FK | Which airport |
| `airline_id` | FK | Slot holder |
| `time_window` | string | "0600-0700" |
| `day_type` | enum | WEEKDAY / WEEKEND / ALL |
| `season` | enum | SUMMER / WINTER |
| `acquired_date` | date | When obtained |
| `acquisition_method` | enum | GRANDFATHER / PURCHASE / ALLOCATION / LEASE |
| `cost` | int? | If purchased |
| `usage_count` | int | Times used this season |
| `usage_required` | int | 80% of available days |

---

## 18. Future Considerations

Not in v1.0, but designed for:

- **Disruption recovery mode** — Mass rebooking after weather/strikes
- **What-if scenarios** — Test schedule changes before committing
- **AI schedule optimization** — Suggest improved rotations
- **Codeshare visualization** — Show partner flights
- **Historical comparison** — Compare current vs past schedules

---

## Document History

| Version | Date | Changes |
|---------|------|---------|
| 0.1 | January 2026 | Initial specification |
| 0.2 | January 2026 | Added Section 17: Slot Management |
