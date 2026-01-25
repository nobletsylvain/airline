# Living Flight — Detailed Specification

**Version:** 0.1  
**Date:** January 2026  
**Companion to:** Game Design Document v0.7, Cabin Designer Spec v0.1

---

## Overview

The Living Flight system lets players observe their airline in operation — watching passengers react to cabin configurations, crew manage service, and flights unfold in real-time.

**Design Philosophy:** Your airline isn't abstract numbers. It's people in tubes crossing the planet. The Living Flight makes your decisions tangible by showing their consequences on actual passengers.

**Core Purpose:** Validation, not gameplay. This is observation mode — no decisions happen here. It exists to make cabin configuration and service choices feel real.

---

## 1. View Hierarchy

### 1.1 Access Levels

| Level | View | What You See | Entry Point |
|-------|------|--------------|-------------|
| **Globe** | Network map | Route arcs, fleet dots moving | Map screen |
| **Follow** | Aircraft exterior | Single plane along route | Click aircraft on map |
| **Cabin** | Interior cross-section | Passengers, crew, service | "Enter cabin" from Follow |

### 1.2 View Transitions

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  GLOBE VIEW                                                                 │
│  ○ Your aircraft shown as dots on route arcs                               │
│  ○ Click any dot to select flight                                          │
│  ○ Flight info panel appears                                               │
│                    ↓ [Follow]                                              │
├─────────────────────────────────────────────────────────────────────────────┤
│  FOLLOW VIEW                                                                │
│  ○ Exterior view of selected aircraft                                      │
│  ○ Moving along route at game speed                                        │
│  ○ Flight data overlay (altitude, speed, ETA)                              │
│                    ↓ [Enter Cabin]                                         │
├─────────────────────────────────────────────────────────────────────────────┤
│  CABIN VIEW                                                                 │
│  ○ Cross-section interior                                                  │
│  ○ Passengers visible in seats                                             │
│  ○ Crew moving, service in progress                                        │
│  ○ Mood indicators on passengers                                           │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Cabin View

### 2.1 Visual Layout

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  MA 1234 · LYS → JFK · A350-900 · Cruise at FL380                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  BUSINESS CLASS                          ECONOMY CLASS                      │
│  ┌─┐ ┌─┐   ┌─┐ ┌─┐                      ┌─┬─┬─┐ ┌─┬─┬─┬─┬─┬─┐ ┌─┬─┬─┐     │
│  │😊│ │😴│   │😐│ │🍽│                      │😊│😴│😐│ │😊│😊│🍽│😴│😐│😊│ │😴│😊│😐│     │
│  └─┘ └─┘   └─┘ └─┘                      └─┴─┴─┘ └─┴─┴─┴─┴─┴─┘ └─┴─┴─┘     │
│  ┌─┐ ┌─┐   ┌─┐ ┌─┐                      ┌─┬─┬─┐ ┌─┬─┬─┬─┬─┬─┐ ┌─┬─┬─┐     │
│  │😊│ │😊│   │😴│ │😊│                      │😐│😊│😴│ │😤│😐│😊│😊│😴│😐│ │😊│😐│😴│     │
│  └─┘ └─┘   └─┘ └─┘                      └─┴─┴─┘ └─┴─┴─┴─┴─┴─┘ └─┴─┴─┘     │
│       ║                                       ║                 ║          │
│      AISLE                                  AISLE             AISLE        │
│                                                                             │
│  [◀ Galley]        [Lavatory]               [Crew member: Marie]           │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│  CABIN STATUS                                                               │
│  Phase: Meal Service │ Lighting: Daylight │ Time to dest: 4h 23m          │
│  Satisfaction: Business 87% │ Economy 72% │ Overall 76%                   │
│                                                                             │
│  [Speed: 1x ▼] [Exit cabin] [Jump to landing]                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2.2 Passenger Visualization

Each seat shows:
- Occupancy (filled or empty)
- Current mood (emoji indicator)
- Current activity (eating, sleeping, watching, working)

**Click on passenger for detail:**

```
┌─────────────────────────────────┐
│  PASSENGER · Seat 24A           │
│                                 │
│  Mood: Content 😊               │
│  Activity: Watching movie       │
│                                 │
│  Satisfaction factors:          │
│  + Seat pitch adequate          │
│  + IFE working well             │
│  + Meal quality good            │
│  − Long wait for lavatory       │
│                                 │
│  Segment: Business traveler     │
│  Fare paid: €847                │
│  Loyalty: Silver member         │
└─────────────────────────────────┘
```

---

## 3. Passenger Mood System

### 3.1 Mood States

| Emoji | State | Satisfaction Range | Behavior |
|-------|-------|-------------------|----------|
| 😊 | Happy | 80-100% | Relaxed, may recommend |
| 😌 | Content | 65-80% | Normal |
| 😐 | Neutral | 50-65% | Indifferent |
| 😤 | Uncomfortable | 35-50% | Fidgeting, complaining |
| 😠 | Unhappy | 20-35% | Visible frustration |
| 😡 | Angry | 0-20% | May cause incident |

### 3.2 Mood Modifiers

**Configuration factors (from cabin-designer):**

| Factor | Impact | Notes |
|--------|--------|-------|
| Seat pitch | ±15% | Below 30" = negative |
| Seat width | ±10% | Below 17" = negative |
| Recline | ±5% | No recline = penalty |
| IFE quality | ±10% | Screen size, content |
| Window access | ±3% | Window seats happier |
| Aisle access | ±3% | Aisle preferred for long-haul |

**Service factors (real-time):**

| Factor | Impact | Duration |
|--------|--------|----------|
| Meal quality | ±15% | After meal service |
| Meal timing | ±5% | Late service = penalty |
| Beverage availability | ±5% | Running out = penalty |
| Crew attentiveness | ±10% | Response to requests |
| Lavatory wait | ±5% | >10 min wait = penalty |
| WiFi performance | ±5% | If offered but slow |

**Flight factors:**

| Factor | Impact | Notes |
|--------|--------|-------|
| On-time departure | ±10% | Delay penalty |
| Turbulence | ±5% | During event |
| Cabin temperature | ±5% | Too hot/cold |
| Cabin pressure | ±3% | Higher altitude = fatigue |
| Flight duration | -0.5%/hr | Gradual fatigue |
| Night flight | ±5% | If lighting appropriate |

### 3.3 Mood Calculation

```
Base_Satisfaction = 70%

Config_Modifier = f(pitch, width, IFE, amenities)
Service_Modifier = f(meal_quality, crew_rating, wait_times)
Flight_Modifier = f(delay, turbulence, duration)

Current_Satisfaction = Base + Config + Service + Flight

Clamp to [0%, 100%]
```

### 3.4 Segment Sensitivity

| Segment | Most Sensitive To | Least Sensitive To |
|---------|-------------------|-------------------|
| **Business** | WiFi, power, timing | Price, food |
| **Premium Leisure** | Comfort, food, IFE | Price |
| **Leisure** | IFE, food | Timing, WiFi |
| **VFR** | Price | Comfort, IFE |
| **Budget** | Price, delays | Comfort, food |

---

## 4. Service Phases

### 4.1 Phase Definitions

| Phase | Duration | Activities |
|-------|----------|------------|
| **Boarding** | 20-45 min | Passengers finding seats, stowing bags |
| **Taxi & Takeoff** | 10-30 min | Safety demo, seatbelt signs |
| **Initial Cruise** | 30-60 min | Drink service begins |
| **Meal Service** | 45-90 min | Main meal, beverages |
| **Rest Period** | Variable | Lights dim, passengers sleep/watch |
| **Second Service** | 30-60 min | Snack or second meal (long-haul) |
| **Pre-Landing** | 30-45 min | Cabin prep, customs forms |
| **Landing & Taxi** | 10-20 min | Arrival, deboarding |

### 4.2 Phase Visualization

Current phase shown in cabin view with:
- Phase name and progress bar
- Crew positions appropriate to phase
- Passenger activities matching phase
- Cabin lighting matching phase

### 4.3 Phase Transitions

```
BOARDING
  └→ Doors closed, pushback
TAXI & TAKEOFF
  └→ Seatbelt sign off, 10,000 ft
INITIAL CRUISE
  └→ Galley activity begins
MEAL SERVICE
  └→ Meal carts cleared
REST PERIOD (long-haul only)
  └→ 2 hours before landing
SECOND SERVICE (long-haul only)
  └→ Cabin prep announcement
PRE-LANDING
  └→ Wheels down
LANDING & TAXI
  └→ Doors open
```

---

## 5. Crew Visualization

### 5.1 Crew Display

Crew members shown as figures moving through cabin:
- Position in cabin (galley, aisle, seat)
- Current task (serving, resting, assisting)
- Fatigue indicator (for long flights)

### 5.2 Crew States

| State | Visual | Trigger |
|-------|--------|---------|
| **Serving** | Moving with cart | Meal/beverage service |
| **Assisting** | At passenger seat | Request response |
| **Resting** | In crew rest | Long-haul duty |
| **Preparing** | In galley | Pre-service prep |
| **Standby** | Jump seat | Between services |

### 5.3 Crew Fatigue

| Duty Time | Fatigue Level | Service Impact |
|-----------|---------------|----------------|
| 0-4 hours | Fresh | Full effectiveness |
| 4-8 hours | Normal | Normal effectiveness |
| 8-12 hours | Tired | -10% response time |
| 12+ hours | Fatigued | -20% response, visible |

---

## 6. Real-Time Events

### 6.1 In-Flight Events

| Event | Probability | Visual | Passenger Impact |
|-------|-------------|--------|------------------|
| **Turbulence** | 10-30%/flight | Camera shake | -5% satisfaction |
| **Meal choice unavailable** | 5-15% | Crew apologizing | -10% affected pax |
| **IFE malfunction** | 2-5% | Blank screen | -15% affected pax |
| **Lavatory queue** | Common | Visible line | -5% waiting pax |
| **Medical situation** | 0.1% | Crew rushing | Neutral (handled) |
| **Disruptive passenger** | 0.5% | Visible incident | -10% nearby pax |
| **Upgrade surprise** | Rare (your policy) | Happy passenger | +20% upgraded pax |

### 6.2 Event Visualization

Events appear as:
- Visual indicators in cabin
- Brief notification
- Passenger mood changes rippling through cabin

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  ⚠ IN-FLIGHT EVENT                                                          │
│                                                                             │
│  Turbulence encountered · Moderate                                         │
│  Duration: ~8 minutes                                                      │
│                                                                             │
│  Crew securing cabin, seatbelt sign illuminated                            │
│  Passenger satisfaction temporarily affected                               │
│                                                                             │
│  [Dismiss]                                                                  │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 7. Connection to Systems

### 7.1 What Living Flight Reflects

| System | What You See | Configured In |
|--------|--------------|---------------|
| Cabin layout | Seat arrangement, classes | Cabin Designer |
| Seat quality | Passenger comfort | Cabin Designer |
| IFE | Screens, content engagement | Service Suppliers |
| Meals | Food service quality | Service Suppliers |
| Crew | Staffing, service quality | Crew Management |
| Delays | Boarding/departure | Network Scheduler |
| Load factor | Seat occupancy | Route Economics |

### 7.2 What Living Flight Doesn't Do

- No decisions made during observation
- No direct intervention (you're CEO, not crew)
- No micromanagement of service
- No impact on running simulation (view only)

---

## 8. Performance Budgets

### 8.1 Rendering Tiers

| Mode | Detail Level | Performance Target |
|------|--------------|-------------------|
| **Globe** | Dots on arcs | 60 fps, minimal load |
| **Follow** | Single aircraft model | 60 fps, low load |
| **Cabin** | Full interior | 30 fps, moderate load |

### 8.2 Cabin View Limits

| Element | Maximum | Notes |
|---------|---------|-------|
| Visible passengers | 50-80 | Render visible section only |
| Animated crew | 4-8 | Active crew members |
| Particle effects | Minimal | Meal steam, etc. |
| Dynamic lighting | Simple | Phase-based, not raytraced |

### 8.3 Optimization Rules

1. Only render cabin view for observed flight
2. All other flights use simulation-only (no visuals)
3. Cabin view uses simplified passenger models
4. LOD system for distant passengers
5. Pool passenger models by mood state

---

## 9. Data Model Integration

### 9.1 FlightSnapshot Entity

Real-time flight state (from data-model.md):

| Field | Type | Purpose |
|-------|------|---------|
| `flight_id` | FK | Which flight |
| `timestamp` | datetime | Snapshot time |
| `phase` | enum | Current service phase |
| `cabin_satisfaction_avg` | float | 0-1 |
| `cabin_satisfaction_business` | float | By cabin |
| `cabin_satisfaction_economy` | float | By cabin |
| `crew_fatigue_avg` | float | 0-1 |
| `active_events` | json | Current in-flight events |
| `service_issues` | json | Problems encountered |

### 9.2 New Enumerations

```yaml
ServicePhase:
  BOARDING
  TAXI_OUT
  TAKEOFF
  INITIAL_CRUISE
  MEAL_SERVICE
  REST_PERIOD
  SECOND_SERVICE
  PRE_LANDING
  LANDING
  TAXI_IN
  DEBOARDING

PassengerMood:
  HAPPY           # 80-100%
  CONTENT         # 65-80%
  NEUTRAL         # 50-65%
  UNCOMFORTABLE   # 35-50%
  UNHAPPY         # 20-35%
  ANGRY           # 0-20%

PassengerActivity:
  BOARDING
  SETTLING
  WATCHING_IFE
  WORKING
  EATING
  SLEEPING
  READING
  WAITING_LAVATORY
  CONVERSATION

CabinLighting:
  BRIGHT          # Boarding, meal service
  DIMMED          # Rest period
  NIGHT           # Night flights
  SUNRISE         # Wake-up service

InFlightEventType:
  TURBULENCE_LIGHT
  TURBULENCE_MODERATE
  TURBULENCE_SEVERE
  MEAL_CHOICE_UNAVAILABLE
  IFE_MALFUNCTION
  LAVATORY_QUEUE
  MEDICAL_SITUATION
  DISRUPTIVE_PASSENGER
  UPGRADE_SURPRISE
  CREW_ANNOUNCEMENT
```

---

## 10. UI Controls

### 10.1 Cabin View Controls

| Control | Action |
|---------|--------|
| **Mouse drag** | Pan camera along cabin |
| **Scroll** | Zoom in/out |
| **Click passenger** | Show detail panel |
| **Click crew** | Show crew status |
| **Speed slider** | 0.5x to 4x observation speed |
| **Phase skip** | Jump to next service phase |
| **Exit** | Return to Follow or Globe view |

### 10.2 Information Overlays

| Overlay | Toggle | Shows |
|---------|--------|-------|
| **Mood heatmap** | M | Color-coded satisfaction |
| **Activity icons** | A | What passengers are doing |
| **Crew paths** | C | Crew movement patterns |
| **Service progress** | S | Phase timeline |
| **Issues** | I | Active problems highlighted |

---

## 11. Audio Design

### 11.1 Ambient Sounds

| Phase | Ambient | Notes |
|-------|---------|-------|
| Boarding | Chatter, bag rustling | Busy, anticipatory |
| Cruise | Engine hum, quiet murmur | Peaceful |
| Meal service | Cart wheels, cutlery | Active but controlled |
| Rest | Very quiet, occasional cough | Hushed |
| Turbulence | Engine change, creaks | Tension |

### 11.2 Event Sounds

| Event | Sound | Volume |
|-------|-------|--------|
| Seatbelt sign | Ding | Medium |
| Crew announcement | PA voice | Low |
| Turbulence start | Rumble | Medium |
| Meal cart | Wheels on floor | Low |
| Happy passenger | None | — |
| Unhappy passenger | Sigh/grumble | Very low |

---

## 12. Future Considerations

Not in v1.0:

- First-person walkthrough mode
- Individual passenger stories/profiles
- Crew conversation system
- Premium cabin detail (flat beds animating)
- Weather visible through windows
- Real-time route progress on IFE screens

---

## Document History

| Version | Date | Changes |
|---------|------|---------|
| 0.1 | January 2026 | Initial specification |
